#import <Foundation/Foundation.h>
#import "Student.h"//定义学生对象用
#import "User.h" //定义登录用户对象用

@interface DBService : NSObject  //数据库服务类，封装所有数据库操作行为
+(DBService *)ShareDBService;//类中公开获取单实例的方法

//============＝＝＝＝＝＝＝数据库操作方法的封装===＝＝================
//SQLite是在MRC下运行，使用完SQLite3后要及时关闭，不然会内存泄漏
-(void)InitXJGL;//仅仅初始化数据库连接字符串

//======================学生表的数据操作方法============================
-(BOOL)CreateStudentTable;//创建学生数据表
-(BOOL)AddStudent:(Student *) insertStu;//向student数据表中添加一个学生对象
-(Student *)SelectStudentWithID:(NSString *)sID;//根据学号返回找到的学生对象
-(BOOL)UpdateStudent:(Student *) updateStu;//修改Student学生对象
-(BOOL)DeleteStudentWithID:(NSString *)sID;//根据学号删除记录
-(NSMutableArray *)getAllStudents;//返回所有学生对象的数组
-(NSMutableArray *)SelectStudentWithNameLike:(NSString *)sName;

//======================用户登录表的数据操作方法============================
-(BOOL)CreateUserTable;//创建登录用户表
-(BOOL)AddUser:(User *) insertUser;//向User数据表中添加一个用户对象
-(User *)SelectUserWithName:(NSString *)uName;//根据账号名称返回找到的用户对象

@end


