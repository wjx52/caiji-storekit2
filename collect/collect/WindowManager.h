#import <UIKit/UIKit.h>

@interface WindowManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *windowDic;

+ (instancetype)shared;
+ (UIWindow *)windowForKey:(NSString *)key;
+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key;
+ (void)destroyWindowForKey:(NSString *)key;
+ (void)destroyAllWindow;

@end
