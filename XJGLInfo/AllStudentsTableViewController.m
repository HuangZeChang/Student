
#import "AllStudentsTableViewController.h"
#import "DBService.h"//调用数据访问服务类中的getAllStudents方法
#import "Student.h"//每个单元格显示一个学生对象
#import "StudentTableViewCell.h"//需要使用自定义的Student单元格类

@interface AllStudentsTableViewController ()<UISearchBarDelegate>
{
    DBService *dbs;
    NSMutableArray *allStudents;//存放所有学生信息的数组
    NSMutableArray *filterStudents;//存放筛选后的学生信息
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AllStudentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dbs=[DBService ShareDBService];//获取数据服务类DBService的唯一单实例方法
    allStudents=[dbs getAllStudents];
    filterStudents=[[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated
{   allStudents=[dbs getAllStudents];
    [self.tableView reloadData];
}

-(BOOL)prefersStatusBarHidden
{return YES;}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{  if (self.searchBar.text.length==0)
        return allStudents.count;
   else
        return filterStudents.count;
    }

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   StudentTableViewCell *stuCell=[tableView dequeueReusableCellWithIdentifier:@"stuCell"];
    Student *curStu=[[Student alloc]init];
    if (self.searchBar.text.length==0)
        curStu=[allStudents objectAtIndex:indexPath.row];
    else
        curStu=[filterStudents objectAtIndex:indexPath.row];
 
    stuCell.sIDLabel.text=[NSString stringWithFormat:@"学号:%@",curStu.sID];
    stuCell.sNameLabel.text=[NSString stringWithFormat:@"姓名:%@",curStu.sName];
    if (curStu.sSex) {
        stuCell.sSexLabel.text=@"性别:男";
    }else
        stuCell.sSexLabel.text=@"性别:女";
    stuCell.sAgeLabel.text=[NSString stringWithFormat:@"年龄:%d",curStu.sAge];
    
    NSDateFormatter *dFormatter=[[NSDateFormatter alloc]init];
    dFormatter.dateFormat=@"yyyy-MM-dd";
    NSTimeZone *desTimeZone= [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dFormatter setTimeZone:desTimeZone];
    NSDate *sEnterDate=curStu.sEnterDate;
    stuCell.sEnterDateLabel.text=[NSString stringWithFormat:@"入学日期:%@",
                                  [dFormatter stringFromDate:sEnterDate]];
    stuCell.sPhotoImageView.image=[UIImage imageWithData:curStu.sPhoto];
    return stuCell;
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length!=0) {
        filterStudents=[dbs SelectStudentWithNameLike:searchText];
    }
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{ [self.searchBar resignFirstResponder];}

@end
















