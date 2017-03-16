//
//  AddCarDimensionCell.h
//  Adogo
//
//  Created by Ranosys on 10/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCarDimensionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *approvedLabel;
@property (strong, nonatomic) IBOutlet UIImageView *approvedByAdmin;
@property (strong, nonatomic) IBOutlet UILabel *carSidelabel;
@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UIView *carDimensionView;
@property (strong, nonatomic) IBOutlet UITextField *lengthField;
@property (strong, nonatomic) IBOutlet UITextField *heightField;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

@property (strong, nonatomic) IBOutlet UILabel *lengthLabel;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *lengthMeasurement;
@property (strong, nonatomic) IBOutlet UILabel *heightMeasurement;
@property (strong, nonatomic) IBOutlet UILabel *adminNote;

@property (weak, nonatomic) IBOutlet UIView *noteBackView;
- (void)displayCellData:(NSMutableArray *)data index:(int)index;
@end
