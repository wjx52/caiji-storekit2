#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface CollectAppStore : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate>

/// StoreKit 1 properties
@property (nonatomic, strong) SKPayment *payment;
@property (nonatomic, strong) NSMutableArray *transactions;
@property (nonatomic, strong) SKPaymentTransaction *transaction;
@property (nonatomic, strong) SKPaymentTransaction *failedtransaction;
@property (nonatomic, strong) SKPaymentTransaction *purchasedtransaction;
@property (nonatomic, strong) SKPaymentQueue *paymentQueue;
@property (nonatomic, strong) id observer;

/// Receipt and persistence
@property (nonatomic, copy) NSString *userfilePatch;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *profductId;
@property (nonatomic, copy) NSString *profductName;
@property (nonatomic, copy) NSString *receiptTemporary;
@property (nonatomic, copy) NSString *receiptTimeChar;
@property (nonatomic, copy) NSString *orderNo;
@property (nonatomic, copy) NSString *transactiondate;
@property (nonatomic, assign) BOOL written;

/// UI
@property (nonatomic, strong) UIView *HUD;
@property (nonatomic, weak) UIViewController *testTableViewController;

/// Callback
@property (nonatomic, copy) void(^backMassages)(NSDictionary *info);

/// Singleton
+ (instancetype)manager;

/// Observer
- (void)setDefaultObserver;

/// Product request (StoreKit 1)
- (void)requestProductData:(NSString *)productId;
- (void)uploadTransaction:(SKPaymentTransaction *)transaction;

/// Receipt handling
- (void)getTransactionReceipt:(SKPaymentTransaction *)transaction;
- (void)transactionFailed;

/// Login
- (void)loginWithUsername:(NSString *)username andPwd:(NSString *)password;

/// Utility
- (NSString *)stringToMD5:(NSString *)input;
- (BOOL)isBlankString:(NSString *)string;
- (NSString *)getInternetDate:(NSDate *)date;

/// HUD
- (void)showHUD;
- (void)dismissHUD;

@end
