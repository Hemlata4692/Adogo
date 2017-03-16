//
//  CancelInstallationViewController.m
//  Adogo
//
//  Created by Hema on 18/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CancelInstallationViewController.h"
#import "CampaignService.h"

@interface CancelInstallationViewController ()
{
    int counter;
    NSTimer *installationTimer;
    int second, continousSecond;
}
@property (weak, nonatomic) IBOutlet UIView *cancelInstallationView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@end

@implementation CancelInstallationViewController
@synthesize cancelInstallationView,confirmBtn,timerLabel;
@synthesize status,scheduleId;
@synthesize campaignId;
@synthesize carId;
@synthesize campaignCarId;
@synthesize installationJobId;
@synthesize dashboardObj;
@synthesize plateNumber, installerId;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [cancelInstallationView setCornerRadius:3.0f];
     confirmBtn.enabled=NO;
    continousSecond = 5;   //time limit
    //start timer
    installationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(startTimer)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Set timer
- (void)startTimer {
    
    continousSecond--;
    second = continousSecond;
    timerLabel.text = [NSString stringWithFormat:@"%02d", second];
    if ([[NSString stringWithFormat:@"%02d", second] isEqualToString:@"00"]) {
        
        [installationTimer invalidate];
        installationTimer = nil;
        confirmBtn.enabled=YES;
        [confirmBtn setBackgroundImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)cancelViewButtonAction:(id)sender
{
     [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmButtonAction:(id)sender
{
    [myDelegate showIndicator];
    [self performSelector:@selector(cancelInstallationWebservice) withObject:nil afterDelay:.1];
}

#pragma maek - Webservice
- (void)cancelInstallationWebservice
{
    [[CampaignService sharedManager] acceptRejectInstallerRequest:scheduleId scheduleStatus:status campaignId:campaignId defaultCarId:carId campaignCarId:campaignCarId installationJobId:installationJobId installerId:installerId platNumber:plateNumber success :^(id responseObject)
     {
          [myDelegate stopIndicator];
         dashboardObj.isPopUpOpen = false;
         [dashboardObj viewWillAppear:YES];
         [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
     }
                                                          failure:^(NSError *error)
     {
         
     }];
}
#pragma mark - end
@end
