//
//  InstalledStickerViewController.h
//  Adogo
//
//  Created by Ranosys on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"

@interface InstalledStickerViewController : UIViewController

@property (nonatomic, assign) NSString *campaignId;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, assign) NSString *campaignCarId;
@property(nonatomic,retain)NSString * scheduleId;
@property (nonatomic, assign) NSString *previousView;
@property(nonatomic,retain)NSString * notificationId;
@property(nonatomic, retain) DashboardViewController *dashboardObj;
@end
