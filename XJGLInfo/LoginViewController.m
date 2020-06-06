#import "LoginViewController.h"
#import "RegisterViewController.h"//注册控制器头文件
#import "DBService.h"
#import "User.h"

@interface LoginViewController ()<UITextFieldDelegate,RegisterViewControllerDelegate>
{ BOOL regSuccess;}  //注册成功用户可直接登录，无需再判断

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPassWordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //将头像控件改为圆形  
    self.photoImageView.layer.masksToBounds=YES;
    self.photoImageView.layer.cornerRadius=self.photoImageView.frame.size.height/2.0;
    self.photoImageView.layer.borderWidth=2;
    self.photoImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    
    regSuccess=NO;//注册成功标志，初始时设置为NO
    
    //若选择了记住密码，则下次显示时，读取偏好设置中存储的数据

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *name=[defaults objectForKey:@"Name"];
    NSString *password=[defaults objectForKey:@"PassWord"];
    NSData *photo=[defaults objectForKey:@"Photo"];
    
    BOOL remember=[[defaults objectForKey:@"isRemember"]  boolValue] ;
    NSLog(@"remember=%d",remember);
    _userNameField.text=name;
    _photoImageView.image=[UIImage imageWithData:photo];
    if (remember) {
        _userPassWordField.text=password;
    }
    _rememberSwitch.on=YES;
}


//登录按钮，条件成立再跳转到TabBarController
//故事板中仅拖了当前控制器到目标控制器的Segue,并指定标识符,根据标识符再跳转
- (IBAction)loginBtnTouched:(UIButton *)sender
{
    if (regSuccess) { //通过注册界成功注册后，则直接登录，无需判断
        [self performSegueWithIdentifier:@"tabBar" sender:self];
        return;
    }
    
    //没有进入注册界面，直接输入几账号和密码时，则需从数据表中查找是否存在该账号
    
    //预先定义一个消息提示框对象，具体弹出前再重设Message参数
    UIAlertController *alertC=[UIAlertController  alertControllerWithTitle:@"提示"
                                                                   message:@"提示"preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:okAction];
    
    //判断用户名和密码是否正确，不正确时给出提示，并退出当前方法
    if ([self.userNameField.text isEqualToString:@""])
    {   alertC.message=@"账号不能为空值!";
        [self.userNameField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    if ([self.userPassWordField.text isEqualToString:@""])
    {   alertC.message=@"密码不能为空值!";
        [self.userPassWordField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    DBService *dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例方法
    User *userFinder=[dbs SelectUserWithName:_userNameField.text];//存放找到的用户信息
    if (userFinder!=nil) //找到该账户信息，则取出该账号的密码与输入密码比较是否正确
    {
        if (![userFinder.userPassWord isEqualToString:_userPassWordField.text]) {
            alertC.message=@"密码不正确,请重新输入!";
            _userPassWordField.text=@"";
            [_userPassWordField becomeFirstResponder];
            [self presentViewController:alertC animated:true completion:nil];
            return;
        }
        else //找到该用户，且密码也正确，则显示该用户的头像,并进入主界面控制器
        {
            NSData *userPhoto=userFinder.userPhoto;//当前登录用户的头像NSData对象
            self.photoImageView.image=[UIImage  imageWithData:userPhoto];
            
            //在用户名和密码都正确情况下，触发下面指定Segue ID为"tabBar"跳转
            [self performSegueWithIdentifier:@"tabBar" sender:self];
            
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            //若界面中选中了记住密码，将当前成功登录用户信息写入“系统偏好设置文件中永久存储”
            
            //获取当前应用的偏好设置单例对象
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            
            NSString *name=_userNameField.text;
            NSString *password=_userPassWordField.text;
            NSNumber *remember=[NSNumber numberWithBool:_rememberSwitch.on];
            NSData *photo=UIImageJPEGRepresentation(_photoImageView.image, 1.0);
            [defaults  setObject:name forKey:@"Name"];
            [defaults  setObject:password forKey:@"PassWord"];
            [defaults  setObject:remember forKey:@"isRemember"];
            [defaults  setObject:photo forKey:@"Photo"];
            
            //强制上面数据“键值对”立刻保存
            [defaults synchronize];
            
          }
    }
    else
    {
        alertC.message=@"该账户信息不存在!";
        _userNameField.text=@"";
        _userPassWordField.text=@"";
        [_userNameField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
}

/* 说明:故事板中segue为2种：自动型和手动型
   自动型:从某一控件拖线，点击控件时自动从当前控制器跳转到目标控制器，没有有任何判断
   手动型:直接从来源控制器拖线到目标控制器即可，只知从来源跳转到目标，跳转需下面这句代码判断
*/

//注册按钮，执行故事板中Segue ID为"register"的跳转，这里不用判断可不用写手动跳转语句
- (IBAction)registerBtnTouched:(id)sender
{
  // [self performSegueWithIdentifier:@"register" sender:self];
}

//在执行Segue跳转之前，先执行下面prepareForSegue方法，可设置控制器跳转方式
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    segue.destinationViewController.modalTransitionStyle=
                   UIModalTransitionStyleFlipHorizontal; //水平翻转切换
    
    //根据标识符，获取目标控制器，将当前控制器设置为目标控制器的代理，实现逆向传值
    if ([segue.identifier isEqualToString:@"register"]) {
        RegisterViewController *regVC=segue.destinationViewController;
        regVC.delegate=self;
    }
}

//重要:目标控制器中代理方法，已在目标控制器中完成传值，通过代理协议方法读取传来的user参数显示在当前界面上
-(void) registerViewController:(RegisterViewController *)add didRegisterUser:(User *)user
{
    _userNameField.text=user.userName;
    _userPassWordField.text=user.userPassWord;
    _photoImageView.image=[UIImage imageWithData:user.userPhoto];
    
    regSuccess=YES;//设置注册成功标志
}

-(BOOL)prefersStatusBarHidden//隐藏控制器上状态栏，系统方法
{return YES;}

//文本框中输入完后，单击界面空白区消失键盘
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{ [self.view endEditing:YES];}

//文本框中回车键触发该事件，为UITextFieldDelegate中方法，需求界面中关联控制器的Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{  if (textField==self.userNameField) {
    [self.userPassWordField becomeFirstResponder];
}else
    [self.view endEditing:YES];
    return YES;
}


@end
