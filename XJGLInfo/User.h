#import <Foundation/Foundation.h>
//用户表在数据库中结构如下：user(uName,uPassWord,uPhoto blob)

@interface User : NSObject  //通过创建模型，实现多个数据封装
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *userPassWord;
@property(nonatomic,strong) NSData *userPhoto;

//工厂方法快速创建对象，对属性初始化  静态方法，用类名调用
+(instancetype) userWithName:(NSString *) name passWord:(NSString *) passWord
                       photo:(NSData *) photo;
@end
