//
//  DashboardViewController.h
//  Adogo
//
//  Created by Sumit on 28/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : AdogoViewController
@property(nonatomic, assign)BOOL isPopUpOpen;
@property(nonatomic, assign)BOOL isImagePickerPopUpOpen;
@property(nonatomic, retain) CLLocationManager *dashboardLocationManager;
@property(nonatomic, assign)BOOL isAskMorePhotoPopUpOpen;
@property(nonatomic, retain) NSString *dashboardTrackingLatitude;
@property(nonatomic, retain) NSString *dashboardTrackingLongitude;
@end