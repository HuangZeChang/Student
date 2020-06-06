#import "AddStudentViewController.h"
#import "DBService.h"//使用数据访问类
#import "Student.h"//定义学生对象需使用
//遵守文本框代理协议实现键盘回车键事件、照片选择控制器及导航控制器协议实现相册访问
@interface AddStudentViewController ()<UITextFieldDelegate,
           UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField   *sIDTextField;//学号文本框
@property (weak, nonatomic) IBOutlet UITextField   *sNameTextField;//姓名文本框
@property (weak, nonatomic) IBOutlet UITextField   *sAgeTextField;//年龄文本框
@property (weak, nonatomic) IBOutlet UIImageView   *sPhotoImageView;//头像图片控件
@property (weak, nonatomic) IBOutlet UIStepper     *sAgeStepper;//步进控件输入年龄
@property(nonatomic,strong)UIImagePickerController *imagePicker;//定义照片选择器对象
@end

@implementation AddStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //注册通知中心监听器，监听键盘弹起和收起事件 程序内部之间的消息广播机制
    //获取NSNotificationCenter唯一单例 每个应用程序都有一个默认的通知中心
    //观察者self在收到名为UIKeyboardWillShowNotification事件时，执行@selector中方法
    //object参数为nil表示接收所有发送者的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide) name:UIKeyboardWillHideNotification object:nil];
    
    self.sAgeStepper.value=[self.sAgeTextField.text doubleValue];
    
    //将UIImageView改为圆形
    self.sPhotoImageView.layer.masksToBounds=YES;
    self.sPhotoImageView.layer.cornerRadius=self.sPhotoImageView.frame.size.height/2.0;
    self.sPhotoImageView.layer.borderWidth=2;
    self.sPhotoImageView.layer.borderColor=[UIColor whiteColor].CGColor;
}

-(BOOL)prefersStatusBarHidden//隐藏控制器上的状态栏，系统方法
{return YES;}

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

//文本框中输入完后，单击界面空白区消失键盘
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{[self.view endEditing:YES];}

//文本框中输入时，按回车键触发该事件，切换文本框输入焦点,为UITextFieldDelegate中方法，需求界面中关联控制器的Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{  if (textField==self.sIDTextField) {
        [self.sNameTextField becomeFirstResponder];
    }else
        [self.view endEditing:YES];
    return YES;
}

- (IBAction)sPhotoImageViewLongPress:(UILongPressGestureRecognizer *)sender
{   self.imagePicker=[[UIImagePickerController alloc]init];
    self.imagePicker.delegate=self;//设置代理
    self.imagePicker.allowsEditing=YES;//设置可以用户编辑
    self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    //在当前界面上弹出照片选择控制器
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//实现图片选择器代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{   //获取得到的图片
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickImage=[info valueForKey:UIImagePickerControllerEditedImage];
    self.sPhotoImageView.image =pickImage;
}

- (IBAction)backBtnTouched:(id)sender//返回按钮
{
    [self dismissViewControllerAnimated:YES completion:nil];//消失当前控制器，回到登录界面
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{[picker dismissViewControllerAnimated:YES completion:nil];}

- (IBAction)sAgeStepperChanged:(UIStepper *)sender
{  int curValue=(int)sender.value;
    self.sAgeTextField.text=[NSString stringWithFormat:@"%d",curValue];
}

- (IBAction)InsertOrUpdateBtnTouched:(UIButton *)sender
{   if ([self.sIDTextField.text isEqual:@""]) {
        [self.sIDTextField becomeFirstResponder];
        [self showMessage:@"学号不能为空!"];
        return;}
    
    if ([self.sNameTextField.text isEqual:@""]) {
        [self.sNameTextField becomeFirstResponder];
        [self showMessage:@"姓名不能为空!"];
        return;}
    
    if ([self.sAgeTextField.text isEqual:@""]) {
        [self showMessage:@"年龄不能为空!"];
        return;}
    
    DBService *dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例
    Student *stu=[[Student alloc]init]; //实例化需要插入数据的学生对象
    stu.sID=self.sIDTextField.text;
    stu.sName=self.sNameTextField.text;
    stu.sAge=[self.sAgeTextField.text intValue];
    UIImage *sPhotoImage=self.sPhotoImageView.image;
    stu.sPhoto=UIImageJPEGRepresentation(sPhotoImage, 1.0);
  //===================日期控件中值的获取及转换为指定格式的日期===================
    NSDateFormatter *dFormatter=[[NSDateFormatter alloc]init];//日期格式转换器
    dFormatter.dateFormat=@"yyyy-MM-dd";//MM表示日期中月份,mm表示日期中秒数，区分大小写
    NSTimeZone *desTimeZone= [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dFormatter setTimeZone:desTimeZone];

    NSDate *dpDate=self.sEnterDatePicker.date;//获取控件中的当前日期值
    NSString *dpDateStr=[dFormatter stringFromDate:dpDate];//将当前日期转换为指定格式的字符串
    stu.sEnterDate=[dFormatter dateFromString:dpDateStr];//将字符日期转换为日期类型
 //=====================＝＝性别值由Segment控件的选择来赋值===================
    if (self.sSexSegment.selectedSegmentIndex==0)
        stu.sSex=YES;//YES表示男
    else
        stu.sSex=NO; //NO表示女
 //=================根据选择的按钮，调用学生表的添加或修改 方法=========================
    BOOL ret;
    switch (sender.tag) {
        case 1://添加按钮
            ret=[dbs  AddStudent:stu];
            NSLog(@"ret=%d",ret);
            if (!ret){
                [self showMessage:@"学生已存在，不能重复添加！"];
                self.sIDTextField.text=@"";
                self.sNameTextField.text=@"";
                self.sAgeTextField.text=@"0";
            }else
                [self showMessage:@"添加学生记录成功!"];
            break;
        case 2://修改按钮
            ret=[dbs UpdateStudent:stu];
            if (ret==NO){
                [self showMessage:@"不存在该学生,请输入修改学号！"];
                self.sIDTextField.text=@"";
                self.sNameTextField.text=@"";
                self.sAgeTextField.text=@"0";
            }
            else
                [self showMessage:@"修改学生记录成功!"];
            break;
        default:
            break;
    }
}

- (IBAction)cancelBtnTouched:(UIButton *)sender
{
    self.sIDTextField.text=@"";
    self.sNameTextField.text=@"";
    self.sAgeTextField.text=@"0";
}

-(void) showMessage:(NSString *) context
{
    UIAlertController *alertC=[UIAlertController  alertControllerWithTitle:@"提示" message:context preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:okAction];
    [self presentViewController:alertC animated:true completion:nil];
}

@end






