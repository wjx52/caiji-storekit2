#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "src/CollectAppStore.h"
#import "src/WindowManager.h"
#import "src/view/CollectWindow.h"

// Forward declare the Swift SK2 class (loaded at runtime from collect_sw.dylib)
@interface SimpleStoreKit : NSObject
- (void)purchaseWithProductID:(NSString *)productID completion:(void (^)(BOOL success))completion;
- (void)restorePurchasesWithCompletion:(void (^)(BOOL success))completion;
@end

#pragma mark - ObserverItem

@interface ObserverItem : NSObject
@property (nonatomic, weak) id<SKPaymentTransactionObserver> observer;
+ (instancetype)itemWithObserver:(id<SKPaymentTransactionObserver>)observer;
@end

@implementation ObserverItem
+ (instancetype)itemWithObserver:(id<SKPaymentTransactionObserver>)observer {
    ObserverItem *item = [[ObserverItem alloc] init];
    item.observer = observer;
    return item;
}
@end

#pragma mark - ClassTool

@interface ClassTool : NSObject
@property (nonatomic, strong) NSMutableArray<ObserverItem *> *observerItems;
@property (nonatomic, strong) SimpleStoreKit *sk2Instance;
@property (nonatomic, assign) BOOL sk2Available;
@property (nonatomic, assign) BOOL sk2Purchasing;
+ (instancetype)shared;
- (void)loadSK2;
- (void)purchaseViaSK2:(NSString *)productID;
@end

@implementation ClassTool

+ (instancetype)shared {
    static ClassTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ClassTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _observerItems = [NSMutableArray array];
        _sk2Available = NO;
        _sk2Purchasing = NO;
        [self loadSK2];
    }
    return self;
}

- (void)loadSK2 {
    if (@available(iOS 15.0, *)) {
        // Try to load the collect_sw dynamic library
        NSString *dylibPath = @"/Library/MobileSubstrate/DynamicLibraries/collect_sw.dylib";
        void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
        if (handle) {
            Class sk2Class = NSClassFromString(@"SimpleStoreKit");
            if (sk2Class) {
                self.sk2Instance = [[sk2Class alloc] init];
                self.sk2Available = YES;
                NSLog(@"[collect] SK2 loaded successfully via collect_sw.dylib");
            } else {
                NSLog(@"[collect] SimpleStoreKit class not found in collect_sw.dylib");
            }
        } else {
            NSLog(@"[collect] Failed to load collect_sw.dylib: %s", dlerror());
        }
    } else {
        NSLog(@"[collect] iOS < 15.0, SK2 not available");
    }
}

- (void)purchaseViaSK2:(NSString *)productID {
    if (!self.sk2Available || !self.sk2Instance) {
        NSLog(@"[collect] SK2 not available, cannot purchase");
        return;
    }
    self.sk2Purchasing = YES;
    NSLog(@"[collect] Starting SK2 purchase for productID: %@", productID);
    [self.sk2Instance purchaseWithProductID:productID completion:^(BOOL success) {
        self.sk2Purchasing = NO;
        if (success) {
            NSLog(@"[collect] SK2 purchase succeeded for productID: %@", productID);
        } else {
            NSLog(@"[collect] SK2 purchase failed for productID: %@", productID);
        }
    }];
}

- (void)addObserverItem:(id<SKPaymentTransactionObserver>)observer {
    @synchronized (self.observerItems) {
        // Avoid duplicates
        for (ObserverItem *item in self.observerItems) {
            if (item.observer == observer) return;
        }
        [self.observerItems addObject:[ObserverItem itemWithObserver:observer]];
        NSLog(@"[collect] Stored transaction observer: %@", observer);
    }
}

@end

#pragma mark - SKPaymentQueue Hooks

%hook SKPaymentQueue

- (void)addPayment:(SKPayment *)payment {
    ClassTool *tool = [ClassTool shared];
    if (tool.sk2Available) {
        NSString *productId = payment.productIdentifier;
        NSLog(@"[collect] Intercepting addPayment, redirecting to SK2 for productID: %@", productId);
        [tool purchaseViaSK2:productId];
        return;
    }
    NSLog(@"[collect] SK2 not available, falling through to SK1 addPayment");
    %orig;
}

- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
    ClassTool *tool = [ClassTool shared];
    if (tool.sk2Available) {
        NSLog(@"[collect] SK2 active, storing observer instead of adding to SK1 queue");
        [tool addObserverItem:observer];
        return;
    }
    NSLog(@"[collect] SK2 not available, adding SK1 transaction observer");
    %orig;
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    ClassTool *tool = [ClassTool shared];
    if (tool.sk2Available || tool.sk2Purchasing) {
        NSLog(@"[collect] SK2 active, skipping SK1 finishTransaction");
        return;
    }
    %orig;
}

%end

#pragma mark - UIWindow Hook

%hook UIWindow

- (void)makeKeyWindow {
    %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[collect] UIWindow makeKeyWindow — initializing ClassTool");
        [ClassTool shared];

        // Show collect window
        dispatch_async(dispatch_get_main_queue(), ^{
            CollectWindow *collectWin = [[CollectWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            collectWin.hidden = NO;
            [WindowManager addWindow:collectWin forKey:@"collectWindow"];
            NSLog(@"[collect] CollectWindow displayed");
        });
    });
}

%end

#pragma mark - Constructor

%ctor {
    NSLog(@"[collect] Tweak loaded — SK2+SK1 bridge architecture");
    [[CollectAppStore manager] setDefaultObserver];
}
