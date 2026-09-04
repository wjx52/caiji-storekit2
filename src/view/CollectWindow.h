#import <UIKit/UIKit.h>

@interface CollectWindow : UIWindow

@property (nonatomic, weak) UIWindow *lastKeyWindow;

- (BOOL)zy_canAffectStatusBarAppearance;
- (BOOL)zy_canBecomeKeyWindow;

@end
