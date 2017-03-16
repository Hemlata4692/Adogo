//
//  DashboardViewController.m
//  Adogo
//
//  Created by Sumit on 28/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "DashboardViewController.h"
#import "RegistrationViewControllerStepTwo.h"
#import "CampaignService.h"
#import "UserDataCell.h"
#import "DefaultCarCell.h"
#import "BiddingCell.h"
#import "BiddingCollectionViewCell.h"
#import "CampaignSuccessfullCell.h"
#import "InstallerSummaryCell.h"
#import "BidInfoViewController.h"
#import "RejectTimingPopupViewController.h"
#import "CancelInstallationViewController.h"
#import "InstallationPopupViewController.h"
#import "CarParkedViewController.h"
#import "InstallationPopupViewController.h"
#import "OnsiteInstallationViewController.h"
#import "CarListiewController.h"
#import "CampaignEndedViewController.h"
#import "InstallationPopupViewController.h"
#import "OnsiteInstallationViewController.h"
#import "CampaignSummaryCell.h"
#import "InstalledStickerViewController.h"
#import "FbAmbassadorPostViewController.h"
#import "AmbassadorHistoryViewController.h"
#import "WorkshopInstallationViewController.h"
#import "ChatHistoryViewController.h"
#import "ProfileCompletionStatusViewController.h"
#import "MMMaterialDesignSpinner.h"
#import "CarDetailViewController.h"
#import "SCLAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "QuestionPopUpViewController.h"

#define kCellsPerRow 1

@interface DashboardViewController ()<InstallationPopupDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate, QuestionPopupViewDelegate> {
    
    NSMutableDictionary * dashboardDataDict;
    int currentIndex, oldIndex, rightLeft;
    CGPoint _lastContentOffset;
    bool isDragged;
    BOOL isDashboardService, isBackground;
    SCLAlertView *alertview;
    UIRefreshControl *refreshControl;
    int isAskForMorePhoto;
    bool isDynamicPopUpOpen;
    int dynamicPopUpCount;
    int dynamicPopUpOpenIndex; //Set index for dynamic popUp
}
@property (weak, nonatomic) IBOutlet UITableView *dashboardTableview;
@property (strong, nonatomic) IBOutlet CampaignSuccessfullCell *campaignCell;
@property (strong, nonatomic) IBOutlet InstallerSummaryCell *installerSummaryCell;
@property (strong, nonatomic) IBOutlet CampaignSummaryCell *campaignSummary;
@property (strong, nonatomic) IBOutlet UIButton *trackBtn;
@property (strong, nonatomic) IBOutlet UIImageView *trackImageView;
@property (strong, nonatomic) IBOutlet UIView *trackView;
@property (strong, nonatomic) IBOutlet UIButton *facebookBar;
@end

@implementation DashboardViewController
@synthesize dashboardTableview,campaignCell,installerSummaryCell,campaignSummary,isPopUpOpen,isImagePickerPopUpOpen, dashboardLocationManager;
@synthesize isAskMorePhotoPopUpOpen;
@synthesize dashboardTrackingLatitude, dashboardTrackingLongitude;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    myDelegate.methodName = @"viewDidLoad";
    [super viewDidLoad];
    self.title = @"Dashboard";
    [myDelegate awsConfugration];
    isPopUpOpen = false;
    rightLeft =1;
    _trackView.hidden  = NO;
    // Do any additional setup after loading the view.
    myDelegate.selScreenState = 0;
    currentIndex = 0;
    dashboardTableview.scrollEnabled = YES;
    [self addDashboardMenu];
    [self addFloatAction];
    [self frameCustomizationTableView:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callDashboardService) name:@"DashBoardScreen" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingChecker:) name:@"isTrack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingCheckerForBeacon:) name:@"isTrackBeacon" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsBluetoothOn:) name:@"isBluetoothOn" object:nil];
    
    refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 10, 10)];
    [dashboardTableview addSubview:refreshControl];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@""];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshControl addTarget:self action:@selector(refreshDashboardTable) forControlEvents:UIControlEventValueChanged];
     _facebookBar.hidden = YES;
}

