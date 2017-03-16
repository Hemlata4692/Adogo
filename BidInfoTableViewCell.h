//
//  BidInfoTableViewCell.h
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BidInfoTableViewCell : UITableViewCell

//Campaign Cell
@property (strong, nonatomic) IBOutlet UIImageView *campaignLogo;
@property (strong, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) IBOutlet UIButton *bidTimeLeftBtn;
@property (strong, nonatomic) IBOutlet UILabel *campaignName;
@property (strong, nonatomic) IBOutlet UILabel *companyName;
@property (strong, nonatomic) IBOutlet UILabel *advertiserName;

- (void)setLayoutCampaign:(NSMutableDictionary *)data;
- (void)displayCampaignData:(NSMutableDictionary *)data;
//end

//Image Cell
@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;
//end

//Campaign Info Cell
@property (strong, nonatomic) IBOutlet UILabel *duration;
@property (strong, nonatomic) IBOutlet UILabel *maxBid;
@property (strong, nonatomic) IBOutlet UILabel *minMileage;
@property (strong, nonatomic) IBOutlet UILabel *requiredRoute;
@property (strong, nonatomic) IBOutlet UIView *currentAvgView;
@property (strong, nonatomic) IBOutlet UILabel *currentAvgBid;
@property (strong, nonatomic) IBOutlet UILabel *myBidLabel;
@property (strong, nonatomic) IBOutlet UILabel *myBidValue;

- (void)setLayoutCampaignInfo:(NSMutableDictionary *)data isBidExist:(BOOL)isBidExist;
- (void)displayCampaignInfoData:(NSMutableDictionary *)data isBidExist:(BOOL)isBidExist;
//end

//Button Cell
@property (strong, nonatomic) IBOutlet UIView *myBidView;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UITextField *myBidField;
@property (strong, nonatomic) IBOutlet UIButton *checkTermCondition;
@property (strong, nonatomic) IBOutlet UIButton *termsConditionBtn;
@property (strong, nonatomic) IBOutlet UIButton *signatureBtn;
@property (strong, nonatomic) IBOutlet UIButton *bidNowBtn;
@property (strong, nonatomic) IBOutlet UIButton *bidLaterBtn;
@property (strong, nonatomic) IBOutlet UIButton *chatBtn;
@property (strong, nonatomic) IBOutlet UIButton *notIntersetedBtn;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImage;

- (void)setLayoutCampaignButton;
- (void)displayCampaignButtonData:(NSMutableDictionary *)data;
//end
@end
