#import "AppDelegate.h"
#import "DBService.h"//使用数据访问类
#import "Student.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSThread sleepForTimeInterval:(1.0)];//控制LaunchImage界面的显示时间
    
    NSLog(@"%@",NSHomeDirectory());//输出沙盒根目录路径
    
    DBService *dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例方法
    
    [dbs InitXJGL]; //初始化数据库连接字符串
    
    [dbs CreateStudentTable]; //通过单实例创建学生数据表
  
    [dbs CreateUserTable]; //通过单实例创建用户数据表

    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
