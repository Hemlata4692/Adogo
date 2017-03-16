//
//  CampaignSummaryCell.h
//  Adogo
//
//  Created by Sumit on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignSummaryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *campaignImage;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *campaignName;
@property (weak, nonatomic) IBOutlet UILabel *advertiserName;
@property (weak, nonatomic) IBOutlet UILabel *durationLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel *pointsEarnedLbl;
@property (weak, nonatomic) IBOutlet UILabel *remainingDaysLbl;
@property (weak, nonatomic) IBOutlet UILabel *infoLbl;
@property (weak, nonatomic) IBOutlet UILabel *campaignSummaryLbl;

@property (weak, nonatomic) IBOutlet UIImageView *mileageIcon;
@property (weak, nonatomic) IBOutlet UILabel *staticMileageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *pointsIcon;
@property (weak, nonatomic) IBOutlet UILabel *staticPointsLbl;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleIcon;
@property (weak, nonatomic) IBOutlet UILabel *staticRemainingTimeLbl;
@property (weak, nonatomic) IBOutlet UIButton *campaignSummaryBtn;

@property (weak, nonatomic) IBOutlet UIView *campaignSummaryBgView;
@property (weak, nonatomic) IBOutlet UIView *campaignInfoBgView;
@property (weak, nonatomic) IBOutlet UIView *durationBgVIew;
@property (weak, nonatomic) IBOutlet UIView *totalMileageBgView;
@property (weak, nonatomic) IBOutlet UIView *pointsBgView;
@property (weak, nonatomic) IBOutlet UIView *remainingDaysBgView;
@property (weak, nonatomic) IBOutlet UIView *campaignSummaryBtnBgView;

@property (weak, nonatomic) IBOutlet UIButton *campaignInfoBtn;
@property (weak, nonatomic) IBOutlet UILabel *waitingLbl;
- (void)displayData : (NSDictionary*)dataDict currentDate:(NSString *)currentDate;
@end
