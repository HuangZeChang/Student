#import "FindStudentViewController.h"
#import "DBService.h"
#import "Student.h"//定义学生对象需使用
@interface FindStudentViewController ()<UITextFieldDelegate>//文本框回车键编程
@property (weak, nonatomic) IBOutlet UITextField *sIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *sNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *sSexTextField;
@property (weak, nonatomic) IBOutlet UITextField *sAgeTextField;
@property (weak, nonatomic) IBOutlet UITextField *sEnterDateTextField;
@property (weak, nonatomic) IBOutlet UIImageView *sPhotoImageView;
@end

@implementation FindStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide) name:UIKeyboardWillHideNotification object:nil];
    
    //将UIImageView改为圆形
    self.sPhotoImageView.layer.masksToBounds=YES;
    self.sPhotoImageView.layer.cornerRadius=self.sPhotoImageView.frame.size.height/2.0;
    self.sPhotoImageView.layer.borderWidth=2;
    self.sPhotoImageView.layer.borderColor=[UIColor whiteColor].CGColor;
}

-(BOOL)prefersStatusBarHidden
{return YES;}

- (IBAction)findStudentBtnTouched:(id)sender
{   if ([self.sIDTextField.text isEqual:@""]) {
        [self.sIDTextField becomeFirstResponder];
        [self showMessage:@"请输入要查找的学号值!"];
        return;
    }
    DBService *dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例方法
    NSString *sID=self.sIDTextField.text; //需要查找的学号值
    
 //===================根据文本框中输入的学号查询该学生信息============================
    Student *stuFinder=[dbs SelectStudentWithID:sID];//存放找到的学生信息
    if (stuFinder!=nil) {//找到该学生信息，在下面控件中显示相应的值
        self.sNameTextField.text=stuFinder.sName;//显示查找的姓名
        
        if (stuFinder.sSex) {//判断查找的性别值
            self.sSexTextField.text=@"男";
        }else
            {self.sSexTextField.text=@"女";}
        
        //显示查找的年龄值
        self.sAgeTextField.text=[NSString stringWithFormat:@"%d",stuFinder.sAge];
        
        NSDateFormatter *dFormatter=[[NSDateFormatter alloc]init];//日期格式转换器
        dFormatter.dateFormat=@"yyyy-MM-dd";//MM表示日期中月份,mm表示日期中秒数，区分大小写
        NSTimeZone *desTimeZone= [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [dFormatter setTimeZone:desTimeZone];
        NSDate *sEnterDate=stuFinder.sEnterDate;//查找的入学日期对象
        self.sEnterDateTextField.text=[dFormatter stringFromDate:sEnterDate];
        
        NSData *sPhoto=stuFinder.sPhoto;//查找的头像NSData对象
        self.sPhotoImageView.image=[UIImage  imageWithData:sPhoto];
    }else
    {   self.sIDTextField.text=@"";
        self.sNameTextField.text=@"";
        self.sSexTextField.text=@"";
        self.sAgeTextField.text=@"";
        self.sEnterDateTextField.text=@"";
        self.sPhotoImageView.image=nil;
        NSString *message=[NSString stringWithFormat:@"没有找到学号为%@的记录",sID];
        [self showMessage:message];
            }
}

- (IBAction)cancelBtnTouched:(id)sender {
    self.sIDTextField.text=@"";
    self.sNameTextField.text=@"";
    self.sAgeTextField.text=@"";
    self.sSexTextField.text=@"";
    self.sEnterDateTextField.text=@"";
    self.sPhotoImageView.image=nil;
}

//文本框中输入完后，单击界面空白区消失键盘
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{[self.view endEditing:YES];}

//回车键事件，为UITextFieldDelegate中方法，需求界面中关联控制器的Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{ [self.view endEditing:YES];
  return YES;}

-(void)keyBoardShow//键盘弹出时触发该方法
{   [UIView animateWithDuration:0.2//动画持续的时间
                          delay:0.0//动画开始执行前等待的时间
                        options:UIViewAnimationOptionCurveEaseInOut//设置动画类型
                     animations:^{//动画效果代码块
                         CGRect rect=self.view.frame;
                         rect.origin.y-=50;
                         self.view.frame=rect;
                     } completion:^(BOOL finished) {
                     }];
}

-(void)keyBoardHide//键盘关闭时触发该方法
{  [UIView animateWithDuration:0.2
                         delay:0.0
                       options:UIViewAnimationOptionCurveEaseInOut//设置动画类型
                    animations:^{//开始动画
                        CGRect rect=self.view.frame;
                        rect.origin.y=0;
                        self.view.frame=rect;
                    } completion:^(BOOL finished) {//结束时的处理
                    }];}

-(void) showMessage:(NSString *) context
{   UIAlertController *alertC=[UIAlertController  alertControllerWithTitle:@"提示" message:context preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:okAction];
    [self presentViewController:alertC animated:true completion:nil];
}

@end
