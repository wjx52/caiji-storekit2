#import "CollectAppStore.h"

@implementation CollectAppStore

+ (instancetype)manager {
    static CollectAppStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CollectAppStore alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _transactions = [NSMutableArray array];
        _paymentQueue = [SKPaymentQueue defaultQueue];
        _written = NO;
    }
    return self;
}

- (void)setDefaultObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSLog(@"[collect] CollectAppStore registered as transaction observer");
}

#pragma mark - Product Request (StoreKit 1)

- (void)requestProductData:(NSString *)productId {
    if (![SKPaymentQueue canMakePayments]) {
        if (self.backMassages) {
            self.backMassages(@{@"error": @"Device cannot make payments"});
        }
        return;
    }
    NSSet *productIds = [NSSet setWithObject:productId];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray<SKProduct *> *products = response.products;
    if (products.count > 0) {
        SKProduct *product = products.firstObject;
        self.profductId = product.productIdentifier;
        self.profductName = product.localizedTitle;
        self.currency = [product.priceLocale objectForKey:NSLocaleCurrencyCode];

        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        self.payment = payment;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)requestDidFinish:(SKRequest *)request {
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self dismissHUD];
    if (self.backMassages) {
        self.backMassages(@{@"error": error.localizedDescription ?: @"Request failed"});
    }
}

#pragma mark - Transaction Observer (StoreKit 1)

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                self.purchasedtransaction = transaction;
                [self getTransactionReceipt:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                self.failedtransaction = transaction;
                [self transactionFailed];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    return NO;
}

- (void)paymentQueueDidChangeStorefront:(SKPaymentQueue *)queue {
}

- (void)paymentQueue:(SKPaymentQueue *)queue didRevokeEntitlementsForProductIdentifiers:(NSArray<NSString *> *)productIdentifiers {
}

#pragma mark - Receipt Handling

- (void)getTransactionReceipt:(SKPaymentTransaction *)transaction {
    NSMutableDictionary *transInfo = [NSMutableDictionary dictionary];
    transInfo[@"transactionIdentifier"] = transaction.transactionIdentifier ?: @"";
    transInfo[@"productIdentifier"] = transaction.payment.productIdentifier ?: @"";
    transInfo[@"transactiondate"] = [self getInternetDate:transaction.transactionDate] ?: @"";
    transInfo[@"orderNo"] = transaction.transactionIdentifier ?: @"";
    transInfo[@"profductId"] = self.profductId ?: @"";
    transInfo[@"profductName"] = self.profductName ?: @"";
    transInfo[@"currency"] = self.currency ?: @"";

    // Extract and base64 encode the receipt
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString *receiptBase64 = @"";
    if (receiptURL) {
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        if (receiptData) {
            receiptBase64 = [receiptData base64EncodedStringWithOptions:0];
            transInfo[@"receipt"] = receiptBase64;
        }
    }

    if (transaction.originalTransaction) {
        transInfo[@"srcOrderNo"] = transaction.originalTransaction.transactionIdentifier ?: @"";
    }

    // Store receipt temporarily
    self.receiptTemporary = receiptBase64;
    self.receiptTimeChar = [self getInternetDate:transaction.transactionDate];
    self.orderNo = transaction.transactionIdentifier;
    self.transactiondate = [self getInternetDate:transaction.transactionDate];

    // Persist to local file
    NSString *filePath = [self userfilePatch];
    if (filePath) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:filePath]) {
            [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *receiptPath = [filePath stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"%@receipt.plist", transaction.transactionIdentifier]];
        [transInfo writeToFile:receiptPath atomically:YES];

        NSString *historyPath = [filePath stringByAppendingPathComponent:@"buyHistory"];
        NSMutableArray *history = [NSMutableArray arrayWithContentsOfFile:historyPath] ?: [NSMutableArray array];
        [history addObject:transInfo];
        [history writeToFile:historyPath atomically:YES];
    }

    // Add to transactions array
    [self.transactions addObject:transInfo];
    self.written = YES;

    if (self.backMassages) {
        self.backMassages(transInfo);
    }
}

- (void)transactionFailed {
    [self dismissHUD];
    SKPaymentTransaction *transaction = self.failedtransaction;
    NSString *errorMessage = transaction.error.localizedDescription ?: @"Purchase failed";
    NSLog(@"[collect] Transaction failed: %@", errorMessage);

    if (self.backMassages) {
        self.backMassages(@{@"error": errorMessage});
    }
}

#pragma mark - Upload Transaction

- (void)uploadTransaction:(SKPaymentTransaction *)transaction {
    [self getTransactionReceipt:transaction];
}

#pragma mark - Login

- (void)loginWithUsername:(NSString *)username andPwd:(NSString *)password {
    if ([self isBlankString:username] || [self isBlankString:password]) {
        NSLog(@"[collect] Login: username or password is blank");
        return;
    }

    NSString *md5Pwd = [self stringToMD5:password];
    [self showHUD];

    NSLog(@"[collect] Login request with username: %@", username);

    // Store credentials to PersonalInformation.plist
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *plistPath = [docPath stringByAppendingPathComponent:@"PersonalInformation.plist"];
    NSDictionary *userInfo = @{@"username": username ?: @"", @"password": password ?: @""};
    [userInfo writeToFile:plistPath atomically:YES];

    [self dismissHUD];
}

#pragma mark - HUD

- (void)showHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.HUD) return;

        UIWindow *kw = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { kw = w; break; }
                }
            }
            if (kw) break;
        }
        if (!kw) return;

        self.HUD = [[UIView alloc] initWithFrame:kw.bounds];
        self.HUD.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [kw addSubview:self.HUD];

        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        indicator.center = self.HUD.center;
        [self.HUD addSubview:indicator];
        [indicator startAnimating];
    });
}

- (void)dismissHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    });
}

#pragma mark - Utility

- (NSString *)stringToMD5:(NSString *)input {
    if (!input) return nil;
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
#pragma clang diagnostic pop

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

- (BOOL)isBlankString:(NSString *)string {
    if (!string) return YES;
    if ([string isKindOfClass:[NSNull class]]) return YES;
    if (![string isKindOfClass:[NSString class]]) return YES;
    if (string.length == 0) return YES;

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [string stringByTrimmingCharactersInSet:whitespace];
    return trimmed.length == 0;
}

- (NSString *)getInternetDate:(NSDate *)date {
    if (!date) return @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