- (void)addFloatAction {

    myDelegate.methodName = @"addFloatAction";
    _trackView.translatesAutoresizingMaskIntoConstraints = YES;
    _trackView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 93, [[UIScreen mainScreen] bounds].size.height - 93 - 64, 83 , 83);
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragOnButton:)];
    [_trackBtn addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkYourLocation:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkYourBackgroundLocation:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    isBackground=false;
    
   myDelegate.methodName = @"viewWillAppear";
    myDelegate.currentPresentViewName = @"DashboardView";
    //NSLog(@"------------------------------------------------??????????????apperar");
    if (!isImagePickerPopUpOpen) {
      
        isAskMorePhotoPopUpOpen=false;
        dashboardTrackingLatitude=@"";
        dashboardTrackingLongitude=@"";
        isDashboardService=false;
        
    if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Yes"]) {
        UIViewController * profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"CarListiewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: profileView]
                                             animated: NO];
        return;
    }//BonusJob
    else if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"BonusJob"]){
    [myDelegate.notificationDict setObject:@"other" forKey:@"isNotification"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objBonusJob = [storyboard instantiateViewControllerWithIdentifier:@"BonusJobViewController"];
        [self.navigationController pushViewController:objBonusJob animated:NO];
        
        return;
    }
    else if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"BidAssigned"])
    {
        [myDelegate.notificationDict setObject:@"other" forKey:@"isNotification"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BidInfoViewController *bidInfoViewObj =[storyboard instantiateViewControllerWithIdentifier:@"BidInfoViewController"];
    
        bidInfoViewObj.carId = [myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.car_id"];
        bidInfoViewObj.bidId = [myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.bid_id"];
        bidInfoViewObj.isBidExist = NO;
        [self.navigationController pushViewController:bidInfoViewObj animated:YES];
        return;
    }
    else if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"PaymentHistory"])
    {
        [myDelegate.notificationDict setObject:@"" forKey:@"isNotification"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"PaymentHistoryViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
        return;
    }
    else if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"RedemHistory"])
    {
        [myDelegate.notificationDict setObject:@"" forKey:@"isNotification"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"RedemptionViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
        return;
    }
    else if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Nric"])
    {
        [myDelegate.notificationDict setObject:@"" forKey:@"isNotification"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"DriverProfileViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
        return;
    }
    
    if (!isPopUpOpen) {
         _facebookBar.hidden = YES;
        isPopUpOpen = true;
        if ([UserDefaultManager getValue:@"isTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"false"])
        {
            _trackBtn.selected = NO;
            [_trackImageView stopAnimating];
            _trackImageView.image = [UIImage imageNamed:@"track"];
        }
        else
        {
            _trackBtn.selected = YES;
            _trackImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"tracking1"],
                                               [UIImage imageNamed:@"tracking2"],
                                               [UIImage imageNamed:@"tracking3"], nil];
            _trackImageView.animationDuration = 1.0f;
            _trackImageView.animationRepeatCount = 0;
            [_trackImageView startAnimating];
        }
        
        if (![[UserDefaultManager getValue:@"isDriverProfileCompleted"] isEqualToString:@"True"])
        {
            isPopUpOpen = false;
            [UserDefaultManager removeValue:@"isPinVerification"];
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RegistrationViewControllerStepTwo *completeProfileView =[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewStepTwo"];
            completeProfileView.isDashboard = YES;
            [self.navigationController pushViewController:completeProfileView animated:NO];
        }
        else
        {
            //NSLog(@"MyAdogo log--------5");
            isDashboardService=true;
            dashboardLocationManager = [[CLLocationManager alloc] init];
            // Set the delegate
            dashboardLocationManager.delegate = self;
            //--------Remove blue line during background location update-------
            if ([dashboardLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                
                [dashboardLocationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
            }
            //--------end
            dashboardLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            dashboardLocationManager.distanceFilter = kCLDistanceFilterNone;
            [dashboardLocationManager startUpdatingLocation];
        }
    }
    }
}

- (void) checkYourLocation:(NSNotification *) note {
    
    isBackground=false;
    if (isAskMorePhotoPopUpOpen) {
    
        isDashboardService=true;
        dashboardLocationManager = [[CLLocationManager alloc] init];
        // Set the delegate
        dashboardLocationManager.delegate = self;
        //--------Remove blue line during background location update-------
        if ([dashboardLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [dashboardLocationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
        }
        //--------end
        dashboardLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        dashboardLocationManager.distanceFilter = kCLDistanceFilterNone;
        [dashboardLocationManager startUpdatingLocation];
    }
}

- (void) checkYourBackgroundLocation:(NSNotification *)note {
    
    isBackground=true;
    if (alertview.view.tag==102) {
        
        [alertview removeBackgroundView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    myDelegate.methodName = @"viewDisappear";
    myDelegate.currentPresentViewName = @"Other";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)callDashboardService {
    
    myDelegate.methodName = @"callDashBoardService";
    //NSLog(@"MyAdogoNotification log--------6");
    if (!myDelegate.isGetNotification) {
        myDelegate.isGetNotification=YES;
        //NSLog(@"MyAdogo log--------6");
        [myDelegate showIndicator];
        [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
    }
}

- (void)refreshDashboardTable {
    
    [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.0];
}
#pragma mark - end

#pragma mark - Table view customization
- (void)frameCustomizationTableView:(BOOL)isAmbassaderPostBar  {

    myDelegate.methodName = @"frameCustomizationTableView";
    _facebookBar.translatesAutoresizingMaskIntoConstraints = YES;
    dashboardTableview.translatesAutoresizingMaskIntoConstraints = YES;
    if (!isAmbassaderPostBar) {
        dashboardTableview.frame = CGRectMake(0, 50, [[UIScreen mainScreen] bounds].size.width, self.view.bounds.size.height - 54);
    }
    else {
    
        dashboardTableview.frame = CGRectMake(0, 50, [[UIScreen mainScreen] bounds].size.width, self.view.bounds.size.height - 50 - 44);    //height = self.view height + 50(top tapbar height) + 44(Ambassador post bottom bar)
    }
    _facebookBar.frame = CGRectMake(0, self.view.bounds.size.height - 44, [[UIScreen mainScreen] bounds].size.width, 44);
}
#pragma mark - end

#pragma mark - Webservice method
- (void)setInstallationLocation:(NSString *)content
{
    myDelegate.methodName = @"setInstallationLocation";
    [[CampaignService sharedManager] setInstallationService:[[dashboardDataDict objectForKey:@"bidsuccessful"]  objectForKey:@"bid_id"] carId:[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"] InstallationType:@"workshop" InstallationNote:myDelegate.popupText amLocation:@"" amPostalCode:@"" amLat:@"" amLng:@"" pmLocation:@"" pmPostalCode:@"" pmLat:@"" pmLng:@"" success:^(id responseObject)
     {
         SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
         [alert addButton:@"OK" actionBlock:^(void) {
             UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             WorkshopInstallationViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"WorkshopInstallationViewController"];
             nextView.numberStr = [dashboardDataDict objectForKey:@"adogo_phone_number"];
             //NSLog(@"%@",content);
             nextView.installationString=content;
             [self.navigationController pushViewController:nextView animated:YES];
             
         }];
         [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
     }
                                                    failure:^(NSError *error) {
                                                    }];
}

- (void)getDashboardData
{
    isDashboardService=false;
    isAskForMorePhoto=0;
    myDelegate.methodName = @"getDashboardData";
    [[CampaignService sharedManager] getDashboardDetail:(NSString *)dashboardTrackingLongitude dashboardLatitude:(NSString *)dashboardTrackingLatitude onSuccess:^(id responseObject)
     {
         isDynamicPopUpOpen=false;
         dynamicPopUpCount=0;
         dynamicPopUpOpenIndex=0;
         
         [UserDefaultManager setValue:@"false" key:@"isCampaignRunning"];
         currentIndex=0;
         for (MMMaterialDesignSpinner *subView1 in [myDelegate.window subviews]) {
             if ([subView1 isKindOfClass:[MMMaterialDesignSpinner class]]) {
                 //NSLog(@"MyAdogo log--------1");
//                 [subView1 removeFromSuperview];
             }
         }
         [myDelegate stopIndicator];
          [self frameCustomizationTableView:NO];
         _facebookBar.hidden = YES;
         dashboardDataDict = [responseObject mutableCopy];
         //NSLog(@"responseObject is %@",responseObject);
         //Set value for app setting
         
         [UserDefaultManager setValue:[responseObject objectForKey:@"defaultcarinfo"] key:@"carInfo"];
         [UserDefaultManager setValue:[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"] key:@"defaultCarPlatNumber"];
         [UserDefaultManager setValue:[[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaigns_name"] key:@"campaignName"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"daily_milage_report"] key:@"isDailyMilageReportOn"];
         [UserDefaultManager setValue:[responseObject  objectForKey:@"daily_mileage_note"] key:@"dailMilageReportNote"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"is_notification_on"] key:@"isNotificationOn"];
         [UserDefaultManager setValue:[responseObject  objectForKey:@"notification_note"] key:@"notificationNote"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"tracking_method"] key:@"trackingMethod"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"ibeacon_id"] key:@"iBeaconSerialNumber"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"gps_device_id"] key:@"gpsIMEINumber"];
         [UserDefaultManager setValue:[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"] key:@"defaultCarId"];
         [UserDefaultManager setValue:[dashboardDataDict objectForKey:@"bidding_banner"] key:@"bidBanner"];
         [UserDefaultManager setValue:[responseObject objectForKey:@"stand_by_message"] key:@"stand_by_message"];
         
         if (nil!=[responseObject objectForKey:@"track_sync_duration"]&&![[responseObject objectForKey:@"track_sync_duration"] isEqualToString:@""]&&([[responseObject objectForKey:@"track_sync_duration"] intValue]>0)&&([[responseObject objectForKey:@"track_sync_duration"] intValue]<=60)) {
             
             myDelegate.locationUpdateTimeDifference=[[responseObject objectForKey:@"track_sync_duration"] intValue];
         }
         
         if (nil!=[responseObject objectForKey:@"enable_track_log_email"]&&![[responseObject objectForKey:@"enable_track_log_email"] isEqualToString:@""]&&([[responseObject objectForKey:@"enable_track_log_email"] intValue]==1)) {
             
             myDelegate.isEnableTrackLogEmail=1;
         }

         
         myDelegate.methodName = @"getDashboardData line: 284";
         if ([[UserDefaultManager getValue:@"isDailyMilageReportOn"] isEqualToString:@""])
         {
             [UserDefaultManager setValue:@"1" key:@"isDailyMilageReportOn"];
             [UserDefaultManager setValue:@"1" key:@"isNotificationOn"];
         }
         
         //end
         //start iBeacon if tracking mode is neacon
         if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Ibeacon"])
         {
             myDelegate.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
             myDelegate.startEndStr = @"1";
             if ([[dashboardDataDict objectForKey:@"currentStateStatus"]intValue]==5)
             {
                 myDelegate.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
                 myDelegate.campaignCarId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
                 
             }
             myDelegate.beaconName = [UserDefaultManager getValue:@"iBeaconSerialNumber"];
             [myDelegate startRangeBeacons];
             
         }
         else if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Gps"])
         {
             _trackBtn.selected = NO;
             [_trackImageView stopAnimating];
             _trackImageView.image = [UIImage imageNamed:@"track"];
             [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
             [myDelegate stopRangeBeacons];
             myDelegate.startEndStr = @"3";
             [myDelegate stopTrack];
         }
         else {
         
             [myDelegate stopRangeBeacons];
         }
         //end
         [UserDefaultManager setValue:[[dashboardDataDict objectForKey:@"userdata"] objectForKey:@"profile_status"] key:@"profileStatus"];
         
         if ([[responseObject objectForKey:@"ambassador_posts"] count] == 0) {
             
             [dashboardTableview reloadData];
         }
         else {
             
              [self frameCustomizationTableView:YES];
             _facebookBar.hidden = NO;
             isPopUpOpen = false;
             if (myDelegate.facebookCount == 0) {
                 myDelegate.facebookCount = 1;
                 isDynamicPopUpOpen=true;
                 if ([[responseObject objectForKey:@"ambassador_posts"] count] == 1) {
                     
                     myDelegate.methodName = @"getDashboardData line: 334";
                     FbAmbassadorPostViewController *fbAmbassadorPostObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FbAmbassadorPostViewController"];
                     fbAmbassadorPostObj.ambassadorId = [[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"id"];
                     fbAmbassadorPostObj.seconds = [[UserDefaultManager formateDate:[[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"duration"]] timeIntervalSinceDate:[UserDefaultManager formateDate:[responseObject objectForKey:@"currentServerTime"]]] + 59;
                     
                     fbAmbassadorPostObj.startDateTime = [responseObject objectForKey:@"currentServerTime"];
                     fbAmbassadorPostObj.endDateTime = [[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"duration"];
                     fbAmbassadorPostObj.numberOfPost = 1;
                     fbAmbassadorPostObj.content = [[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"post_content"];
                     fbAmbassadorPostObj.imageUrl = [[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"post_image"];
                     fbAmbassadorPostObj.shareTitleText = [[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"title"];
                     fbAmbassadorPostObj.sharedUrl=[[[responseObject objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"post_url"];
                     fbAmbassadorPostObj.previousScreen = 1;
                     [self.navigationController pushViewController:fbAmbassadorPostObj animated:YES];
                 }
                 else {
                     
                     AmbassadorHistoryViewController *fbAmbassadorPostHistoryObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AmbassadorHistoryViewController"];
                     fbAmbassadorPostHistoryObj.isDashBoard = YES;
                     [self.navigationController pushViewController:fbAmbassadorPostHistoryObj animated:YES];
                 }
             }
             else {
                 
                 [dashboardTableview reloadData];
             }
         }
         [refreshControl endRefreshing];
         
         if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"AskForMorePics"]) {
         
             [self navigateToAskForMorePhoto];
         }
         else {
             if ([responseObject objectForKey:@"campaignsummary"]!=nil) {
                 isAskForMorePhoto=[[[responseObject objectForKey:@"campaignsummary"] objectForKey:@"photos_asked"] intValue];
                 
                 if ((isAskForMorePhoto==1)&&([[UserDefaultManager getValue:@"isCampaignRunning"] isEqualToString:@"true"])) {
                     
                     isDynamicPopUpOpen=true;
                     isImagePickerPopUpOpen=true;
                     isAskMorePhotoPopUpOpen=true;
                     isDashboardService=true;
                     dashboardLocationManager = [[CLLocationManager alloc] init];
                     // Set the delegate
                     dashboardLocationManager.delegate = self;
                     //--------Remove blue line during background location update-------
                     if ([dashboardLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                         
                         [dashboardLocationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
                     }
                     //--------end
                     dashboardLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                     dashboardLocationManager.distanceFilter = kCLDistanceFilterNone;
                     [dashboardLocationManager startUpdatingLocation];
                     
                     
                     UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                     InstalledStickerViewController *objAddMorePics =[storyboard instantiateViewControllerWithIdentifier:@"InstalledStickerViewController"];
                     objAddMorePics.carId =[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
                     objAddMorePics.campaignCarId =[[responseObject objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
                     objAddMorePics.campaignId =[[responseObject objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
                     objAddMorePics.dashboardObj=self;
                     objAddMorePics.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
                     [objAddMorePics setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                     [myDelegate.notificationDict setObject:@"other" forKey:@"isNotification"];
                     [self presentViewController:objAddMorePics animated: YES completion:nil];
                     return;
                 }
             }
         }
         
         if (!isDynamicPopUpOpen) {
             
             if ([[responseObject objectForKey:@"user_ananswered_questions"] count]!=0) {
                 
                 dynamicPopUpCount=(int)[[dashboardDataDict objectForKey:@"user_ananswered_questions"] count];
                 [self openQuestionPopUpView];
             }
             else {
                 //If answered all questions remove all id's if exist
                 [UserDefaultManager removeAllPlistValueForSelectedUser];
             }
         }
     }
    failure:^(NSError *error)
     {
         [refreshControl endRefreshing];
         //Set default value for app setting
         [UserDefaultManager setValue:@"1" key:@"isDailyMilageReportOn"];
         [UserDefaultManager setValue:@"" key:@"dailMilageReportNote"];
         [UserDefaultManager setValue:@"1" key:@"isNotificationOn"];
         [UserDefaultManager setValue:@"" key:@"notificationNote"];
         [UserDefaultManager setValue:@"Phone" key:@"trackingMethod"];
         [UserDefaultManager setValue:@"" key:@"iBeaconSerialNumber"];
         [UserDefaultManager setValue:@"" key:@"gpsIMEINumber"];

         //end
     }];
}

- (void)openQuestionPopUpView {

    if (![UserDefaultManager isExistPlistValue:[NSString stringWithFormat:@"%@_%@",[UserDefaultManager getValue:@"userId"],[[[dashboardDataDict objectForKey:@"user_ananswered_questions"] objectAtIndex:dynamicPopUpOpenIndex] objectForKey:@"id"]]]) {        //If id is not exist in local database/plist file
        
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QuestionPopUpViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"QuestionPopUpViewController"];
        popupView.popUpIdValue = [[[dashboardDataDict objectForKey:@"user_ananswered_questions"] objectAtIndex:dynamicPopUpOpenIndex] objectForKey:@"id"];
        popupView.delegate=self;
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popupView animated: YES completion:nil];
    }
    else {
        
        if (![[UserDefaultManager getPlistValue:[NSString stringWithFormat:@"%@_%@",[UserDefaultManager getValue:@"userId"],[[[dashboardDataDict objectForKey:@"user_ananswered_questions"] objectAtIndex:dynamicPopUpOpenIndex] objectForKey:@"id"]]] isEqualToString:[[[dashboardDataDict objectForKey:@"currentServerTime"] componentsSeparatedByString:@" "] objectAtIndex:0]]) {   //If id is exist in local database/plist file but date is different
            
            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionPopUpViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"QuestionPopUpViewController"];
            popupView.popUpIdValue = [[[dashboardDataDict objectForKey:@"user_ananswered_questions"] objectAtIndex:dynamicPopUpOpenIndex] objectForKey:@"id"];
            popupView.delegate=self;
            popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
            [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            [self presentViewController:popupView animated: YES completion:nil];
        }
        else {
            
            //If id is exist in local database/plist file and date same then don't show popUp
            dynamicPopUpOpenIndex=dynamicPopUpOpenIndex+1;
            if (dynamicPopUpOpenIndex<dynamicPopUpCount) {
               
                [self openQuestionPopUpView];
            }
        }
    }
}

- (void)navigateToAskForMorePhoto {

    if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"AskForMorePics"])
    {
        
     
//        if ([UserDefaultManager getValue:@"NotificationAPSData"]!=nil) {
//            [myDelegate.notificationDict setObject:[UserDefaultManager getValue:@"NotificationAPSData"] forKey:@"NotificationAPSData"];
//        }
        isImagePickerPopUpOpen=true;
        NSString *str = [[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"alert"];
        
        NSRange range1 = [str rangeOfString:@"your car "];
        NSRange range2 = [str rangeOfString:@" for "];
        NSRange rangeToSubString = NSMakeRange(range1.location + range1.length, range2.location - range1.location - range1.length);
        
        NSString *resultStr = [str substringWithRange:rangeToSubString];
        
        //NSLog(@"path1 : %@",resultStr);
        if ((nil!=[UserDefaultManager getValue:@"defaultCarId"])&&([[UserDefaultManager getValue:@"defaultCarId"] intValue] != [[myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.car_id"] intValue])) {

            [myDelegate.notificationDict setObject:@"Other" forKey:@"isNotification"];
            [UserDefaultManager showAlertMessage:[NSString stringWithFormat:@"Change your default car to %@ for uploading more photos.",resultStr]];\
        }
        else if (![[UserDefaultManager getValue:@"isCampaignRunning"] isEqualToString:@"true"]) {
            
            [myDelegate.notificationDict setObject:@"Other" forKey:@"isNotification"];
            [UserDefaultManager showAlertMessage:@"Either campaign is not running or car is not ready to run in this campaign."];
        }
        else {

        isDynamicPopUpOpen=true;
//        dashboardTrackingLongitude=@"";
//        dashboardTrackingLatitude=@"";
        isAskMorePhotoPopUpOpen=true;
        isDashboardService=true;
        dashboardLocationManager = [[CLLocationManager alloc] init];
        // Set the delegate
        dashboardLocationManager.delegate = self;
        //--------Remove blue line during background location update-------
        if ([dashboardLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [dashboardLocationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
        }
        //--------end
        dashboardLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        dashboardLocationManager.distanceFilter = kCLDistanceFilterNone;
        [dashboardLocationManager startUpdatingLocation];
        
        
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            InstalledStickerViewController *objAddMorePics =[storyboard instantiateViewControllerWithIdentifier:@"InstalledStickerViewController"];
            objAddMorePics.carId =[myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.car_id"];
            objAddMorePics.campaignCarId =[myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.campaign_car_id"];
            objAddMorePics.campaignId =[myDelegate.notificationDict valueForKeyPath:@"NotificationAPSData.extra_params.campaign_id"];
            //        objAddMorePics.carId =@"315";
            //        objAddMorePics.campaignCarId =@"22";
            //        objAddMorePics.campaignId =@"10";
            objAddMorePics.dashboardObj=self;
            objAddMorePics.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
            [objAddMorePics setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            [myDelegate.notificationDict setObject:@"Other" forKey:@"isNotification"];
            [self presentViewController:objAddMorePics animated: YES completion:nil];
            return;
        }
    }
}

- (void)confirmInstallserRequest :(NSString *)status
{
    myDelegate.methodName = @"confirmInstallserRequest";
    [[CampaignService sharedManager] acceptRejectInstallerRequest:[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_schedule_id"] scheduleStatus:status campaignId:[[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"] defaultCarId:[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"] campaignCarId:[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"campaign_car_id"] installationJobId:[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_id"] installerId:[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installer_user_id"] platNumber:[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"] success :^(id responseObject)
     {
        [self getDashboardData];
     }
                                                          failure:^(NSError *error)
     {
         
     }];
    
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    myDelegate.methodName = @"numberOfSectionsInTableView";
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dashboardDataDict==nil)
    {
        return  0;
    }
    else
    {
        myDelegate.methodName = @"numberOfRowsInSection";
        if (section==0)
        {
            return 1;
        }
        else if (section==1)
        {
            return 1;
        }
        else
        {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        UserDataCell *cell ;
        NSString *simpleTableIdentifier = @"UserDataCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[UserDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        myDelegate.methodName = @"cellForRowAtIndexPath line: 432";
        [cell displayData:[dashboardDataDict objectForKey:@"userdata"]];
        return cell;
    }
    else if(indexPath.section == 1)
    {
        DefaultCarCell *cell ;
        NSString *simpleTableIdentifier = @"DefaultCarCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[DefaultCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        myDelegate.methodName = @"cellForRowAtIndexPath line: 445";
        [cell displayData:[dashboardDataDict objectForKey:@"defaultcarinfo"]];
        return cell;
    }
    else
    {
        int status = [[dashboardDataDict objectForKey:@"currentStateStatus"]intValue];
//        status =5;
        switch (status)
        {
            case 1:
            case 100:
            case 2:
            case 0:
            {
                BiddingCell *cell ;
                NSString *simpleTableIdentifier = @"BiddingCell";
                cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if (cell == nil)
                {
                    cell = [[BiddingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
                }
                myDelegate.methodName = @"cellForRowAtIndexPath line: 467";
                [cell displayData:[dashboardDataDict objectForKey:@"currentStateStatus"]];
                //setting collection view cell size according to iPhone screens
                UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)cell.collectionView.collectionViewLayout;
                CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow -1);
                CGFloat cellWidth = (availableWidthForCells / kCellsPerRow);
                flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
                //end
                [cell.collectionView reloadData];
                return cell;
                break;
            }
            case 3:
            {
                NSString *simpleTableIdentifier = @"CampaignSuccessfullCell";
                campaignCell=(CampaignSuccessfullCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if(campaignCell==nil)
                {
                    [[NSBundle mainBundle] loadNibNamed:@"CampaignSuccessfullCell" owner:self options:nil] ;
                }
                [campaignCell.moreInfoBtn addTarget:self action:@selector(getMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
                [campaignCell.setInstallationBtn addTarget:self action:@selector(setInstallation:) forControlEvents:UIControlEventTouchUpInside];
                myDelegate.methodName = @"cellForRowAtIndexPath line: 489";
                [campaignCell displayData:[dashboardDataDict objectForKey:@"bidsuccessful"]  currentTime:[dashboardDataDict objectForKey:@"currentServerTime"] isPending:([[[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"installation_type"] isEqualToString:@"Pending"]?YES:NO)];
                
                return campaignCell;
                break;
            }
            case 4:
            {
                NSString *simpleTableIdentifier = @"InstallerSummaryCell";
                installerSummaryCell=(InstallerSummaryCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if(installerSummaryCell==nil)
                {
                    [[NSBundle mainBundle] loadNibNamed:@"InstallerSummaryCell" owner:self options:nil];
                }
                [installerSummaryCell.refreshBtn addTarget:self action:@selector(refreshBtnclicked:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.confirmTimeBtn addTarget:self action:@selector(confirmTimeing:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.rejectTimeBtn addTarget:self action:@selector(rejectTimeing:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.callAdogoBtn addTarget:self action:@selector(callAdogoAction:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.callBtn addTarget:self action:@selector(callInstallerAction:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.chatAdogoBtn addTarget:self action:@selector(chatAdogoAction:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.uploadStickerBtn addTarget:self action:@selector(uploadStickerAction:) forControlEvents:UIControlEventTouchUpInside];
                [installerSummaryCell.dashboardAshButton addTarget:self action:@selector(askButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                myDelegate.methodName = @"cellForRowAtIndexPath line: 510";
                [installerSummaryCell displayData:[dashboardDataDict objectForKey:@"installationSummary"]];
                myDelegate.methodName = @"cellForRowAtIndexPath line: 512";
                return installerSummaryCell;
                break;
            }
            case 5:
            {
                NSString *simpleTableIdentifier = @"CampaignSummaryCell";
                campaignSummary=(CampaignSummaryCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if(campaignSummary==nil)
                {
                    [[NSBundle mainBundle] loadNibNamed:@"CampaignSummaryCell" owner:self options:nil];
                }
                [campaignSummary.campaignSummaryBtn addTarget:self action:@selector(campaignSummaryProcedures:) forControlEvents:UIControlEventTouchUpInside];
                [campaignSummary.campaignInfoBtn addTarget:self action:@selector(campaignInfoMethod:) forControlEvents:UIControlEventTouchUpInside];
                myDelegate.methodName = @"cellForRowAtIndexPath line: 525";
                [campaignSummary displayData:[dashboardDataDict objectForKey:@"campaignsummary"] currentDate:[dashboardDataDict objectForKey:@"currentServerTime"]];
                return campaignSummary;
                break;
            }
            default:
            {
                UITableViewCell *cell;
                return cell;
                break;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    myDelegate.methodName = @"heightForRowAtIndexPath line: 542";
    if (indexPath.section==0)
    {
        return 120.0;
    }
    else if (indexPath.section==1)
    {
        if ([[dashboardDataDict objectForKey:@"defaultcarinfo"] isEqual:@""]) {
            return 230.0;
        }
        else
        {
            return 200.0;
        }
    }
    else
    {
        int status = [[dashboardDataDict objectForKey:@"currentStateStatus"]intValue];
        switch (status)
        {
            case 1:
                if([[UIScreen mainScreen] bounds].size.height<568)
                {
                    
                    dashboardTableview.scrollEnabled = YES;
                }
                else if (!([[UserDefaultManager getValue:@"bidBanner"] isEqualToString:@""]||[UserDefaultManager getValue:@"bidBanner"]==nil || [UserDefaultManager getValue:@"bidBanner"]==NULL)){
                    
                    dashboardTableview.scrollEnabled = YES;
                }
                else
                {
                    dashboardTableview.scrollEnabled = NO;
                }
                return 150.0;
            case 2:
                dashboardTableview.scrollEnabled = YES;
                return 360.0;
            case 3:
                dashboardTableview.scrollEnabled = YES;
//                return 280.0;
                return 345.0;
            case 4:
                if([[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"job_status"] isEqualToString:@""]||[[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"job_status"] isEqualToString:@"waiting"])
                {
                  return 155.0;
                }
                else
                {
                   return 275.0;
                }
                
            case 5:
            {
                if ([UserDefaultManager dateComparision:[dashboardDataDict objectForKey:@"currentServerTime"] endDate:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"end_date"] startTime:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"start_date"]]==1)
                {
                    return 200.0;
                }
                else
                {
//                    return 345.0;
                    return 414.0;
                }
            }
            default:
                return 150.0;
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        
        ProfileCompletionStatusViewController * profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileCompletionStatusViewController"];
        profileView.shouldShowBackButton = YES;
        [self.navigationController pushViewController:profileView animated:YES];
    }
    else if (indexPath.section==1 && ([[dashboardDataDict objectForKey:@"defaultcarinfo"] count]<1)){
        
        UIViewController * carListView = [self.storyboard instantiateViewControllerWithIdentifier:@"CarListiewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: carListView]
                                             animated: NO];
    }
    else if (indexPath.section==1 && (![[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"is_measurement_approved"]boolValue])){
        
        CarDetailViewController * carDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"CarDetailViewController"];
        carDetail.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        [self.navigationController pushViewController:carDetail animated:YES];
    }
    
    
}
#pragma mark - end

#pragma mark - Tableview button actions
- (void)campaignMoreInfoBtnClicked:(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BidInfoViewController *bidInfoViewObj =[storyboard instantiateViewControllerWithIdentifier:@"BidInfoViewController"];
    bidInfoViewObj.bidId = [[dashboardDataDict objectForKey:@"bidsuccessful"]  objectForKey:@"bid_id"];
    bidInfoViewObj.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
    bidInfoViewObj.isBidExist = YES;
    [self.navigationController pushViewController:bidInfoViewObj animated:NO];
}

//Installer summary action
- (void)refreshBtnclicked :(id)sender
{
    //NSLog(@"MyAdogo log--------2");
    [myDelegate showIndicator];
    [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
}

- (void)callInstallerAction:(id)sender
{
    NSArray * mobNoArray  = [[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"phone_number"] componentsSeparatedByString:@"+"];
    //NSLog(@"no is %@",[[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"phone_number"]);
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[mobNoArray objectAtIndex:1]]]];
    
}

- (void)confirmTimeing :(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"Confirm Timing"])
    {
        //NSLog(@"MyAdogo log--------3");
        [myDelegate showIndicator];
        [self performSelector:@selector(confirmInstallserRequest:) withObject:@"accepted" afterDelay:.1];
    }
    else
    {
//        note_from_admin
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CarParkedViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"CarParkedViewController"];
        popupView.carOwnerStatus = @"parked";
        popupView.dashboardObj = self;
        isPopUpOpen = true;
        popupView.scheduleId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_schedule_id"];
        popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        popupView.campaignId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"];
        popupView.noteFromAdmin = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"note_from_admin"];
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popupView animated:YES completion:nil];
    }
}

- (void)rejectTimeing :(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"Reject Timing"])
    {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RejectTimingPopupViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"RejectTimingPopupViewController"];
        popupView.status = @"rejected";
        popupView.dashboardObj = self;
        popupView.campaignId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"];
        popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        popupView.scheduleId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_schedule_id"];
        popupView.campaignCarId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"campaign_car_id"];
        popupView.installationJobId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_id"];
        popupView.installerId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installer_user_id"];
        popupView.plateNumber = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"];
        
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popupView animated: YES completion:nil];
        
    }
    else
    {
        //CancelInstallationViewController
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CancelInstallationViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"CancelInstallationViewController"];
        popupView.status = @"rejected";
        popupView.dashboardObj = self;
        popupView.campaignId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"];
        popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        popupView.scheduleId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_schedule_id"];
        popupView.campaignCarId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"campaign_car_id"];
        popupView.installationJobId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_id"];
        popupView.installerId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installer_user_id"];
        popupView.plateNumber = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"];
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popupView animated: YES completion:nil];
    }
}

- (void)callAdogoAction:(id)sender
{
    NSArray * mobNoArray  = [[dashboardDataDict objectForKey:@"adogo_phone_number"] componentsSeparatedByString:@"+"];
    //NSLog(@"no is %@",[dashboardDataDict objectForKey:@"adogo_phone_number"]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[mobNoArray objectAtIndex:1]]]];
}

- (void)chatAdogoAction:(id)sender {
    
    [[ZDCChat instance].api trackEvent:@"Chat button pressed: (pre-set data)"];
    
    // before starting the chat set the visitor data
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        
        visitor.phone = [UserDefaultManager getValue:@"mobileNumber"];
        visitor.name = [UserDefaultManager getValue:@"emailId"];
        visitor.email = [UserDefaultManager getValue:@"emailId"];
    }];
    
    [ZDCChat startChatIn:[UIApplication sharedApplication].keyWindow.rootViewController.navigationController withConfig:^(ZDCConfig *config) {
        
        config.preChatDataRequirements.name = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.email = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
        config.tags = @[@"iPhoneChat"];
    }];
}

- (void)uploadStickerAction:(id)sender
{
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InstalledStickerViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"InstalledStickerViewController"];
    popupView.previousView = @"InstalledStikers";
    popupView.scheduleId = [[dashboardDataDict objectForKey:@"installationSummary"] objectForKey:@"installation_job_schedule_id"];
    popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
    popupView.campaignId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"];
   
    popupView.dashboardObj = self;
     popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
    isPopUpOpen = true;
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:popupView animated:YES completion:nil];
}

- (void)askButtonAction:(id)sender
{
    [UserDefaultManager showAlertMessage:@"Please indicate that you have parked your car so that the installer can make his way to you.\n\nEmergency Cancel is used when you have parked your car and installer is on his way down and you need to cancel for emergency reasons. Please do not misuse. Thank you"];
}
//end

//Horizontal bid listing action
- (void)moreInfoBtnClicked:(id)sender {
    
    isPopUpOpen=false;
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BidInfoViewController *bidInfoViewObj =[storyboard instantiateViewControllerWithIdentifier:@"BidInfoViewController"];
    bidInfoViewObj.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
    bidInfoViewObj.bidId = [[[dashboardDataDict objectForKey:@"bidding"] objectAtIndex:currentIndex] objectForKey:@"bid_id"];
    bidInfoViewObj.isBidExist = NO;
    
    NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:0 inSection:2];
    BiddingCell *Bidcell  =(BiddingCell *)[dashboardTableview cellForRowAtIndexPath:cellIndex];
    [Bidcell.collectionView reloadData];
    [self.navigationController pushViewController:bidInfoViewObj animated:NO];
}

- (void)nextBtnClicked:(id)sender
{

    [self swipeToImageLeft];
}

- (void)previourBtnClicked:(id)sender
{

    [self swipeToImageRight];
}
//end

//Campaign successfully bid
- (void)setInstallation :(id)sender
{
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InstallationPopupViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"InstallationPopupViewController"];
    popupView.delegate = self;
    popupView.bidId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"bid_id"];
    popupView.campaignId=[[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"campaignsId"];
    popupView.isDashboard=true;
    popupView.dashboardViewObj=self;
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    [self presentViewController:popupView animated: YES completion:nil];
    
}
- (void)getMoreInfo:(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BidInfoViewController *bidInfoViewObj =[storyboard instantiateViewControllerWithIdentifier:@"BidInfoViewController"];
    bidInfoViewObj.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
    bidInfoViewObj.bidId = [[dashboardDataDict objectForKey:@"bidsuccessful"] objectForKey:@"bid_id"];
    bidInfoViewObj.isBidExist = YES;
    [self.navigationController pushViewController:bidInfoViewObj animated:NO];
}
//end

-(IBAction)facebookBarAction:(id)sender
{
    isPopUpOpen = false;
    if ([[dashboardDataDict objectForKey:@"ambassador_posts"] count] == 1) {
        
        myDelegate.facebookCount = 1;
        FbAmbassadorPostViewController *fbAmbassadorPostObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FbAmbassadorPostViewController"];
        fbAmbassadorPostObj.ambassadorId = [[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"id"];
        fbAmbassadorPostObj.seconds = [[UserDefaultManager formateDate:[[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"duration"]] timeIntervalSinceDate:[UserDefaultManager formateDate:[dashboardDataDict objectForKey:@"currentServerTime"]]] + 59;
        
        fbAmbassadorPostObj.startDateTime = [dashboardDataDict objectForKey:@"currentServerTime"];
        fbAmbassadorPostObj.endDateTime = [[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"duration"];
        fbAmbassadorPostObj.numberOfPost = 1;
        fbAmbassadorPostObj.content = [[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"post_content"];
        fbAmbassadorPostObj.imageUrl = [[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"post_image"];
        fbAmbassadorPostObj.shareTitleText = [[[dashboardDataDict objectForKey:@"ambassador_posts"] objectAtIndex:0] objectForKey:@"title"];
        fbAmbassadorPostObj.previousScreen = 1;
        [self.navigationController pushViewController:fbAmbassadorPostObj animated:YES];
    }
    else {
        
        AmbassadorHistoryViewController *fbAmbassadorPostHistoryObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AmbassadorHistoryViewController"];
        fbAmbassadorPostHistoryObj.isDashBoard = YES;
        [self.navigationController pushViewController:fbAmbassadorPostHistoryObj animated:YES];
    }
}

//Campaign summary ended
- (void)campaignSummaryProcedures :(id)sender {
    
    if ([[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"Ispicuploaded"] intValue] == 0 ) {
        
        BidInfoModel *tempModel=[[BidInfoModel alloc] init];
        tempModel.campaignId=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *fromDateTime = [dateFormatter dateFromString:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"start_date"]];
        NSDate *ToDateTime = [dateFormatter dateFromString:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"end_date"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        tempModel.duration = [NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:fromDateTime],[dateFormatter stringFromDate:ToDateTime]];
        
        tempModel.campaignName=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_name"];
        tempModel.carOwnerName=[UserDefaultManager getValue:@"userName"];
        tempModel.carPlateNumber=[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"];
        
        NSString *currentDateTimeString=[dashboardDataDict objectForKey:@"currentServerTime"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
        NSDate *currentDate=[dateFormatter dateFromString:currentDateTimeString];
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
        tempModel.dateTime = [dateFormatter stringFromDate:currentDate];
        
        tempModel.totalEarning=([[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_earnings"] isEqualToString:@""]?@"0":[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_earnings"]);
//        tempModel.totalEarning=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_earnings"];
        tempModel.totalPoints=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_points"];
        tempModel.distanceCovered=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"track_distance"];
        tempModel.daysTravelled=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"days_travelled"];
        
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CampaignEndedViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"CampaignEndedViewController"];
        popupView.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
        popupView.dashboardObj = self;
        popupView.cmsContent = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"terms_and_conditions"];
//        popupView.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaigns_id"];
        popupView.campaignCarId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
        popupView.isUpdated = false;
        popupView.signatureId = @"0";
        popupView.campaignSubmitPreview=[tempModel copy];
        popupView.isSignatureApproved = @"Pending";
        isPopUpOpen = true;
        
        popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [self presentViewController:popupView animated: YES completion:nil];
    }
    else if ([[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"Ispicuploaded"] intValue] == 1 && [[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"is_approved"] intValue] == 0) {
        
        BidInfoModel *tempModel=[[BidInfoModel alloc] init];
        tempModel.campaignId=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *fromDateTime = [dateFormatter dateFromString:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"start_date"]];
        NSDate *ToDateTime = [dateFormatter dateFromString:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"end_date"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        tempModel.duration = [NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:fromDateTime],[dateFormatter stringFromDate:ToDateTime]];
        
        tempModel.campaignName=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_name"];
        tempModel.carOwnerName=[UserDefaultManager getValue:@"userName"];
        tempModel.carPlateNumber=[[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"plate_number"];
        
        NSString *currentDateTimeString=[dashboardDataDict objectForKey:@"currentServerTime"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
        NSDate *currentDate=[dateFormatter dateFromString:currentDateTimeString];
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
        tempModel.dateTime = [dateFormatter stringFromDate:currentDate];
        
        tempModel.totalEarning=([[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_earnings"] isEqualToString:@""]?@"0":[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_earnings"]);
        tempModel.totalPoints=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"total_points"];
        tempModel.distanceCovered=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"track_distance"];
        tempModel.daysTravelled=[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"days_travelled"];
        
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CampaignEndedViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"CampaignEndedViewController"];
        popupView.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
        popupView.dashboardObj = self;
        popupView.cmsContent = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"terms_and_conditions"];
//        popupView.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaigns_id"];
        popupView.campaignCarId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
        popupView.signatureId = @"0";
        popupView.campaignSubmitPreview=[tempModel copy];
        popupView.carId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
        popupView.isUpdated = true;
        isPopUpOpen = true;
        
        NSMutableArray *tempCarImagesArray;
        tempCarImagesArray = [NSMutableArray new];
        
         NSMutableDictionary *tempDic = [NSMutableDictionary new];
        
        for (int i = 0; i < 5; i++) {
            
            tempDic = [NSMutableDictionary new];
            [tempCarImagesArray addObject:tempDic];
        }
        for (int i = 0; i < [[dashboardDataDict objectForKey:@"campaignend"] count]; i++) {
            @try {
                tempDic = [NSMutableDictionary new];
                if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"End mileage reading"]) {
                    
                    if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"Rejected"]) {
                        
                        [tempDic setObject:@"false" forKey:@"isSet"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:@"Pending" forKey:@"is_approved"];
                        [tempDic setObject:@"false" forKey:@"isUploaded"];
                    }
                    else {
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] forKey:@"imageUrl"];
                        [tempDic setObject:@"true" forKey:@"isSet"];
                        [tempDic setObject:[[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] lastPathComponent] forKey:@"imageName"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
                        [tempDic setObject:@"true" forKey:@"isUploaded"];
                    }
                    
                    [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"note"] forKey:@"warning"];
                    [tempCarImagesArray replaceObjectAtIndex:0 withObject:tempDic];
                }
                else if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"Front"]) {
                    if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"Rejected"]) {
                        tempDic = [NSMutableDictionary new];
                        [tempDic setObject:@"false" forKey:@"isSet"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:@"Pending" forKey:@"is_approved"];
                        [tempDic setObject:@"false" forKey:@"isUploaded"];
                    }
                    else {
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] forKey:@"imageUrl"];
                        [tempDic setObject:@"true" forKey:@"isSet"];
                        [tempDic setObject:[[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] lastPathComponent] forKey:@"imageName"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
                        [tempDic setObject:@"true" forKey:@"isUploaded"];
                    }
                    [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"note"] forKey:@"warning"];
                    [tempCarImagesArray replaceObjectAtIndex:1 withObject:tempDic];
                    
                }
                else if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"Left"]) {
                    if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"Rejected"]) {
                        tempDic = [NSMutableDictionary new];
                        [tempDic setObject:@"false" forKey:@"isSet"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:@"Pending" forKey:@"is_approved"];
                        [tempDic setObject:@"false" forKey:@"isUploaded"];
                    }
                    else {
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] forKey:@"imageUrl"];
                        [tempDic setObject:@"true" forKey:@"isSet"];
                        [tempDic setObject:[[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] lastPathComponent] forKey:@"imageName"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
                        [tempDic setObject:@"true" forKey:@"isUploaded"];
                    }
                    [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"note"] forKey:@"warning"];
                    [tempCarImagesArray replaceObjectAtIndex:2 withObject:tempDic];
                }
                else if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"Right"]) {
                    if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"Rejected"]) {
                        tempDic = [NSMutableDictionary new];
                        [tempDic setObject:@"false" forKey:@"isSet"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:@"Pending" forKey:@"is_approved"];
                        [tempDic setObject:@"false" forKey:@"isUploaded"];
                    }
                    else {
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] forKey:@"imageUrl"];
                        [tempDic setObject:@"true" forKey:@"isSet"];
                        [tempDic setObject:[[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] lastPathComponent] forKey:@"imageName"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
                        [tempDic setObject:@"true" forKey:@"isUploaded"];
                    }
                    [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"note"] forKey:@"warning"];
                    [tempCarImagesArray replaceObjectAtIndex:3 withObject:tempDic];
                }
                else if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"Rear"]) {
                    if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"Rejected"]) {
                        tempDic = [NSMutableDictionary new];
                        [tempDic setObject:@"false" forKey:@"isSet"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:@"Pending" forKey:@"is_approved"];
                        [tempDic setObject:@"false" forKey:@"isUploaded"];
                    }
                    else {
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] forKey:@"imageUrl"];
                        [tempDic setObject:@"true" forKey:@"isSet"];
                        [tempDic setObject:[[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image"] lastPathComponent] forKey:@"imageName"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
                        [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
                        [tempDic setObject:@"true" forKey:@"isUploaded"];
                    }
                    [tempDic setObject:[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"note"] forKey:@"warning"];
                    [tempCarImagesArray replaceObjectAtIndex:4 withObject:tempDic];
                }
                else if ([[[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"image_type"] isEqualToString:@"Signature"]) {
                    
                    popupView.isSignatureApproved = [[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"is_approved"];
                    popupView.signatureId = [[[dashboardDataDict objectForKey:@"campaignend"] objectAtIndex:i] objectForKey:@"id"];
                }
            } @catch (NSException *exception) {
                
                //NSLog(@"exception is %@",exception);
            }
            
        }
        
        popupView.carImagesArray = [tempCarImagesArray mutableCopy];
//        popupView.resetData = [tempCarImagesArray mutableCopy];
        popupView.resetData = [[NSMutableArray alloc] initWithArray:tempCarImagesArray
                                    copyItems:YES];
        popupView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [self presentViewController:popupView animated: YES completion:nil];
    }
    else if ([[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"Ispicuploaded"] intValue] == 1 && [[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"is_approved"] intValue] == 2) {
         [UserDefaultManager showAlertMessage:@"Please wait, Admin will review the images."];
//        Please wait, admin will review the images.
        //show alert
    }
}

//Campaign information method
- (void)campaignInfoMethod :(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BidInfoViewController *bidInfoViewObj =[storyboard instantiateViewControllerWithIdentifier:@"BidInfoViewController"];
    bidInfoViewObj.bidId = [[dashboardDataDict objectForKey:@"bidsuccessful"]  objectForKey:@"bid_id"];
    bidInfoViewObj.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
    bidInfoViewObj.isBidExist = YES;
    [self.navigationController pushViewController:bidInfoViewObj animated:NO];
}
#pragma mark - end

#pragma mark - UICollectionview methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([[dashboardDataDict objectForKey:@"bidding"] count]>0) {
        return 1;
    }
    else {
        return 0;
    }
//    return [[dashboardDataDict objectForKey:@"bidding"] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BiddingCollectionViewCell *myCell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:@"BiddingCollectionViewCell"
                                         forIndexPath:indexPath];
    [[myCell contentView] setFrame:[myCell bounds]];
    [[myCell contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [myCell dispalyData:[[dashboardDataDict objectForKey:@"bidding"] objectAtIndex:currentIndex] count:(int)[[dashboardDataDict objectForKey:@"bidding"] count]];
    if ([[dashboardDataDict objectForKey:@"bidding"] count]<=1)
    {
        myCell.previousBtn.hidden=YES;
        myCell.nextBtn.hidden=YES;
    }
    else if (currentIndex==0)
    {
        myCell.previousBtn.hidden= YES;
        myCell.nextBtn.hidden=NO;
    }
    else if(currentIndex==[[dashboardDataDict objectForKey:@"bidding"] count]-1)
    {
        myCell.previousBtn.hidden= NO;
        myCell.nextBtn.hidden=YES;
    }
    else{
        myCell.previousBtn.hidden= NO;
        myCell.nextBtn.hidden=NO;
    }
    myCell.moreBidBtn.tag = currentIndex;
    [myCell.moreBidBtn addTarget:self action:@selector(moreInfoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [myCell.nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [myCell.previousBtn addTarget:self action:@selector(previourBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Add swipe gesture
    myCell.biddingImage.userInteractionEnabled = YES;
    
    //Swipe gesture to swipe images to left
    UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToImageLeft)];
    swipeImageLeft.delegate=self;
    UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToImageRight)];
    swipeImageRight.delegate=self;
    
    // Setting the swipe direction.
    [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
    // Adding the swipe gesture on image view
    [[myCell biddingImage] addGestureRecognizer:swipeImageLeft];
    [[myCell biddingImage] addGestureRecognizer:swipeImageRight];
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"stop");
}
#pragma mark - end

#pragma mark - Swipe Images
//Adding left animation to banner images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        //NSLog(@"stop");
        NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:0 inSection:2];
        BiddingCell *Bidcell  =(BiddingCell *)[dashboardTableview cellForRowAtIndexPath:cellIndex];
        [Bidcell.collectionView reloadData];
    }];
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
    [CATransaction commit];
}

