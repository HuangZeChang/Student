#import "User.h"

@implementation User
+(instancetype) userWithName:(NSString *) name passWord:(NSString *) passWord
                       photo:(NSData *) photo
{
    User *user=[[User alloc]init];//创建当前类的实例
    user.userName=name;
    user.userPassWord=passWord;
    user.userPhoto=photo;
    return user; //返回赋好值的实例对象
}

@end
