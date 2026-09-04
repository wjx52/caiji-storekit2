#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^PurchaseCallback)(NSDictionary *transactionInfo, NSError *error);

@interface CollectAppStore : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate>

@property (nonatomic, copy) NSString *userfilePatch;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) void(^backMassages)(NSDictionary *info);
@property (nonatomic, copy) NSString *profductId;
@property (nonatomic, copy) NSString *profductName;
@property (nonatomic, weak) UIViewController *testTableViewController;

+ (instancetype)manager;

- (void)requestProductData:(NSString *)productId;
- (void)uploadTransaction:(SKPaymentTransaction *)transaction;
- (NSString *)getInternetDate:(NSDate *)date;

/// Login with username and password
- (void)loginWithUsername:(NSString *)username andPwd:(NSString *)password;

/// Setup / UI helper methods (originally obfuscated names)
- (void)setupCollectUI;
- (void)configureProductDisplay;
- (void)handlePurchaseResult;

@end
