
#import "StudentTableViewCell.h"

@implementation StudentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //将UIImageView改为圆形
    self.sPhotoImageView.layer.masksToBounds=YES;
    self.sPhotoImageView.layer.cornerRadius=self.sPhotoImageView.frame.size.height/2.0;
    self.sPhotoImageView.layer.borderWidth=2;
    self.sPhotoImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    
    int R =(arc4random()%256); //产生0-255之间的一个随机整数
    int G =(arc4random()%256); //RGB3个参数为0-1范围
    int B =(arc4random()%256);
    self.contentView.backgroundColor=[UIColor colorWithRed:R/255.0
                                                     green:G/255.0
                                                      blue:B/255.0
                                                     alpha:0.2];

}
@end

/*+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;//指定RGB，参数是：红、绿、黄、透明度，范围是0-1
 */

/*UIWebView的使用方法  iOS9新特性要求App内访问的网络必须使用HTTPS协议
  Info.plist配置  增加下面选项的子选项，设置为YES
  增加=> App Transport Security Settings=> Allow Arbitrary Loads=>YES
 
  NSString *urlString=@"https://baike.baidu.com/item/%E9%99%88%E4%BC%9F%E9%9C%86/3463936?fr=aladdin";
  NSURL *url=[NSURL URLWithString:urlString];
  NSURLRequest *request=[NSURLRequest requestWithURL:url];
  [self.myWebView loadRequest:request];
  */