//Adding right animation to banner images
- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [CATransaction setCompletionBlock:^{
        //NSLog(@"stop");
        NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:0 inSection:2];
        BiddingCell *Bidcell  =(BiddingCell *)[dashboardTableview cellForRowAtIndexPath:cellIndex];
        [Bidcell.collectionView reloadData];
    }];
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
    [CATransaction commit];
}

//Swipe images in left direction
- (void)swipeToImageLeft {
    
    currentIndex++;
    if (currentIndex < [[dashboardDataDict objectForKey:@"bidding"] count]) {
        
        NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:0 inSection:2];
        BiddingCell *Bidcell  =(BiddingCell *)[dashboardTableview cellForRowAtIndexPath:cellIndex];
         NSIndexPath * Index = [NSIndexPath indexPathForRow:0 inSection:0];
         BiddingCollectionViewCell *cell  =(BiddingCollectionViewCell *)[Bidcell.collectionView cellForItemAtIndexPath:Index];
        
        __weak UIImageView *weakRef = cell.biddingImage;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[dashboardDataDict objectForKey:@"bidding"] objectAtIndex:currentIndex] objectForKey:@"bidimage"]]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [cell.biddingImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        UIImageView *moveIMageView = cell.biddingImage;
        [self addLeftAnimationPresentToView:moveIMageView];
    }
    else {
        
        currentIndex = (int)[[dashboardDataDict objectForKey:@"bidding"] count] - 1;
    }
}

