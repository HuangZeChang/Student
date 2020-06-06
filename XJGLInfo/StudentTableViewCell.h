
#import <UIKit/UIKit.h>

@interface StudentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *sNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sSexLabel;
@property (weak, nonatomic) IBOutlet UILabel *sAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sEnterDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sPhotoImageView;
@end
