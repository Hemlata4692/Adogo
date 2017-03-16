//
//  InstallationPopupViewController.h
//  Adogo
//
//  Created by Monika on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"
@protocol InstallationPopupDelegate <NSObject>
@optional
- (void)popupViewDelegateMethod:(int)option installationText:(NSString *)installationText installationType:(NSString *)installationType;
@end

@interface InstallationPopupViewController : UIViewController
{
    id <InstallationPopupDelegate> _delegate;
}
@property (nonatomic,strong) id <InstallationPopupDelegate>delegate;
@property (nonatomic, retain) NSString *bidId;
@property (nonatomic, retain) NSString *campaignId;
@property (nonatomic, assign) BOOL isDashboard;
@property (nonatomic, retain) DashboardViewController *dashboardViewObj;
@end
