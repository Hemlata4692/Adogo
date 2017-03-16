//
//  AppDelegate.m
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MMMaterialDesignSpinner.h"
#import "UIImage+deviceSpecificMedia.h"
#import <AWSCore/AWSCore.h>
#import "Constants.h"
#import "Constants.h"
#import "AWSDownload.h"
#import "GAI.h"
#import "SCLAlertView.h"
#import "CampaignService.h"
#import "MyDatabase.h"
//#import "IntroductionViewController.h"
#import "LoginViewController.h"
#import "FbAmbassadorPostViewController.h"
#import "ChatHistoryViewController.h"
#import "ChatStyling.h"
#import "AddNewCarViewController.h"
#import "ABTransmitters.h"
#import "AprilBeaconSDK.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "InstalledStickerViewController.h"
#import "BonusJobViewController.h"
#import "RegistrationViewControllerStepOne.h"
#import "UncaughtExceptionHandler.h"
#import "ExploreViewController.h"

@import GoogleMaps;

@interface AppDelegate ()<ABBluetoothManagerDelegate,CBCentralManagerDelegate>
{
    
    UIImageView *spinnerBackground;
    UIView *loaderView;
    UIApplication *applicationObj;
    NSString *trackingLatitude, *trackingLongitude,*trackingDate;
    NSString *oldTrackingLatitude, *oldTrackingLongitude;
    bool isTracking;
    bool shouldTrack;
    NSTimer *backgroundTimerForDatabase, *backgroundTimerForService,*beaconDetectionTimer;
    int rangeTimer;
}
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;
@property (nonatomic, strong) UILabel *loaderLabel;
@property (nonatomic, strong) NSMutableArray *beconDataArray;

@property (nonatomic, strong) ABBeaconRegion *region;
@end

@implementation AppDelegate
id<GAITracker> tracker;
//@synthesize  deviceToken;
@synthesize sideBarImage;
@synthesize selScreenState;
@synthesize navigationController;
@synthesize popupText, isStarted;
@synthesize alertCount;
@synthesize isAmbassadorPost;
@synthesize beaconName;
@synthesize  isAmbassadorPostListing;
@synthesize isbluetoothOn;
//Database variables
@synthesize carId;
@synthesize campaignId;
@synthesize campaignCarId;
@synthesize startEndStr;
@synthesize notificationDict;
@synthesize currentNavController;
@synthesize currentPresentViewName;
@synthesize beaconArray;
@synthesize isLogout;
@synthesize bluetoothManager;
@synthesize facebookCount;
@synthesize isGetNotification;
@synthesize isValidDate;
//Testing track log
@synthesize locationUpdateTimeDifference, isEnableTrackLogEmail;
@synthesize testingCarId, testingStartEndString;
//end
#pragma mark - Global indicator view
- (void)showIndicator:(NSString*)title {
    
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=YES;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [loaderView addSubview:spinnerBackground];
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.spinnerView.tintColor = [UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
    self.spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    self.spinnerView.lineWidth=3.0f;
    
    self.loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) + 30, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.loaderLabel.backgroundColor = [UIColor clearColor];
    self.loaderLabel.textColor = [UIColor whiteColor];
    self.loaderLabel.font = [UIFont railwayBoldWithSize:14];
    self.loaderLabel.textAlignment = NSTextAlignmentCenter;
    self.loaderLabel.text = title;
    
    [self.window addSubview:loaderView];
    [self.window addSubview:self.spinnerView];
    [self.window addSubview:self.loaderLabel];
    [self.spinnerView startAnimating];
}

