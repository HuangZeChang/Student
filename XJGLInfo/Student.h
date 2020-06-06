
#import <Foundation/Foundation.h>

@interface Student : NSObject //封装学生对象，对应数据表中学生实体
//student(sID char(10) primary key,sName  char(10) not null,sSex bool, sAge integer,sEnterDate date, sPhoto blob)
@property(nonatomic,strong) NSString *sID;
@property(nonatomic,strong) NSString *sName;
@property(nonatomic,assign) BOOL sSex;
@property(nonatomic,assign) int sAge;
@property(nonatomic,strong) NSDate *sEnterDate;
@property(nonatomic,strong) NSData *sPhoto;
@end


