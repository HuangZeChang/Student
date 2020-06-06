#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "DBService.h"
#import "User.h"

@interface RegisterViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{ BOOL regSuccess;}  //记录当前用户在数据库中注册是否成功
   
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPassWordField;
@property (weak, nonatomic) IBOutlet UITextField *passWordAgainField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property(nonatomic,strong)UIImagePickerController *imagePicker;//照片选择器
@end

@implementation RegisterViewController

- (IBAction)backLoginBtn:(id)sender //返回按钮,要使用代理向前界面传递当前界面用户信息
{
    [self dismissViewControllerAnimated:YES completion:nil];//消失当前控制器，回到登录界面
    
    if (regSuccess) {//数据库中注册成功，才需通过代理向前面控制器逆传值
        //当前界面信息，实例化为User用户对象,作为代理参数传递
        NSData *userPhoto=UIImageJPEGRepresentation(_photoImageView.image, 1.0);
        User *user=[User userWithName:_userNameField.text passWord:_userPassWordField.text photo:userPhoto];
        
        //_delegate表示前面源控制器 self表示当前控制器 user表示逆传值对象
        [_delegate registerViewController:self didRegisterUser:user];
   }
}

- (IBAction)registerBtn:(id)sender//注册按钮，检测界面数据有效性，向数据表添加一条记录
{
    NSInteger letterCount,numberCount;//某文本框中字符和数字个数
    
    //实例化一个消息控制器对象，提示内容的消息参数Message根据判断重新赋值，再弹出
    UIAlertController *alertC=[UIAlertController  alertControllerWithTitle:@"提示"
                                                                   message:@"提示"preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:okAction];
    
    if ([_userNameField.text isEqualToString:@""])
    {   alertC.message=@"账号不能为空!";
        [_userNameField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    //计算账户名中数字个数,根据规则判断内容有效性
//    letterCount=[self letterCount:_userNameField.text];
    numberCount=[self numberCount:_userNameField.text];
    if (letterCount<1 ||numberCount<1 ||letterCount+numberCount<6) {
        alertC.message=@"账号不能少于6位!";
        [_userNameField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    if ([_userPassWordField.text isEqualToString:@""])
    {   alertC.message=@"密码不能为空!";
        [_userPassWordField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    //计算密码文本框中字母及数字个数,判断内容有效性
    numberCount=[self numberCount:_userPassWordField.text];
    if (letterCount<1 ||numberCount<1 ||letterCount+numberCount<6) {
        alertC.message=@"密码不能少于6位，且必须由字符和数字组成!";
        [_userPassWordField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    if (![_userPassWordField.text isEqualToString:_passWordAgainField.text])
    {   alertC.message=@"两次密码必须完全相同!";
        [_passWordAgainField becomeFirstResponder];
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
    
    DBService *dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例方法
       
    //界面中符合条件的控件值去实例化用户对象
    NSData *userPhoto=UIImageJPEGRepresentation(_photoImageView.image, 1.0);//图片转Ndata
    User *user=[User userWithName:_userNameField.text passWord:_userPassWordField.text photo:userPhoto];//调用User类的工厂方法实例化对象
    
    BOOL ret=[dbs AddUser:user];//数据服务类方法，增加一条用户记录
    
    if (ret) {
        alertC.message=@"注册用户成功!";
        regSuccess=YES;
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }else
    {
        alertC.message=@"注册用户失败!";
        regSuccess=NO;
        [self presentViewController:alertC animated:true completion:nil];
        return;
    }
 
}

//-(NSInteger) letterCount:(NSString *) text//返回字符串参数中含有多少个英文字母字符
//{   //英文字符规则表达式
//    NSRegularExpression *regular=[NSRegularExpression
//                                   regularExpressionWithPattern:@"[A-Za-z]" options:
//                                     NSRegularExpressionCaseInsensitive error:nil];
//    //计算英文字母有几个
//    NSUInteger count = [regular numberOfMatchesInString:text options:
//                        NSMatchingReportProgress range:NSMakeRange(0, text.length)];
//    return count;
//}

-(NSInteger) numberCount:(NSString *) text //返回字符串参数中含有多少个数字字符
{   //数字字符规则表达式
    NSRegularExpression *regular= [NSRegularExpression
                                       regularExpressionWithPattern:@"[0-9]"
                                       options:NSRegularExpressionCaseInsensitive
                                            error:nil];
    //计算数字字符有几个
    NSUInteger count=[regular numberOfMatchesInString:text
                                                  options:NSMatchingReportProgress
                                                    range:NSMakeRange(0,text.length)];
    return count;
}


- (IBAction)photoLongPressGesture:(UILongPressGestureRecognizer *)sender//头像上长按手势
{
    self.imagePicker=[[UIImagePickerController alloc]init];
    self.imagePicker.delegate=self;//设置代理
    self.imagePicker.allowsEditing=YES;//设置可以用户编辑
    self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    //在当前界面上弹出照片选择控制器
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//实现图片选择器代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{   //获取得到的图片
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickImage=[info valueForKey:UIImagePickerControllerEditedImage];
    self.photoImageView.image =pickImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker//取消相册选择器
{[picker dismissViewControllerAnimated:YES completion:nil];}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //将登录头像改为圆形
    self.photoImageView.layer.masksToBounds=YES;
    self.photoImageView.layer.cornerRadius=self.photoImageView.frame.size.height/2.0;
    self.photoImageView.layer.borderWidth=2;
    self.photoImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    
    regSuccess=NO;//注册是否成功标志，初始时设置为NO
}

-(BOOL)prefersStatusBarHidden//隐藏控制器上的状态栏，系统方法
{return YES;}

//文本框中输入完后，单击界面空白区消失键盘
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{ [self.view endEditing:YES];}

//文本框中回车键触发该事件，为UITextFieldDelegate中方法，需求界面中关联控制器的Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{  if (textField==self.userNameField) //当前为姓名框，跳转到密码框
            [self.userPassWordField becomeFirstResponder]; //获得焦点，光标停留在其中
   else if (textField==self.userPassWordField) //当前为密码框,跳转到再输入一次密码框
       [self.passWordAgainField becomeFirstResponder]; //获得焦点，出现光标
   else
       [self.view endEditing:YES]; // 消失键盘
    
   return YES;
}


@end