- (void)showIndicator {
    
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=YES;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [loaderView addSubview:spinnerBackground];
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.spinnerView.tintColor = [UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
    self.spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    self.spinnerView.lineWidth=3.0f;
    [self.window addSubview:loaderView];
    [self.window addSubview:self.spinnerView];
    [self.spinnerView startAnimating];
}

- (void)stopIndicator
{
    [loaderView removeFromSuperview];
    [self.spinnerView removeFromSuperview];
    [self.loaderLabel removeFromSuperview];
    [self.spinnerView stopAnimating];
}
#pragma mark - end

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Call crashlytics method
    [self performSelector:@selector(installUncaughtExceptionHandler) withObject:nil afterDelay:0];
    
    locationUpdateTimeDifference=5;
    isEnableTrackLogEmail=0;
    [UserDefaultManager setValue:@"false" key:@"isTrackingStart"];
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    // Initialize tracker. Replace with your tracking ID.
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-77957486-1"];
    //        //Google api key
    //[MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
    [GMSServices provideAPIKey:@"AIzaSyCi1e_gmKw5Bu7WTj0YlAo8Lpnfu-NU2u4"];
    //    //*******set up for beacon initialization*****
    self.beaconManager = [[ABBeaconManager alloc] init];
    [self.beaconManager requestAlwaysAuthorization];
    self.beaconManager.delegate = self;
    beaconArray = [[NSMutableArray alloc]init];
    //[self startRangeBeacons];
    //*******end*****
    
    //setting all default valuess
    [self setDefaultValues];
    //end
    
    //check if database exists or not.
    [MyDatabase checkDataBaseExistence];
    
    //sync local tracking database to server if app was force closed while tracking or data not synced due to network connetivity
    [self startTrackingBg];
    //end
    
    //set navigation bar properties.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont railwayRegularWithSize:18], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    application.statusBarHidden = NO;
    applicationObj = application;
    //end
    
    //Maintain switch state for setting screen.
    if([UserDefaultManager getValue:@"switchStatusDict"]==NULL)
    {
        NSMutableDictionary *switchDict=[[NSMutableDictionary alloc]init];
        [switchDict setObject:@"False" forKey:@"00"];
        [switchDict setObject:@"False" forKey:@"01"];
        [UserDefaultManager setValue:switchDict key:@"switchStatusDict"];
    }
    if([UserDefaultManager getValue:@"isNotificationAvailable"]==NULL)
    {
        [UserDefaultManager setValue:@"False" key:@"isNotificationAvailable"];
    }
    
    isGetNotification=NO;
    // Chat setup
    [ChatStyling applyStyling];
    // configure account key and pre-chat form
    [ZDCChat initializeWithAccountKey:@"41oB3OK3bV5zDXg4psO9rBr94HXv8r8n"];
    [ZDCChat startChat:^(ZDCConfig *config){
        config.preChatDataRequirements.name = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.email = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
        //                        config.emailTranscriptAction = ZDCEmailTranscriptActionNeverSend;
    }];
    // To override the default avatar uncomment and complete the image name
    //[[ZDCChatAvatar appearance] setDefaultAvatar:@"your_avatar_name_here"];
    // Uncomment to disable visitor data persistence between application runs
    //    [[ZDCChat instance].session visitorInfo].shouldPersist = YES;
    
    // Uncomment if you don't want open chat sessions to be automatically resumed on application launch
    [ZDCChat instance].shouldResumeOnLaunch = YES;
    
    // remember to switch off debug logging before app store submission!
    [ZDCLog enable:YES];
    [ZDCLog setLogLevel:ZDCLogLevelWarn];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    selScreenState = 0;
    
    //        [UserDefaultManager setValue:@"Yes" key:@"rootView"];
    //Navigate view if already logged in.
    self.navigationController = (UINavigationController *)[self.window rootViewController];
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([UserDefaultManager getValue:@"isCampaignRunning"] == nil) {
        
        [UserDefaultManager setValue:@"false" key:@"isCampaignRunning"];
    }
    
    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (remoteNotifiInfo)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self application:application didReceiveRemoteNotification:remoteNotifiInfo];
    }
    else {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil)
        {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                                 animated: YES];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            if(![UserDefaultManager getValue:@"rootView"])
            {
                //If the app is installed first time this screen will apper first
                ExploreViewController * objTutorial = [storyboard instantiateViewControllerWithIdentifier:@"ExploreViewController"];
                [self.navigationController setViewControllers: [NSArray arrayWithObject: objTutorial]
                                                     animated: YES];
            }
            else
            {
                //        Once the user is logged in login screen will appear
                RegistrationViewControllerStepOne * objLogin = [storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
                [self.navigationController setViewControllers: [NSArray arrayWithObject: objLogin]
                                                     animated: YES];
            }
        }
        //end
    }
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    return YES;
}

- (void)installUncaughtExceptionHandler {
    
    InstallUncaughtExceptionHandler();
}

- (void)setDefaultValues
{

    facebookCount = 0;
    isLogout = false;
    isAmbassadorPost = false;
    isAmbassadorPostListing = false;
    alertCount=0;
    rangeTimer = -1;
    popupText = @"";
    carId = @"";
    campaignCarId = @"0";
    campaignId = @"0";
    startEndStr = @"";
    notificationDict = [NSMutableDictionary new];
    [notificationDict setObject:@"Other" forKey:@"ScreenType"];
    [notificationDict setObject:@"No" forKey:@"isNotification"];
    currentPresentViewName = @"Other";
    
    [UserDefaultManager setValue:@"123" key:@"DeviceToken"];
    [UserDefaultManager setValue:@"Phone" key:@"trackingMethod"];
    [UserDefaultManager setValue:@"1" key:@"isNotificationOn"];
    [UserDefaultManager setValue:@"1" key:@"isDailyMilageReportOn"];
    [UserDefaultManager setValue:@"No" key:@"ShouldStartTrack"];
    if ([UserDefaultManager getValue:@"TestingTrackMethod"]==nil || [[UserDefaultManager getValue:@"TestingTrackMethod"] isEqualToString:@""] || [UserDefaultManager getValue:@"TestingTrackMethod"]==NULL) {
        [UserDefaultManager setValue:@"Mobile GPS" key:@"TestingTrackMethod"];
    }
//    if ([UserDefaultManager getValue:@"isTrackBeacon"]==nil || [[UserDefaultManager getValue:@"isTrackBeacon"] isEqualToString:@""] || [UserDefaultManager getValue:@"isTrackBeacon"]==NULL){
//        [UserDefaultManager setValue:@"No" key:@"isBeaconRegistered"];
//    }
    
    oldTrackingLongitude = @"";
    oldTrackingLatitude = @"";
}