//Swipe images in right direction
- (void)swipeToImageRight {
    
    currentIndex--;
    if (currentIndex>=0) {
        
        NSIndexPath * cellIndex = [NSIndexPath indexPathForRow:0 inSection:2];
        BiddingCell *Bidcell  =(BiddingCell *)[dashboardTableview cellForRowAtIndexPath:cellIndex];
        NSIndexPath * Index = [NSIndexPath indexPathForRow:0 inSection:0];
        BiddingCollectionViewCell *cell  =(BiddingCollectionViewCell *)[Bidcell.collectionView cellForItemAtIndexPath:Index];
        
        __weak UIImageView *weakRef = cell.biddingImage;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[dashboardDataDict objectForKey:@"bidding"] objectAtIndex:currentIndex] objectForKey:@"bidimage"]]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [cell.biddingImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        UIImageView *moveIMageView = cell.biddingImage;
        [self addRightAnimationPresentToView:moveIMageView];
    }
    else {
        
        currentIndex = 0;
    }
}
#pragma mark - end

#pragma mark - Custom delegate
- (void)popupViewDelegateMethod:(int)option installationText:(NSString *)installationText installationType:installationType
{
    isPopUpOpen=false;
    if (option == 1)
    {
        //NSLog(@"installationText %@",installationText);
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([installationType containsString:@"Workshop"])
        {
            //NSLog(@"MyAdogo log--------4");
            [myDelegate showIndicator];
            [self performSelector:@selector(setInstallationLocation:) withObject:installationText afterDelay:.1];
        }
        else
        {
            OnsiteInstallationViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"OnsiteInstallationViewController"];
            nextView.bidId = [[dashboardDataDict objectForKey:@"bidsuccessful"]  objectForKey:@"bid_id"];
            nextView.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
            nextView.methodStr = installationText;
            [self.navigationController pushViewController:nextView animated:YES];
        }
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (void)handleDragOnButton:(UIPanGestureRecognizer *)recognizer {
    
    UIButton *button = (UIButton *)recognizer.view;
    CGPoint translation = [recognizer translationInView:button];
    if (((_trackView.center.x + translation.x) >= 50) && ((_trackView.center.x + translation.x) <= [[UIScreen mainScreen] bounds].size.width - 41 - 10) && ((_trackView.center.y + translation.y) >= 100) && ((_trackView.center.y + translation.y) <= [[UIScreen mainScreen] bounds].size.height - 41 - 64 - 10)) {
        
        _trackView.center = CGPointMake(_trackView.center.x + translation.x, _trackView.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:_trackView];
    }
}

- (IBAction)locationTrack:(UIButton *)sender {
    if ([[dashboardDataDict objectForKey:@"defaultcarinfo"] count]<1)
    {
        [UserDefaultManager showAlertMessage:@"Please add a car to start tracking."];
        return;
    }
    else if (![[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Phone"])
    {
        return;
    }
    if (_trackBtn.selected)
    {
        myDelegate.startEndStr = @"3";
        [myDelegate stopTrack];
        _trackBtn.selected = NO;
        [_trackImageView stopAnimating];
        _trackImageView.image = [UIImage imageNamed:@"track"];
        [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
    }
    else {
        myDelegate.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
        myDelegate.startEndStr = @"1";
        if ([[dashboardDataDict objectForKey:@"currentStateStatus"]intValue]==5 && ([UserDefaultManager dateComparision:[dashboardDataDict objectForKey:@"currentServerTime"] endDate:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"end_date"] startTime:[[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"start_date"]]!=1))
        {
            myDelegate.carId = [[dashboardDataDict objectForKey:@"defaultcarinfo"] objectForKey:@"id"];
            myDelegate.campaignId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaignsid"];
            myDelegate.campaignCarId = [[dashboardDataDict objectForKey:@"campaignsummary"] objectForKey:@"campaign_car_id"];
        }
        _trackBtn.selected = YES;
        
        [myDelegate startTrack];
    }
}

- (void)trackingChecker:(NSNotification *)notification
{
    //NSLog(@"%@",[notification object]);
    if ([[notification object] isEqualToString:@"stop"])
    {
        _trackBtn.selected = NO;
        [_trackImageView stopAnimating];
        _trackImageView.image = [UIImage imageNamed:@"track"];
        [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
        [myDelegate stopTrack];
    }
    else if ([[notification object] isEqualToString:@"start"])
    {
        _trackBtn.selected = YES;
        _trackImageView.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"tracking1"],
                                           [UIImage imageNamed:@"tracking2"],
                                           [UIImage imageNamed:@"tracking3"], nil];
        _trackImageView.animationDuration = 1.0f;
        _trackImageView.animationRepeatCount = 0;
        [_trackImageView startAnimating];
        [UserDefaultManager setValue:@"true" key:@"isTrackingStart"];
    }
}

- (void)trackingCheckerForBeacon:(NSNotification *)notification
{
    if ([[notification object] isEqualToString:@"stop"])
    {
        _trackBtn.selected = NO;
        [_trackImageView stopAnimating];
        _trackImageView.image = [UIImage imageNamed:@"track"];
        [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
    }
    else if ([[notification object] isEqualToString:@"start"])
    {
        _trackBtn.selected = YES;
        _trackImageView.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"tracking1"],
                                           [UIImage imageNamed:@"tracking2"],
                                           [UIImage imageNamed:@"tracking3"], nil];
        _trackImageView.animationDuration = 1.0f;
        _trackImageView.animationRepeatCount = 0;
        [_trackImageView startAnimating];
        [UserDefaultManager setValue:@"true" key:@"isTrackingStart"];
    }
}
#pragma mark - end


- (void)checkIsBluetoothOn:(NSNotification *)notification
//-(void)checkIsBluetoothOn
{
    if ([[notification object] boolValue]) {
    
        
        //NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@start");
        dashboardLocationManager = [[CLLocationManager alloc] init];
        // Set the delegate
        dashboardLocationManager.delegate = self;
        //--------Remove blue line during background location update-------
        if ([dashboardLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [dashboardLocationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
        }
        //--------end
        dashboardLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        dashboardLocationManager.distanceFilter = kCLDistanceFilterNone;
    }
//    else {
//    
//        //NSLog(@"################################################start");
//    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (isAskMorePhotoPopUpOpen) {
        if (!isBackground) {
            if ([CLLocationManager locationServicesEnabled]) {
                switch (status)
                {
                    case kCLAuthorizationStatusNotDetermined:
                    {
                        
                        alertview = [[SCLAlertView alloc] initWithNewWindow];
                        alertview.view.tag=102;
                        [alertview addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alertview showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:nil duration:0.0f];
                        
                        //NSLog(@"************************************************start->%d",status);
                    }
                        break;
                    case kCLAuthorizationStatusRestricted:{
                        //NSLog(@"************************************************start->%d",status);
                        
                        alertview = [[SCLAlertView alloc] initWithNewWindow];
                        alertview.view.tag=102;
                        [alertview addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alertview showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:nil duration:0.0f];
                        
                    }
                        break;
                    case kCLAuthorizationStatusDenied:
                    {
                        
                        //NSLog(@"************************************************start->%d",status);
                        alertview = [[SCLAlertView alloc] initWithNewWindow];
                        alertview.view.tag=102;
                        [alertview addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alertview showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:nil duration:0.0f];
                        
                        
                    }
                        break;
                    case kCLAuthorizationStatusAuthorizedAlways:
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                    {
                        //NSLog(@"************************************************start->%d",status);
                        [dashboardLocationManager requestAlwaysAuthorization];
                        
                    }
                        break;
                    default:
                    {
                        alertview = [[SCLAlertView alloc] initWithNewWindow];
                        alertview.view.tag=102;
                        [alertview addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alertview showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:nil duration:0.0f];
                    }
                        break;
                }
            }
            else {
                alertview = [[SCLAlertView alloc] initWithNewWindow];
                alertview.view.tag=102;
                [alertview addButton:@"Settings" actionBlock:^(void) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }];
                [alertview showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:nil duration:0.0f];
                
            }
            
        }
    }
    else {
        if ([CLLocationManager locationServicesEnabled]) {
            switch (status)
            {
                case kCLAuthorizationStatusNotDetermined:
                {
                    if (isDashboardService) {
                        isDashboardService=false;
                        [myDelegate showIndicator];
                        [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
                    }
                    else {
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
                    }
                    
                    //NSLog(@"************************************************start->%d",status);
                }
                    break;
                case kCLAuthorizationStatusRestricted:{
                    //NSLog(@"************************************************start->%d",status);
                    if (isDashboardService) {
                        isDashboardService=false;
                        [myDelegate showIndicator];
                        [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
                    }
                    else {
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addButton:@"Settings" actionBlock:^(void) {
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:url];
                        }];
                        [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
                    }
                }
                    break;
                case kCLAuthorizationStatusDenied:
                {
                    if (isDashboardService) {
                        isDashboardService=false;
                        [myDelegate showIndicator];
                        [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
                    }
                    else {
                        if ([CLLocationManager locationServicesEnabled]) {
                            //NSLog(@"************************************************start->%d",status);
                            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                            [alert addButton:@"Settings" actionBlock:^(void) {
                                
                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                [[UIApplication sharedApplication] openURL:url];
                            }];
                            [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
                        }
                    }
                }
                    break;
                case kCLAuthorizationStatusAuthorizedAlways:
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                {
                    //NSLog(@"************************************************start->%d",status);
                    [dashboardLocationManager requestAlwaysAuthorization];
                    
                }
                    break;
                default:
                {
                    if (isDashboardService) {
                        isDashboardService=false;
                        
                        [myDelegate showIndicator];
                        [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
                    }
                }
                    break;
            }
        }
        else {
            if (isDashboardService) {
                isDashboardService=false;
                [myDelegate showIndicator];
                [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
            }
            else {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"Settings" actionBlock:^(void) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    CLLocationCoordinate2D here = newLocation.coordinate;
    
    if (isDashboardService) {
        isDashboardService=false;
        dashboardTrackingLatitude = [NSString stringWithFormat:@"%lf",here.latitude];
        dashboardTrackingLongitude = [NSString stringWithFormat:@"%lf",here.longitude];
        
        if (!isAskMorePhotoPopUpOpen) {
            [myDelegate showIndicator];
            [self performSelector:@selector(getDashboardData) withObject:nil afterDelay:.1];
            
        }
        //NSLog(@"----->%@,%@",dashboardTrackingLatitude,dashboardTrackingLongitude);
        [dashboardLocationManager stopUpdatingLocation];
    }
}
#pragma mark - end

#pragma mark - Question popUp delegate
- (void)questionPopupViewDelegateMethod:(int)option {

    if (option==4) {    //If select later option
        [UserDefaultManager setPlistValue:[[[dashboardDataDict objectForKey:@"currentServerTime"] componentsSeparatedByString:@" "] objectAtIndex:0] key:[NSString stringWithFormat:@"%@_%@",[UserDefaultManager getValue:@"userId"],[[[dashboardDataDict objectForKey:@"user_ananswered_questions"] objectAtIndex:dynamicPopUpOpenIndex] objectForKey:@"id"]]];
    }
    
    dynamicPopUpOpenIndex=dynamicPopUpOpenIndex+1;
    
    if (dynamicPopUpOpenIndex<dynamicPopUpCount) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openQuestionPopUpView];
        });
    }
}
#pragma mark - end
@end
