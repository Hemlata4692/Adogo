//
//  DefaultCarCell.h
//  Adogo
//
//  Created by Sumit on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultCarCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@property (weak, nonatomic) IBOutlet UIButton *defaultCarBtn;
@property (weak, nonatomic) IBOutlet UILabel *carModelLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceInfoLbl;
@property (weak, nonatomic) IBOutlet UILabel *carRegistrationLbl;
@property (weak, nonatomic) IBOutlet UILabel *warningLbl;
@property (weak, nonatomic) IBOutlet UIView *lblBgView;

- (void)displayData:(NSDictionary *)dataDict;
@end
