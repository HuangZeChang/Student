/* 多线程方式创建数据库，批量执行事务
   如果在多线程中同时使用一个FMDatabase实例，会造成数据混乱。
   使用FMDatabaseQueue，它是线程安全的
 */

#import "DBService.h"
#import "FMDatabase.h" //数据库头文件，执行create alter drop insert update delete等更新语句
#import "FMResultSet.h"//数据集头文件，执行select语句
#import "FMDatabaseQueue.h"

@implementation DBService
static DBService *_instance=nil;//全局静态变量，为当前类唯一的实例对象
//static FMDatabase *db=nil;      //全局静态变量，指向唯一数据库实例对象
static FMDatabaseQueue *dbQueue=nil;

//==============数据库的初始化、数据表的添删查改等方法封装===============
//NSHomeDirectory()返回当前沙盒根目标路径,需加上Documents文件夹前缀
-(void)InitXJGL//仅仅初始化数据库连接字符串
{   NSString *strPath=[NSHomeDirectory() stringByAppendingPathComponent:
                                  @"Documents/xjgl.sqlite"];
    dbQueue = [FMDatabaseQueue databaseQueueWithPath:strPath];
}

/* blob为二进制流照片类型，对应OC中的NSData类型
   datetime为日期时间型，实际存储double类型的时间戳，对应OC中的NSDate类型;
   BOOL类型存储1/0对应OC中YES/NO
   学生表结构:学号sID、姓名sName、性别sSex、年龄sAge、入学日期sEnterDate、照片sPhoto
*/

-(BOOL)CreateStudentTable
{   __block BOOL ret;
    NSString *sql=@"create table if not exists student(sID char(10) primary key,sName  char(10) not null,sSex bool, sAge integer,sEnterDate date, sPhoto blob)";
    
    [dbQueue inDatabase:^(FMDatabase *db) {
         if (![db open]) {//创建或打开目标数据库 没有则新建，有则为打开；仅在准备操作时打开数据库
             [db close];
             return ;
            }
         ret=[db executeUpdate:sql];//执行更新语句
         [db close];//数据库用完需及时关闭
     }];
    return ret;
}

-(BOOL)CreateUserTable;//创建登录用户表
{
    __block BOOL ret;
    NSString *sql=@"create table if not exists user(uName,uPassWord,uPhoto blob)";
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {//创建或打开目标数据库 没有则新建，有则为打开；仅在准备操作时打开数据库
            [db close];
            return ;
        }
        ret=[db executeUpdate:sql];//执行更新语句
        [db close];//数据库用完需及时关闭
    }];
    return ret;
}

//封装学生表的添加记录方法，参数为需要添加的Student对象
-(BOOL)AddStudent:(Student *) insertStu
{
    static BOOL ret;//block中访问全局变量,就不要__block修饰
    
    //通过SelectStudentWithID:查找即将添加的学号值，若在表中已存在表示主键重复，返回NO
    if ([self  SelectStudentWithID:insertStu.sID]) {
         NSLog(@"already have this student");
         return NO;}
    
    NSString *sql=@" insert into student(sID,sName,sSex,sAge,sEnterDate,sPhoto) values(?,?,?,?,?,? ) ";//学号值不重复时，向表中添加当前值记录  不确定参数用?来占位
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSArray *argument=@[insertStu.sID,insertStu.sName,@(insertStu.sSex),@(insertStu.sAge),insertStu.sEnterDate,insertStu.sPhoto];//对应参数依次封装为对象放入数组
        
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;     }
        
        ret=[db executeUpdate:sql withArgumentsInArray:argument];//使用数组参数执行更新
        [db close];//数据库用完需及时关闭
    }];
    return ret;
}

-(BOOL)AddUser:(User *) insertUser;//向User数据表中添加一个用户对象
{
    static BOOL ret;//block中访问全局变量,就不要__block修饰
    
    if ([self SelectUserWithName:insertUser.userName]) {
            NSLog(@"already have this user");
            return NO;}
    
    NSString *sql=@" insert into user(uName,uPassWord,uPhoto) values(?,?,?) ";    [dbQueue inDatabase:^(FMDatabase *db) {
        NSArray *argument=@[insertUser.userName,insertUser.userPassWord,insertUser.userPhoto];//对应参数依次封装为对象放入数组
        
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;     }
        
        ret=[db executeUpdate:sql withArgumentsInArray:argument];//使用数组参数执行更新
        [db close];//数据库用完需及时关闭
    }];
    return ret;
}

-(Student *)SelectStudentWithID:(NSString *)sID//根据学号值查询学生对象
{   Student *stuFinder=[[Student alloc]init];//查找的学生对象
    __block int flag=0;
    [dbQueue inDatabase:^(FMDatabase *db) {
       if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
           [db close];
           return ;
       }
       NSString *sql=@"select * from student where sID=? ";
       FMResultSet *result=[db executeQuery:sql,sID];//获取查询结果集
       if ([result next]) {//找到学生时，读取表中第一条记录
           flag=1;
           stuFinder.sID=[result stringForColumn:@"sID"];//读取当前记录的学号字段值
           stuFinder.sName=[result stringForColumn:@"sName"];//读取当前记录的姓名字段值
           stuFinder.sSex=[result boolForColumn:@"sSex"];//读取当前记录的性别字段值
           stuFinder.sAge=[result intForColumn:@"sAge"];//读取当前记录的年龄字段值
           stuFinder.sEnterDate=[result dateForColumn:@"sEnterDate"];//读取当前记录入学日期值
           stuFinder.sPhoto=[result dataForColumn:@"sPhoto"];//读取当前记录的blob照片字段值
                             }
        [db close];
    }];
    if (flag==1) {
        return stuFinder;
    }
    else
        return nil;
}