- (void)awsConfugration {
    
    //Set AWS credentials
    AWSStaticCredentialsProvider *credentialsProvider = [[ AWSStaticCredentialsProvider alloc]initWithAccessKey:[UserDefaultManager getValue:@"AccessKey"] secretKey:[UserDefaultManager getValue:@"Secretkey"]];
    AWSServiceConfiguration *configuration =  [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //end
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    applicationObj = application;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    applicationObj = application;
    if ([UserDefaultManager getValue:@"isTrackingStart"] != NULL || ![[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"false"]) {
        [remoteTimer invalidate];
        [localTimer invalidate];
        [backgroundTimerForService invalidate];
        backgroundTimerForService = nil;
        [backgroundTimerForDatabase invalidate];
        backgroundTimerForDatabase = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // [_beaconManager startAprilBeaconsDiscovery];
            backgroundTimerForService = [NSTimer scheduledTimerWithTimeInterval:60*locationUpdateTimeDifference target:self selector:@selector(startTrackingBg) userInfo:nil repeats:YES];
            backgroundTimerForDatabase = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startTrackingForLocalDatabase) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:backgroundTimerForService forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] addTimer:backgroundTimerForDatabase forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    applicationObj = application;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    applicationObj = application;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [FBAppCall handleDidBecomeActive];  //Facebook SDK method
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    applicationObj = application;
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook login
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}
#pragma mark - end

#pragma mark - Push notification methods
- (void)registerDeviceForNotification {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1 {
    
    NSString *token = [[deviceToken1 description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"content---%@", token);
    
//    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    [UserDefaultManager setValue:token key:@"DeviceToken"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    isGetNotification=NO;
//    NSLog(@"push notification response.............%@",userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil) {
        
//        NSLog(@"push notification response.............%@",userInfo);
        [UserDefaultManager setValue:@"True" key:@"isNotificationAvailable"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAlert" object:nil];
        switch ([[[userInfo objectForKey:@"aps"] objectForKey:@"notification_type_id"] intValue]) {
            case FBAmbassadorPostNotification:     //Facebook ambassador post share notification handling
                [self fbAmbassadorPostNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case AddMoreCarImageNotification:    //Add more car image notification handling.
                [self addMoreCarImageNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case AddCarDimensionNotification:     //Ask for car dimension notification handling.
            case ApproveCarDimensionNotification:    //Ask for approve car dimension notification handling.
            case RejectCarDimensionNotification:    //Ask for reject car dimension notification handling.
                [self carDimensionNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case ApproveCarNotification:     //Approve car notification handling.
                [self approvedCarNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case BidExpiryReminderNotification:     //Bid expiry reminder notification handling.
                [self BidExpiryReminderNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case BidAssignedNotification:     //Assigned bid by adogo
                [self assignedBid:application notificationData:[userInfo mutableCopy]];
                break;
            case BidApproveNotification:    //Approve bid by adogo
            case InstallerAssignedNotification:    //Installer assign by adogo
            case InstallationScheduleNotification:    //Installation schedule notification handling
            case InstallerOnTheWayNotification:    //Installer on the way notification handling
            case CampaignEndProcedureAcceptRejectNotification:    //Campaign end procedure accepte/reject notification
            case InstallationJobCompletedNotification:    //When installation job completed
            case InstallationErrorNotification:     //When error occured during installation
            case DeleteSchedulNotification:     //When schedule is deleted by installer
            case StartJobInstallation:   //When installer starts the job
            case campaignEndNotification:
                [self approvedCarBid:application notificationData:[userInfo mutableCopy]];
                break;
            case MorePhotoDuringCampaignNotification:    //Upload more photos during campaign.
                [self uploadMorePhotos:application notificationData:[userInfo mutableCopy]];
                break;
            case BonusJobNotification:    // Bonus job offer notification hander.
                [self bonusJobNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case PaymentNotification:    //Notification when driver gets payment from admin.
                [self paymentHistoryNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case RedemNotification:    //Notification when driver gets points from admin.
                [self redemHistoryNotification:application notificationData:[userInfo mutableCopy]];
                break;
            case NRICDeleted:    //Notification when driver gets points from admin.
                [self nricNotification:application notificationData:[userInfo mutableCopy]];
                break;
            default:  //Alert in case if no action is required when user clicks on it.
                [self BidExpiryReminderNotification:application notificationData:[userInfo mutableCopy]];
                break;
        }
    }
    else {
        
        return;
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
//    NSLog(@"did failtoRegister and testing : %@",str);
}

- (void)unrigisterForNotification {
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
#pragma mark - end

#pragma mark - Notification handlers

- (void)nricNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"Nric" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"DriverProfileViewController"];
            [currentNavController pushViewController:objReveal animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"Nric" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)paymentHistoryNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"PaymentHistory" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"PaymentHistoryViewController"];
            [currentNavController pushViewController:objReveal animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"PaymentHistory" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)redemHistoryNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"RedemHistory" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"RedemptionViewController"];
            [currentNavController pushViewController:objReveal animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"RedemHistory" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}


- (void)fbAmbassadorPostNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if(!isAmbassadorPost && !isAmbassadorPostListing) {
        
        isAmbassadorPost = true;
        [myDelegate stopIndicator];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FbAmbassadorPostViewController * fbAmbassadorObj = [storyboard instantiateViewControllerWithIdentifier:@"FbAmbassadorPostViewController"];
        fbAmbassadorObj.ambassadorId = [[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"ambassador_posts_id"];
        fbAmbassadorObj.seconds = [[UserDefaultManager formateDate:[[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"end_time"]] timeIntervalSinceDate:[UserDefaultManager formateDate:[[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"start_time"]]] + 59;
        fbAmbassadorObj.startDateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"start_time"];
        fbAmbassadorObj.endDateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"end_time"];
        fbAmbassadorObj.sharedUrl = [[[userInfo objectForKey:@"aps"] objectForKey:@"extra_params"] objectForKey:@"post_url"];
        fbAmbassadorObj.numberOfPost = 1;
        fbAmbassadorObj.previousScreen = 0;
        myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [myDelegate.window setRootViewController:fbAmbassadorObj];
        [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
        [myDelegate.window makeKeyAndVisible];
    }
    else if (isAmbassadorPostListing){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AmbassadorList" object:nil];
    }
}

- (void)addMoreCarImageNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"Yes" forKey:@"isNotification"];
        [notificationDict setObject:@"EditCar" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AddNewCarViewController *carDetailInfo =[storyboard instantiateViewControllerWithIdentifier:@"AddNewCarView"];
            carDetailInfo.isEditCar = YES;
            carDetailInfo.isCarListing = YES;
            
            [currentNavController pushViewController:carDetailInfo animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"Yes" forKey:@"isNotification"];
        [notificationDict setObject:@"EditCar" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)carDimensionNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        if ([[myDelegate.notificationDict objectForKey:@"ScreenType"] isEqualToString:@"CarDetailView"]) {
            [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"carDetail" object:nil];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
        }
        else {
            
            [notificationDict setObject:@"Yes" forKey:@"isNotification"];
            [notificationDict setObject:@"CarDetail" forKey:@"toScreen"];
            [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController * carDetailView = [storyboard instantiateViewControllerWithIdentifier:@"CarDetailViewController"];
                [currentNavController pushViewController:carDetailView animated:YES];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
        }
    }
    else {
        
        [notificationDict setObject:@"Yes" forKey:@"isNotification"];
        [notificationDict setObject:@"CarDetail" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)approvedCarNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"Yes" forKey:@"isNotification"];
        [notificationDict setObject:@"CarListing" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * carListView = [storyboard instantiateViewControllerWithIdentifier:@"CarListiewController"];
            [currentNavController pushViewController:carListView animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"Yes" forKey:@"isNotification"];
        [notificationDict setObject:@"CarListing" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)BidExpiryReminderNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objBonusJob = [storyboard instantiateViewControllerWithIdentifier:@"NotificationHistoryViewController"];
            [self.currentNavController pushViewController:objBonusJob animated:NO];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
}

- (void)assignedBid:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    [notificationDict setObject:@"BidAssigned" forKey:@"isNotification"];
    [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            [currentNavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DashboardViewController"] animated:NO];
            
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)approvedCarBid:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            if ([currentPresentViewName isEqualToString:@"DashboardView"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DashBoardScreen" object:nil];
            }
            else {
                [currentNavController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DashboardViewController"] animated:YES];
            }
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}

- (void)uploadMorePhotos:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo {
    
    NSString *str = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    NSRange range1 = [str rangeOfString:@"your car "];
    NSRange range2 = [str rangeOfString:@" for "];
    NSRange rangeToSubString = NSMakeRange(range1.location + range1.length, range2.location - range1.location - range1.length);
    
    NSString *resultStr = [str substringWithRange:rangeToSubString];
    
//    NSLog(@"path1 : %@",[resultStr stringByTrimmingCharactersInSet:
//                         [NSCharacterSet whitespaceCharacterSet]]);
//    if ((nil!=[UserDefaultManager getValue:@"defaultCarId"])&&![[UserDefaultManager getValue:@"defaultCarId"] isEqualToString:[userInfo valueForKeyPath:@"aps.extra_params.car_id"]]) {
//        [UserDefaultManager showAlertMessage:[NSString stringWithFormat:@"Change your default car to %@ for uploading more photos.",[UserDefaultManager getValue:@"defaultCarPlatNumber"]]];
//    }
//    else if ([[UserDefaultManager getValue:@"isCampaignRunning"] isEqualToString:@"true"]) {
//        [UserDefaultManager showAlertMessage:@"This campaign is not running."];
//    }
//    else {
    if ((application.applicationState == UIApplicationStateActive)|| (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"AskForMorePics" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
//        [UserDefaultManager setValue:[userInfo objectForKey:@"aps"] key:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            if ((nil!=[UserDefaultManager getValue:@"defaultCarId"])&&([[UserDefaultManager getValue:@"defaultCarId"] intValue] != [[userInfo valueForKeyPath:@"aps.extra_params.car_id"] intValue])) {
                [notificationDict setObject:@"Other" forKey:@"isNotification"];
                [UserDefaultManager showAlertMessage:[NSString stringWithFormat:@"Change your default car to %@ for uploading more photos.",resultStr]];
            }
            else if (![[UserDefaultManager getValue:@"isCampaignRunning"] isEqualToString:@"true"]) {
                [notificationDict setObject:@"Other" forKey:@"isNotification"];
                [UserDefaultManager showAlertMessage:@"Either campaign is not running or car is not ready to run in this campaign."];
            }
            else {
//            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            InstalledStickerViewController *objAddMorePics =[storyboard instantiateViewControllerWithIdentifier:@"InstalledStickerViewController"];
//            objAddMorePics.carId =[userInfo valueForKeyPath:@"aps.extra_params.car_id"];
//            objAddMorePics.campaignCarId =[userInfo valueForKeyPath:@"aps.extra_params.campaign_car_id"];
//            objAddMorePics.campaignId =[userInfo valueForKeyPath:@"aps.extra_params.campaign_id"];
//            objAddMorePics.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
//            [objAddMorePics setModalPresentationStyle:UIModalPresentationOverCurrentContext];
//            [currentNavController presentViewController:objAddMorePics animated: YES completion:nil];
                [notificationDict setObject:@"AskForMorePics" forKey:@"isNotification"];
                [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                                     animated: NO];
            }
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else
    {
        [notificationDict setObject:@"AskForMorePics" forKey:@"isNotification"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: NO];
    }
//    }
}

- (void)bonusJobNotification:(UIApplication *)application notificationData:(NSMutableDictionary *)userInfo
{
    if ((application.applicationState == UIApplicationStateActive) || (application.applicationState == UIApplicationStateBackground)) {
        
        [notificationDict setObject:@"BonusJob" forKey:@"isNotification"];
        [notificationDict setObject:@"EditCar" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            if ([currentPresentViewName isEqualToString:@"BonusJob"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BonusJobScreen" object:nil];
            }
            else {
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController * objBonusJob = [storyboard instantiateViewControllerWithIdentifier:@"BonusJobViewController"];
                [currentNavController pushViewController:objBonusJob animated:YES];
            }
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] closeButtonTitle:nil duration:0.0f];
    }
    else {
        
        [notificationDict setObject:@"BonusJob" forKey:@"isNotification"];
        [notificationDict setObject:@"EditCar" forKey:@"toScreen"];
        [notificationDict setObject:[userInfo objectForKey:@"aps"] forKey:@"NotificationAPSData"];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                             animated: YES];
    }
}
#pragma mark - end

#pragma mark - AWSDownload delegate
- (void)startImageDownloading:(NSString *)ImageName
{
    if(ImageName != nil)
    {
        NSMutableArray * awsImageArray=[NSMutableArray new];
        [awsImageArray addObject:ImageName];
        AWSDownload *download;
        download = [[AWSDownload alloc]init];
        download.delegate = self;
        [download listObjects:self ImageName:awsImageArray folderName:nil];
    }
}
- (void)ListObjectprocessCompleted:DownloadimageArray
{
    NSMutableArray * awsImageArray=[DownloadimageArray mutableCopy];
    [myDelegate stopIndicator];
    id object = [awsImageArray objectAtIndex:0];
    if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = object;
        downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (totalBytesExpectedToWrite > 0) {
                    
                }
            });
        };
        
    } else if ([object isKindOfClass:[NSURL class]]) {
        
    }
}
- (void)DownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index:(NSUInteger)index
{
    sideBarImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:downloadRequest.downloadingFileURL]];
}
#pragma mark - end delegate

#pragma mark - Location tracking
- (void)startTrack {
    //NSLog(@"entered in startTrack line---------------------------------: 830");
    locationManager = [[CLLocationManager alloc] init];
    isTracking  = true;
    isStarted = true;
    // Set the delegate
    locationManager.delegate = self;
    //--------Remove blue line during background location update-------
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        [locationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
    }
    //--------end
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    // Enable automatic pausing
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    locationManager.pausesLocationUpdatesAutomatically = NO;
    // Start location updates
    [locationManager startUpdatingLocation];
    if (![remoteTimer isValid])
    {
      //  NSLog(@"%d",locationUpdateTimeDifference);
        remoteTimer = [NSTimer scheduledTimerWithTimeInterval: 60*locationUpdateTimeDifference
                                                       target: self
                                                     selector: @selector(startTrackingBg)
                                                     userInfo: nil
                                                      repeats: YES];
    }
    if (![localTimer isValid])
    {
        localTimer = [NSTimer scheduledTimerWithTimeInterval: 10
                                                      target: self
                                                    selector: @selector(startTrackingForLocalDatabase)
                                                    userInfo: nil
                                                     repeats: YES];
    }
    [NSTimer scheduledTimerWithTimeInterval: 2
                                     target: self
                                   selector: @selector(startTrackingForLocalDatabase)
                                   userInfo: nil
                                    repeats: NO];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrack" object:@"stop"];
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrack" object:@"stop"];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"Settings" actionBlock:^(void) {
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrack" object:@"stop"];
            if ([CLLocationManager locationServicesEnabled]) {
                
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"Settings" actionBlock:^(void) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (([UserDefaultManager getValue:@"isTrackingStart"] == NULL || [[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"false"])&&isStarted) {
                [UserDefaultManager setValue:@"true" key:@"isTrackingStart"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrack" object:@"start"];
                [locationManager requestAlwaysAuthorization];
            }
        }
            break;
        default:
        {
        }
            break;
    }
}

- (void)startTrackingBg
{
    NSMutableArray *gpsInfo = [NSMutableArray new];
    
//    NSString *query=[NSString stringWithFormat:@"SELECT * FROM LocationTracking"];
     NSString *query=[NSString stringWithFormat:@"SELECT * FROM LocationTracking limit 0,90"];
    gpsInfo =[MyDatabase getDataFromLocationTable:[query UTF8String]];
   // NSLog(@"database entry code:%lu",(unsigned long)gpsInfo.count);
    if (gpsInfo.count>0)
    {
//        NSLog(@"##############database entry code:%lu",(unsigned long)gpsInfo.count);
        [[CampaignService sharedManager] setGPSTrackDataService:gpsInfo success :^(id responseObject)
         {
//             [MyDatabase deleteRecord:[@"delete from LocationTracking" UTF8String]];
             [MyDatabase deleteRecord:[@"DELETE from LocationTracking limit 0,90" UTF8String]];

                 [NSTimer scheduledTimerWithTimeInterval: 0
                                                  target: self
                                                selector: @selector(startTrackingBg)
                                                userInfo: nil
                                                 repeats: NO];
         }
                                                        failure:^(NSError *error)
         {
             [NSTimer scheduledTimerWithTimeInterval: 60*2
                                              target: self
                                            selector: @selector(startTrackingBg)
                                            userInfo: nil
                                             repeats: NO];
         }];
    }
}

- (void)startTrackingForLocalDatabase
{
    //NSLog(@"trackingLongitude is %@ and trackingLatitude is %@",trackingLongitude,trackingLatitude);
    if ((!([trackingLongitude length] == 0 || [trackingLatitude length] == 0) &&[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil) && ([trackingLongitude floatValue]!=0.0 && [trackingLatitude floatValue]!=0.0))
    {
//        if (![oldTrackingLatitude isEqualToString:trackingLatitude]&&![oldTrackingLongitude isEqualToString:trackingLongitude]) {
            NSArray * DataBaseArray = [[NSArray alloc]initWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],carId,campaignId,[NSNumber numberWithDouble:[trackingLatitude doubleValue]],[NSNumber numberWithDouble:[trackingLongitude doubleValue]],trackingDate,startEndStr,campaignCarId,nil];
            
            oldTrackingLatitude = trackingLatitude;
            oldTrackingLongitude = trackingLongitude;
            NSString *temp=[NSString stringWithFormat:@"insert into LocationTracking values(?,?,?,?,?,?,?,?)"];
            [MyDatabase insertIntoDatabase:[temp UTF8String] tempArray:[NSArray arrayWithArray:DataBaseArray]];
//            trackingLatitude = @"";
//            trackingLongitude =@"";
            startEndStr = @"2";

//        }
    }
    else
    {
//        [remoteTimer invalidate];
//        remoteTimer = nil;
//        [localTimer invalidate];
//        localTimer = nil;
//        isTracking  = false;
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//            [backgroundTimerForService invalidate];
//            backgroundTimerForService = nil;
//            [backgroundTimerForDatabase invalidate];
//            backgroundTimerForDatabase = nil;
//        }];
    }
    //enter lat long in local database
    //use lat long trackingLatitude,trackingLongitude
}

- (void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    
    CLLocationCoordinate2D here = newLocation.coordinate;
    
    if (isStarted) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        trackingDate = [dateFormatter stringFromDate:newLocation.timestamp];
        trackingLatitude = [NSString stringWithFormat:@"%lf",here.latitude];
        trackingLongitude = [NSString stringWithFormat:@"%lf",here.longitude];
       // NSLog(@"lat->%@,long->%@",trackingLatitude,trackingLongitude);
    }
}

- (void)stopTrack {
    // Stop location updates
    isStarted = false;
    startEndStr = @"3";
    [remoteTimer invalidate];
    remoteTimer = nil;
    [localTimer invalidate];
    localTimer = nil;
    isTracking  = false;
    shouldTrack=false;
        [backgroundTimerForService invalidate];
        backgroundTimerForService = nil;
        [backgroundTimerForDatabase invalidate];
        backgroundTimerForDatabase = nil;
    
    
    [self startTrackingForLocalDatabase];
    [myDelegate startTrackingBg];
    trackingLatitude = @"";
    trackingLongitude = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrackBeacon" object:@"stop"];
    [locationManager stopUpdatingLocation];
}
#pragma mark - end

#pragma mark - Exception handler module
void uncaughtExceptionHandler(NSException *exception) {
    [ZDCLog e:@"CRASH: %@", exception];
    [ZDCLog e:@"Stack Trace: %@", [exception callStackReturnAddresses]];
}
#pragma mark - end

#pragma mark - Beacon detection methods
- (void)checkLocationService {

    locationManager = [[CLLocationManager alloc] init];
    isTracking  = true;
    isStarted = true;
    // Set the delegate
    locationManager.delegate = self;
    //--------Remove blue line during background location update-------
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        [locationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
    }
    //--------end
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    NSString *stateString = nil;
    switch(bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateUnsupported:
        {
            isbluetoothOn = false;
            startEndStr = @"3";
            [self stopTrack];
            
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"Settings" actionBlock:^(void) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"Please turn on your device Bluetooth to continue the tracking." closeButtonTitle:@"Cancel" duration:0.0f];
            
//            [UserDefaultManager showAlertMessage:@"Please turn on your device Bluetooth to continue the tracking."];
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            stateString = @"Bluetooth is currently powered off.";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isBluetoothOn" object:[NSNumber numberWithBool:false]];
            break;
        }
        case CBCentralManagerStatePoweredOn: {
            isbluetoothOn = true;
            stateString = @"Bluetooth is currently powered on and available to use.";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isBluetoothOn" object:[NSNumber numberWithBool:true]];
            break;
        }
        default: stateString = @"State unknown, update imminent."; break;
    }
  //  NSLog(@"Bluetooth State: %@",stateString);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [UserDefaultManager showAlertMessage:@"Please turn on your device Bluetooth to continue the tracking."];
}

- (void)startLocationTrackingWithBeacon : (NSArray *)beacons
{
    [UserDefaultManager setValue:[NSDate date] key:@"MethodCallingDate"];
//    NSLog(@"beacons is %@",beacons);
    if (beacons.count>0 && isbluetoothOn &&[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] != nil)
    {
        beaconArray = [beacons mutableCopy];
        if (beacons.count==1)
        {
            ABBeacon *beacon = [beacons objectAtIndex:0];
            if ([[beaconName uppercaseString] isEqualToString:[NSString stringWithFormat:@"%@.%@.%@",[beacon.proximityUUID UUIDString],[NSString stringWithFormat:@"%@",beacon.major],[NSString stringWithFormat:@"%@",beacon.minor]]])
            {
                rangeTimer = 0;
                [UserDefaultManager setValue:@"Yes" key:@"ShouldStartTrack"];
//                NSLog(@"entered in startLocationTrackingWithBeacon line:----------------- 1079");
               
                if (!isTracking)
                {
                    startEndStr = @"1";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrackBeacon" object:@"start"];
//                    NSLog(@"entered in startLocationTrackingWithBeacon line:----------------------- 1084");
//                    if([[UserDefaultManager getValue:@"isBeaconRegistered"]isEqualToString:@"No"]){
//                        
//                        [self startMonitoringForRegion:beacon];
//                    }
                    [self  startTrack];
                }
            }
            else
            {
                [UserDefaultManager setValue:@"No" key:@"ShouldStartTrack"];
                if (isTracking && ![[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Phone"])
                {
                    
                    rangeTimer++;
                    if(rangeTimer>=5)
                    {
                        startEndStr = @"3";
                       [self stopTrack];
                    }
                    
                    
                }
            }
        }
        else if (beacons.count>1)
        {
            
            for (int i = 0; i<beacons.count; i++)
            {
                
                ABBeacon *beacon = [beacons objectAtIndex:i];
                if ([[beaconName uppercaseString] isEqualToString:[NSString stringWithFormat:@"%@.%@.%@",[beacon.proximityUUID UUIDString],[NSString stringWithFormat:@"%@",beacon.major],[NSString stringWithFormat:@"%@",beacon.minor]]])
                {
                    rangeTimer = 0;
                    shouldTrack = true;
                    [UserDefaultManager setValue:@"Yes" key:@"ShouldStartTrack"];
                    if (!isTracking)
                    {
//                        if([[UserDefaultManager getValue:@"isBeaconRegistered"]isEqualToString:@"No"]){
//                            
//                            [self startMonitoringForRegion:beacon];
//                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrackBeacon" object:@"start"];
                        startEndStr = @"1";
                        
//                        NSLog(@"entered in startLocationTrackingWithBeacon line:---------------------- 1111");
                        [self  startTrack];
                    }
                    break;
                }else{
                    shouldTrack = false;
                }
                
            }
//            NSLog(@"shouldTrack is %d",shouldTrack);
            if(isTracking &&!shouldTrack){
                rangeTimer++;
                if(rangeTimer>=5)
                {
                   [self stopTrack];
                }
            }
        }
    }
}

- (void)beaconManagerDidStartAdvertising:(ABBeaconManager *)manager error:(NSError *)error{
    
//    NSLog(@"manager is %@",manager);
}

- (void)beaconManager:(ABBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ABBeaconRegion *)region
{
    if(beacons.count>0){
    [self startLocationTrackingWithBeacon:beacons];
    }
    else{
        if (![beaconDetectionTimer isValid]) {
            beaconDetectionTimer=[NSTimer scheduledTimerWithTimeInterval: 25
                                                                  target: self
                                                                selector: @selector(checkBeaconRange)
                                                                userInfo: nil
                                                                 repeats: YES];
        }
       
    }
}

- (void)checkBeaconRange{
    if ([UserDefaultManager getValue:@"MethodCallingDate"]!=nil){
//    NSLog(@"date is %@",[UserDefaultManager getValue:@"MethodCallingDate"]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:[UserDefaultManager getValue:@"MethodCallingDate"]];
    NSInteger seconds = [components second];
    NSInteger minutes = [components minute];
    NSInteger finaltime = seconds+(minutes*60);
    
//    NSLog(@"date is %@",[UserDefaultManager getValue:@"MethodCallingDate"]);
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSCalendar *calendar1 = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [calendar1 components:(NSCalendarUnitHour | NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:[NSDate date]];
    NSInteger seconds1 = [components1 second];
    NSInteger minutes1 = [components1 minute];
     NSInteger finaltime1 = seconds1+(minutes1*60);
//    NSLog(@"finalTime is %ld and finaltime1 is %ld",(long)finaltime,(long)finaltime1);
    NSInteger finalValue=finaltime1-finaltime;
    if (finalValue>25 &&isTracking) {
        [UserDefaultManager setValue:nil key:@"MethodCallingDate"];
        [self stopTrack];
    }
    }
}

- (void)beaconManager:(ABBeaconManager *)manager rangingBeaconsDidFailForRegion:(ABBeaconRegion *)region withError:(NSError *)error
{
//    NSLog(@"error is %@",error);
}

- (void)enteredInRegion
{
    if ([[UserDefaultManager getValue:@"ShouldStartTrack"] isEqualToString:@"Yes"])
    {
        startEndStr = @"1";
        [self startTrack];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"isTrackBeacon" object:@"start"];
    }
//    NSLog(@"enteredInRegion..........................................................");
}

- (void)exitFromRegion
{
    //[UserDefaultManager setValue:@"No" key:@"ShouldStartTrack"];
//    startEndStr = @"3";
//    if (isTracking) {
//        [self stopTrack];
//    }
    
//    NSLog(@"exitFromRegion..........................................................");
}

- (void)startRangeBeacons
{
    [self stopRangeBeacons];
    bluetoothManager = [[CBCentralManager alloc] initWithDelegate:myDelegate
                                                            queue:nil
                                                          options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                              forKey:CBCentralManagerOptionShowPowerAlertKey]];
    ABTransmitters *tran = [ABTransmitters sharedTransmitters];
    [[tran transmitters] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:obj[@"uuid"]];
        NSString *regionIdentifier = obj[@"uuid"];
        
        ABBeaconRegion *beaconRegion;
        beaconRegion = [[ABBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                          identifier:regionIdentifier];
        beaconRegion.notifyOnEntry = YES;
        beaconRegion.notifyOnExit = YES;
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [self.beaconManager startRangingBeaconsInRegion:beaconRegion];
    }];
}

- (void)stopRangeBeacons
{
    ABTransmitters *tran = [ABTransmitters sharedTransmitters];
    [[tran transmitters] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:obj[@"uuid"]];
        NSString *regionIdentifier = obj[@"uuid"];
        
        ABBeaconRegion *beaconRegion;
        beaconRegion = [[ABBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                          identifier:regionIdentifier];
        [self.beaconManager stopRangingBeaconsInRegion:beaconRegion];
    }];
}

- (void)beaconManager:(ABBeaconManager *)manager
    didDetermineState:(CLRegionState)state
            forRegion:(ABBeaconRegion *)region
{
    // NSLog(@"region is %@ state is %ld",region,(long)state);
}

- (void)beaconManager:(ABBeaconManager *)manager didEnterRegion:(ABBeaconRegion *)region
{
//    NSLog(@"didEnterRegion");
//    [self enteredInRegion];
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"Auto Mileage Tracker Activated";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)beaconManager:(ABBeaconManager *)manager didExitRegion:(ABBeaconRegion *)region
{
    [self exitFromRegion];
//    NSLog(@"didExitRegion");
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"Exit monitoring region";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)startMonitoringForRegion : (ABBeacon *)beacon
{
//    [UserDefaultManager setValue:@"Yes" key:@"isBeaconRegistered"];
    self.region = [[ABBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID identifier:beacon.proximityUUID.UUIDString];
    self.region.notifyOnEntry =true;
    self.region.notifyOnExit = true;
    self.region.notifyEntryStateOnDisplay = YES;
    [_beaconManager startMonitoringForRegion:self.region];
}
#pragma mark -end

@end
