//
//  AppDelegate.h
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AprilBeaconSDK.h>

typedef enum
{
    FBAmbassadorPostNotification = 2,
    AddMoreCarImageNotification = 4,
    AddCarDimensionNotification = 5,
    ApproveCarNotification = 6,
    BidAssignedNotification = 7,
    BidExpiryReminderNotification = 8,
    BidApproveNotification = 10,
    InstallerAssignedNotification = 11,
    InstallationScheduleNotification = 12,
    InstallerOnTheWayNotification = 18,
    StartJobInstallation = 19,
    InstallationErrorNotification = 20,
    InstallationJobCompletedNotification = 21,
    campaignEndNotification = 25,
    MorePhotoDuringCampaignNotification = 27,
    BonusJobNotification = 28,
    ApproveCarDimensionNotification = 30,
    RejectCarDimensionNotification = 31,
    CampaignEndProcedureAcceptRejectNotification = 32,
    DeleteSchedulNotification = 33,
    PaymentNotification = 36,
    RedemNotification = 40,
    NRICDeleted = 44
} NotificationHander;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,ABBeaconManagerDelegate> {
    
    CLLocationManager *locationManager;
    NSTimer *remoteTimer, *localTimer,  *beaconTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain) UINavigationController *navigationController;
@property(nonatomic,retain) UINavigationController *currentNavController;
@property(nonatomic,retain)UIImage * sideBarImage;
@property(nonatomic,retain)NSString * popupText;
@property(nonatomic,assign)int  alertCount;
@property(nonatomic,assign)int  facebookCount;
@property(nonatomic,assign)bool isAmbassadorPost;
@property(nonatomic,assign)bool isAmbassadorPostListing;
@property(nonatomic,assign)bool isLogout;
@property(nonatomic,retain)NSString * currentPresentViewName;

@property(nonatomic,retain)NSString *myPresentView;
@property(nonatomic,retain)NSMutableDictionary *notificationDict;
@property(nonatomic,retain)NSString * beaconName;
//Database variables
@property(nonatomic,retain)NSString * carId;
@property(nonatomic,retain)NSString * campaignId;
@property(nonatomic,retain)NSString * campaignCarId;
@property(nonatomic,retain)NSString * startEndStr;
@property (nonatomic, strong) ABBeaconManager *beaconManager;
@property (nonatomic ,retain)NSMutableArray * beaconArray;
@property(nonatomic,assign)bool isGetNotification;

@property(nonatomic,retain)NSString * methodName;
@property(nonatomic,assign)bool isbluetoothOn;

//Testing variables for log tracking
@property(nonatomic,retain)NSString *testingStartEndString;
@property(nonatomic,retain)NSString *testingCarId;
//end

@property(nonatomic,assign)int locationUpdateTimeDifference; //Get dynamic time from dashboard service
@property(nonatomic,assign)int isEnableTrackLogEmail;
//bool for checking proper date format in offer feed
@property(nonatomic,assign) bool isValidDate;
//Indicator method
- (void)showIndicator:(NSString*)title;
- (void)showIndicator;
- (void)stopIndicator;
//AWS method
- (void)startImageDownloading:(NSString *)ImageName;
//end

//Use for start and stop location tracking
- (void)startTrack;
- (void)stopTrack;
//end

@property (nonatomic) int selScreenState;
@property (nonatomic) bool isStarted;
@property (nonatomic,retain) CBCentralManager *bluetoothManager;
- (void)registerDeviceForNotification;
- (void)unrigisterForNotification;
- (void)awsConfugration;
- (void)startRangeBeacons;
- (void)stopRangeBeacons;
- (void)startTrackingBg;
- (void)startMonitoringForRegion : (ABBeacon *)beacon;
- (void)checkLocationService;
@end