-(User *)SelectUserWithName:(NSString *)uName//根据账号名称返回找到的用户对象
{
    User *userFinder=[[User alloc]init];//查找的用户对象
    __block int flag=0;
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;}
        
        NSString *sql=@"select * from user where uName=? ";
        FMResultSet *result=[db executeQuery:sql,uName];//获取查询结果集
        if ([result next]) {//找到学生时，读取表中第一条记录
            flag=1;
            userFinder.userName=[result stringForColumn:@"uName"];//当前记录账号名
            userFinder.userPassWord=[result stringForColumn:@"uPassWord"];//密码值
            userFinder.userPhoto=[result dataForColumn:@"uPhoto"];//当前记录blob照片
        }
        [db close];
    }];
    if (flag==1) {
        return userFinder;
    }
    else
        return nil;
}

-(NSMutableArray *)getAllStudents
{   NSMutableArray *allStudents=[[NSMutableArray alloc]init];//用于保存所有学生对象
    NSString *sql=@"select * from student ";
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;//有问题时返回空对象
        }
        FMResultSet *result=[db executeQuery:sql];//获取查询结果集
        while ([result next]) {//依次读取表中的每一条记录
            Student *stuRow=[[Student alloc]init];//当前记录对应的学生对象
            stuRow.sID=[result stringForColumn:@"sID"];//读取当前记录的学号字段值
            stuRow.sName=[result stringForColumn:@"sName"];//读取当前记录的姓名字段值
            stuRow.sSex=[result boolForColumn:@"sSex"];//读取当前记录的性别字段值
            stuRow.sAge=[result intForColumn:@"sAge"];//读取当前记录的年龄字段值
            stuRow.sEnterDate=[result dateForColumn:@"sEnterDate"];//读取当前记录的入学日期值
            stuRow.sPhoto=[result dataForColumn:@"sPhoto"];//读取当前记录的blob照片字段值
            [allStudents addObject:stuRow];
        }
        [db close];
    }];
    return allStudents;//返回查找的所有学生对象数组
}

-(NSMutableArray *)SelectStudentWithNameLike:(NSString *)sName
{
    NSMutableArray *allStudents=[[NSMutableArray alloc]init];//用于保存所有学生对象
    NSString *sql=[[@"select * from student where sName like '%" stringByAppendingString:sName] stringByAppendingString:@"%'"];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;//有问题时返回空对象
        }
        FMResultSet *result=[db executeQuery:sql];//获取查询结果集
        while ([result next]) {//依次读取表中的每一条记录
            Student *stuRow=[[Student alloc]init];//当前记录对应的学生对象
            stuRow.sID=[result stringForColumn:@"sID"];//读取当前记录的学号字段值
            stuRow.sName=[result stringForColumn:@"sName"];//读取当前记录的姓名字段值
            stuRow.sSex=[result boolForColumn:@"sSex"];//读取当前记录的性别字段值
            stuRow.sAge=[result intForColumn:@"sAge"];//读取当前记录的年龄字段值
            stuRow.sEnterDate=[result dateForColumn:@"sEnterDate"];//读取当前记录的入学日期值
            stuRow.sPhoto=[result dataForColumn:@"sPhoto"];//读取当前记录的blob照片字段值
            [allStudents addObject:stuRow];
        }
        [db close];
    }];
    return allStudents;//返回查找的所有学生对象数组
}


//根据学号值修改记录中其它字段，参数为需要修改的Student对象
-(BOOL)UpdateStudent:(Student *) updateStu
{   __block BOOL ret;//表示在block内部不要把外部变量当做常量使用,当变量使用
    //通过SelectStudentWithID:查找将修改学号值，若不在表中则不用修改，返回NO
    if (![self  SelectStudentWithID:updateStu.sID]) {
        return NO;}
    
    NSString *sql=@"update student set sName=?,sSex=?,sAge=?,sEnterDate=?,sPhoto=? where sID=? ";//找到该学生，则根据学号进行修改
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSArray *argument=@[updateStu.sName,@(updateStu.sSex),@(updateStu.sAge),updateStu.sEnterDate,updateStu.sPhoto,updateStu.sID];//对应参数依次封装为对象放入数组
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;
        }
        ret=[db executeUpdate:sql withArgumentsInArray:argument];
        [db close];//数据库用完需及时关闭
    }];
   return ret;
}

-(BOOL)DeleteStudentWithID:(NSString *)sID//根据学号值删除记录
{   __block BOOL ret;
    NSString *sql=@"delete from student where sID=? ";
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {  //打开目标数据库；仅在准备操作时打开数据库
            [db close];
            return ;
        }
        ret=[db executeUpdate:sql,sID];
        [db close];//数据库用完需及时关闭
    }];
    return ret;
}


//==当前类单实例引用 阻止用户用alloc copy mutableCopy方法创建实例对象==
+(DBService *) ShareDBService
{
    static dispatch_once_t onceToKen;//用于检查代码块是否已被调用
    //dispatch_one函数保证语句块中代码只被执行一次，且线程安全
    dispatch_once(&onceToKen, ^{
        _instance=[[super allocWithZone:NULL]init];
    });
    return _instance;
}

//调用类alloc方法，自动调用allocWithZone申请内存，重写该方法，返回单实例
+(id) allocWithZone:(struct _NSZone *)zone
{  return [DBService ShareDBService];  }

//copy方法返回一个新对象，对象属性为浅复制，重写该方法，返回单实例
-(id) copyWithZone:(struct _NSZone *)zone
{return [DBService ShareDBService];}

//mutableCopy方法返回新对象，对象属性为深复制，重写该方法，返回单实例
-(id) mutableCopyWithZone:(struct _NSZone *)zone
{return [DBService ShareDBService];}

@end
























