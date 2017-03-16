//
//  CarHistoryTableViewCell.h
//  Adogo
//
//  Created by Hema on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CamapaignHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *comapnyImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *campaignIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *earningLabel;
@property (weak, nonatomic) IBOutlet UILabel *carPlateNoLabel;
@end
