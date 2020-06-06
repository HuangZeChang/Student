#import <UIKit/UIKit.h>

@class User,RegisterViewController; //仅仅是类的声明

//协议声明
@protocol RegisterViewControllerDelegate <NSObject>
@optional//可选方法
-(void) registerViewController:(RegisterViewController *) regVC
               didRegisterUser:(User *) user;
@end

@interface RegisterViewController : UIViewController
//设置代理属性，不论何种对象实现该协议，即可成为其代理
@property (nonatomic,weak) id<RegisterViewControllerDelegate> delegate;

@end
