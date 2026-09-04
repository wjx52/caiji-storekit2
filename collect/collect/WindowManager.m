#import "WindowManager.h"

@implementation WindowManager

+ (instancetype)shared {
    static WindowManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WindowManager alloc] init];
        instance.windowDic = [NSMutableDictionary dictionary];
    });
    return instance;
}

+ (UIWindow *)windowForKey:(NSString *)key {
    if (!key) return nil;
    return [[WindowManager shared].windowDic objectForKey:key];
}

+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key {
    if (!key || !window) return;
    [[WindowManager shared].windowDic setObject:window forKey:key];
}

+ (void)destroyWindowForKey:(NSString *)key {
    if (!key) return;
    UIWindow *window = [[WindowManager shared].windowDic objectForKey:key];
    if (window) {
        window.hidden = YES;
        [window resignKeyWindow];
        [[WindowManager shared].windowDic removeObjectForKey:key];
    }
}

+ (void)destroyAllWindow {
    NSMutableDictionary *dic = [WindowManager shared].windowDic;
    for (NSString *key in dic.allKeys) {
        UIWindow *window = dic[key];
        window.hidden = YES;
        [window resignKeyWindow];
    }
    [dic removeAllObjects];
}

@end
