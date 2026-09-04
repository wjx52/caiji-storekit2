#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WindowManager : NSObject

/// Window dictionary — stores named windows for management
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIWindow *> *windowDic;

/// Get a window by key
+ (UIWindow *)windowForKey:(NSString *)key;

/// Save a window with a key
+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key;

/// Destroy a window by key
+ (void)destroyWindowForKey:(NSString *)key;

/// Destroy all managed windows
+ (void)destroyAllWindow;

/// Add a window with a key (convenience alias)
+ (void)addWindow:(UIWindow *)window forKey:(NSString *)key;

@end
