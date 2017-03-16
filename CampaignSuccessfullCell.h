//
//  CampaignSuccessfullCell.h
//  Adogo
//
//  Created by Sumit on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignSuccessfullCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *campaignNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *advertiserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *campaignImage;
@property (weak, nonatomic) IBOutlet UILabel *companyLbl;
@property (weak, nonatomic) IBOutlet UIButton *moreInfoBtn;
@property (weak, nonatomic) IBOutlet UILabel *timerLbl;
@property (weak, nonatomic) IBOutlet UIButton *setInstallationBtn;
@property (nonatomic,assign)long long hours;
@property (nonatomic,assign)long long minutes;
@property (nonatomic,assign)long long seconds;
@property(nonatomic,retain)NSTimer* campaignTimer;
- (void)displayData:(NSDictionary *)dataDict  currentTime:(NSString *)currentTime isPending:(BOOL)isPending;
@end
