//
//  DriverProfileCell.h
//  Adogo
//
//  Created by Sumit on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *driverImage;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverMobileNo;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *viewProfileButton;

- (void)displayData:(NSDictionary *)dataDict;
@end
