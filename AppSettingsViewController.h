//
//  AppSettingsViewController.h
//  Adogo
//
//  Created by Monika on 24/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsViewController : AdogoViewController
@property(nonatomic,retain)NSString *uniqueTrackiBeaconValue;
- (void)setBeaconForTracking;
@property(nonatomic, assign)BOOL isProfileStatusScreen;
@property(nonatomic, assign)BOOL isBeaconCancel;
@end
