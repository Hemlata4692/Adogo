//
//  CancelInstallationViewController.h
//  Adogo
//
//  Created by Hema on 18/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"

@interface CancelInstallationViewController : UIViewController

@property(nonatomic,retain)NSString * status;
@property(nonatomic,retain)NSString * scheduleId;
@property(nonatomic,retain)NSString * campaignId;
@property(nonatomic,retain)NSString * carId;
@property(nonatomic,retain)NSString * campaignCarId;
@property(nonatomic,retain)NSString * installationJobId;
@property(nonatomic,retain)NSString * plateNumber;
@property(nonatomic,retain)NSString * installerId;
@property(nonatomic, retain) DashboardViewController *dashboardObj;
@end
