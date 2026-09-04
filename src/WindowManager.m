#import "WindowManager.h"

@implementation WindowManager

+ (instancetype)sharedManager {
    static WindowManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WindowManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _windowDic = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (UIWindow *)windowForKey:(NSString *)key {
    if (!key) return nil;
    @synchronized ([self sharedManager].windowDic) {
        return [self sharedManager].windowDic[key];
    }
}

+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key {
    if (!key || !window) return;
    @synchronized ([self sharedManager].windowDic) {
        [self sharedManager].windowDic[key] = window;
    }
}

+ (void)addWindow:(UIWindow *)window forKey:(NSString *)key {
    [self saveWindow:window forKey:key];
}

+ (void)destroyWindowForKey:(NSString *)key {
    if (!key) return;
    @synchronized ([self sharedManager].windowDic) {
        UIWindow *window = [self sharedManager].windowDic[key];
        if (window) {
            window.hidden = YES;
            [[self sharedManager].windowDic removeObjectForKey:key];
        }
    }
}

+ (void)destroyAllWindow {
    @synchronized ([self sharedManager].windowDic) {
        for (NSString *key in [self sharedManager].windowDic.allKeys) {
            UIWindow *window = [self sharedManager].windowDic[key];
            window.hidden = YES;
        }
        [[self sharedManager].windowDic removeAllObjects];
    }
}

@end
