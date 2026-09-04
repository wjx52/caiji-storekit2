#import <UIKit/UIKit.h>

@interface CollectWindow : UIWindow

@property (nonatomic, weak) UIWindow *lastKeyWindow;
@property (nonatomic, assign) BOOL zy_canAffectStatusBarAppearance;
@property (nonatomic, assign) BOOL zy_canBecomeKeyWindow;

@end
