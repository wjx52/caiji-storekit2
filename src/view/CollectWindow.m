#import "CollectWindow.h"

@implementation CollectWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];

        // Store reference to current key window via connectedScenes
        UIWindow *kw = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { kw = w; break; }
                }
            }
            if (kw) break;
        }
        self.lastKeyWindow = kw;
    }
    return self;
}

- (BOOL)zy_canAffectStatusBarAppearance {
    return NO;
}

- (BOOL)zy_canBecomeKeyWindow {
    return NO;
}

- (BOOL)canAffectStatusBarAppearance {
    return NO;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

@end
