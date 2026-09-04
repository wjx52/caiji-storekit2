#import "CollectWindow.h"

@implementation CollectWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.zy_canAffectStatusBarAppearance = NO;
        self.zy_canBecomeKeyWindow = YES;
    }
    return self;
}

// Override private API: _canAffectStatusBarAppearance
- (BOOL)_canAffectStatusBarAppearance {
    return self.zy_canAffectStatusBarAppearance;
}

// Override private API: _canBecomeKeyWindow
- (BOOL)_canBecomeKeyWindow {
    return self.zy_canBecomeKeyWindow;
}

@end
