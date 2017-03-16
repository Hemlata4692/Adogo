//
//  CarParkedViewController.h
//  Adogo
//
//  Created by Ranosys on 17/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DashboardViewController.h"

@interface CarParkedViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, assign) NSString *campaignId;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, assign) NSString *scheduleId;
@property (nonatomic, assign) NSString *carOwnerStatus;
@property (nonatomic, assign) NSString *noteFromAdmin;
@property(nonatomic, retain) DashboardViewController *dashboardObj;
@end
