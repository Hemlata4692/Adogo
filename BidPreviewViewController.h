//
//  BidPreviewViewController.h
//  Adogo
//
//  Created by Ranosys on 20/10/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BidInfoModel.h"

@interface BidPreviewViewController : UIViewController

@property(nonatomic,retain)BidInfoModel *previewData;
@property(nonatomic,retain)UIImage *previewSignatureImage;
@property(nonatomic,assign)BOOL isCampaignEnd;

@property(nonatomic,retain)NSString *campaignEndCampaignId;
@property(nonatomic,retain)NSString *campaignEndCarId;
@property(nonatomic,retain)NSString *campaignEndCampaignCarId;
@property(nonatomic,retain)NSString *selectRemoveMeasureTextFieldText;
@property(nonatomic,retain)NSString *selfRemovalContent;
@property(nonatomic,retain)NSMutableDictionary *campaignEndImageNames;
@property(nonatomic,retain)NSString *selfRemovalContentURl;
@end