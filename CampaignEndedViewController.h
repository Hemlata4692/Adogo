//
//  CampaignEndedViewController.h
//  Adogo
//
//  Created by Hema on 18/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"
#import "BidInfoModel.h"

@interface CampaignEndedViewController : UIViewController

@property(nonatomic, retain)NSString *signatureImageName;
@property (nonatomic, assign) NSString *campaignId;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, assign) NSString *campaignCarId;
@property(nonatomic,retain)NSString * cmsContent;
@property(nonatomic,retain) NSMutableArray *carImagesArray;
@property(nonatomic,retain) NSMutableArray *resetData;
@property(nonatomic,assign)BOOL isUpdated;
@property(nonatomic,retain)NSString * signatureId;
@property(nonatomic,retain)NSString * isSignatureApproved;
@property(nonatomic, retain)DashboardViewController *dashboardObj;
@property (nonatomic, retain)UIImage *signatureImage;
@property(nonatomic, retain)BidInfoModel *campaignSubmitPreview;
@end
