#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "StoreKitBridge.h"
#import "WindowManager.h"
#import "view/CollectWindow.h"

@class CollectAppStore;

@interface CollectAppStore : NSObject
+ (instancetype)manager;
- (void)setupCollectUI;
@end

static NSString *applicationDocumentsDirectory(void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

static void showCollectWindow(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CollectWindow *window = [[CollectWindow alloc] initWithFrame:screenBounds];
        window.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
        window.zy_canAffectStatusBarAppearance = NO;
        window.zy_canBecomeKeyWindow = YES;
        window.hidden = NO;

        [WindowManager saveWindow:window forKey:@"collectWindow"];
    });
}

%hook UIWindow

- (void)makeKeyWindow {
    %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Start the unified StoreKit listener (SK2 on iOS 15+, SK1 fallback)
        [[StoreKitBridge shared] startTransactionListener];

        [[StoreKitBridge shared] setTransactionUpdateCallback:^(NSDictionary *info) {
            NSString *filePath = applicationDocumentsDirectory();
            [[StoreKitBridge shared] saveTransactionToLocal:info filePath:filePath];
        }];

        showCollectWindow();
    });
}

%end

%hook SKPaymentQueue

- (void)addPayment:(SKPayment *)payment {
    if ([[StoreKitBridge shared] useStoreKit2]) {
        NSLog(@"[collect] SK2 active, intercepting addPayment for product: %@", payment.productIdentifier);
        // SK2 handles purchases through StoreKit2Manager, skip SK1 payment queue
        return;
    }
    %orig;
}

%end

static void getProduct(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        showCollectWindow();
    });
}

%ctor {
    getProduct();
}
