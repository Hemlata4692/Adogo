//
//  CampaignService.m
//  Adogo
//
//  Created by Sumit on 03/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CampaignService.h"
#import "MyDatabase.h"
#import "BidInfoModel.h"
#define kUrlDashboardDetails                 @"getdashboarddetail"
#define kUrlFetchquestiondetail              @"fetchquestiondetail"
#define kUrlgetInstallationType              @"getinstallationtype"
#define kUrlAcceptRejectCampaignbId          @"acceptrejectcampaignbid"
#define kUrlDashboardDetails                 @"getdashboarddetail"
#define kUrlGetBidInfo                       @"getbidinfo"
#define kUrlFacebookConnect                  @"facebookconnect"
#define kUrlAcceptRejectInstallerRequest     @"confirminstallationtiming"
#define kUrlsetInstallationLocation          @"setinstallationtype"
#define kUrlSetInstalledSticker              @"setinstalledsticker"
#define kUrlGetRemoveMethods                 @"removemethods"
#define kUrlStoreTrackData                   @"storetrackdata"
#define kUrlSetCampaignEndData               @"setcampaignenddata"
#define kUrlGetMerchantList                  @"getmerchantlist"
#define kUrlGetCategoryList                  @"categorylisting"
#define kUrlSetAppSetting                    @"setappsetting"
#define kUrlGetPointRedemptionList           @"productlisting"
#define kUrlGetRedeemHistory                 @"redemhistory"
#define kUrlGetPaymentHistory                @"paymenthistory"
#define kUrlGetCampaignHistory               @"campaignhistory"
#define kUrlGetAmbassadorHistory             @"ambassadorhistory"
#define kUrlDeactivateAccount                @"deactivateaccount"

#define kUrlGetCurrentDate                   @"getcurrentdate"
#define kUrlDeactivateAccount                @"deactivateaccount"
#define kUrlAddRequestedPhotos               @"addrequestphotos"
#define kUrlGetEstimatedMileage              @"estimatedmontly"
#define kUrlGetBonusJob                      @"getbonusjob"
#define kUrlFetchProfile                     @"fetchprofile"
#define kUrlGetNotificationHistory           @"notificationhistory"
#define kUrlGetAmabassdorPostList            @"amabassdorpostlist"

#define kUrlDefaultCarAppSetting             @"defaultcarappsetting"
#define kUrlacceptReject                     @"setofferaction"
//campaignhistory
@implementation CampaignService

#pragma mark - Shared instance
+ (id)sharedManager {
    static CampaignService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init
{
    return self;
}
#pragma mark - end

#pragma mark - Dashboard service
- (void)getDashboardDetail:(NSString *)dashboardTrackingLongitude dashboardLatitude:(NSString *)dashboardTrackingLatitude onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    NSDictionary *requestDict;
    if ((dashboardTrackingLatitude==nil)||(dashboardTrackingLatitude==NULL)||[dashboardTrackingLatitude isEqualToString:@""]) {
        requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    }
    else {
        requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"cars_last_location":@{
                                @"lat":dashboardTrackingLatitude,
                                @"lng":dashboardTrackingLongitude
                                }};
    }
    
    //NSLog(@"getDashboardDetail request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlDashboardDetails parameters:requestDict success:^(id responseObject) {
        //NSLog(@"getDashboardDetail Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Fetch question detail
- (void)getQuestionDetail:(NSString *)questionId onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict=@{@"user_id":[UserDefaultManager getValue:@"userId"],@"question_id":[NSNumber numberWithInt:[questionId intValue]], @"user_answer":@""};
    //NSLog(@"Get question detail request%@", requestDict);
    
    [[Webservice sharedManager] postQuestion:kUrlFetchquestiondetail parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Get question detail Response%@", responseObject);
        [myDelegate stopIndicator];
        success(responseObject);

    } failure:^(NSError *error) {
        
        [myDelegate stopIndicator];
        failure(error);
    }];
}

- (void)setQuestionDetail:(NSString *)questionId submitText:(NSString *)submitText onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict=@{@"user_id":[UserDefaultManager getValue:@"userId"],@"question_id":[NSNumber numberWithInt:[questionId intValue]], @"user_answer":submitText};
    //NSLog(@"Get question detail request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlFetchquestiondetail parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Get question detail Response%@", responseObject);
        [myDelegate stopIndicator];
        
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
        
    } failure:^(NSError *error) {
        
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Bid info service
- (void)getBidInfoService:(NSString *)bidId carId:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure {
        
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"bid_id":bidId,@"car_id":carId};
    [[Webservice sharedManager] post:kUrlGetBidInfo parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            [myDelegate stopIndicator];
            failure(responseObject);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Add more photos
- (void)addRequestedPhotos:(NSString *)carId campaignId:(NSString *)campaignId imageArray:(NSMutableArray *)imageArray latitude:(NSString *)latitude longitude:(NSString *)longitude success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"campaign_id":campaignId,@"campaign_car_id":carId,@"other":imageArray, @"car_location":@{
                                        @"lat":latitude,@"lng":longitude
                                          }};
    
    //NSLog(@"upload photo  request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlAddRequestedPhotos parameters:requestDict success:^(id responseObject) {
        //NSLog(@"upload photo Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            [myDelegate stopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Accept reject campaign bid service
- (void)acceptRejectCampaignbidService:(NSString *)bidId campaignId:(NSString *)campaignId bidAmount:(NSString *)bidAmount signatureImage:(NSString *)signatureImage rejectReason:(NSString *)rejectReason isAccept:(NSString *)isAccept previewDataModel:(BidInfoModel*)previewData success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"bid_id":bidId, @"campaign_id":campaignId, @"driver_bid_amount":bidAmount, @"driver_signature_image":signatureImage, @"driver_note":rejectReason, @"status" : ([isAccept boolValue] ? [NSNumber numberWithBool:true] : [NSNumber numberWithBool:false]),@"avg_bid_amount" : previewData.avgBidAmount, @"campaign_brand" : previewData.brand,
                                  @"campaign_name" : previewData.campaignName,
                                  @"carowner_name" : previewData.carOwnerName,
                                  @"maxBid" : previewData.maxBid,
                                  @"plate_number" : previewData.carPlateNumber
                                  };
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlAcceptRejectCampaignbId parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            [myDelegate stopIndicator];
            failure(responseObject);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Accept reject installer request
- (void)acceptRejectInstallerRequest:(NSString *)scheduleId scheduleStatus:(NSString *)scheduleStatus campaignId:(NSString *)campaignId defaultCarId:(NSString *)defaultCarId campaignCarId:(NSString *)campaignCarId installationJobId:(NSString *)installationJobId installerId:(NSString *)installerId platNumber:(NSString *)platNumber success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
   NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"installation_job_schedule_id":scheduleId, @"schedule_status":scheduleStatus,@"campaign_id":campaignId,@"default_car_id":defaultCarId,@"campaign_car_id":campaignCarId,@"installation_job_id":installationJobId, @"installer_id":installerId,@"plate_number":platNumber,@"car_owner_name":[UserDefaultManager getValue:@"userName"]};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlAcceptRejectInstallerRequest parameters:requestDict success:^(id responseObject)
    {
        //NSLog(@"Response%@", responseObject);
        
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            [myDelegate stopIndicator];
            success(responseObject);
        }
        else {
            [myDelegate stopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Set installation location
- (void)setInstallationService:(NSString *)bidId carId:(NSString *)carId InstallationType:(NSString *)InstallationType InstallationNote:(NSString *)InstallationNote amLocation:(NSString *)amLocation amPostalCode:(NSString *)amPostalCode amLat:(NSString *)amLat amLng:(NSString *)amLng pmLocation:(NSString *)pmLocation pmPostalCode:(NSString *)pmPostalCode pmLat:(NSString *)pmLat pmLng:(NSString *)pmLng success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict;
    @try {
    requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId, @"bid_id":bidId,@"installation_type":InstallationType,@"installation_note":InstallationNote,@"afternoon_location": @{
                                          @"postal_code":amPostalCode,
                                          @"latitude":amLat,
                                          @"longitude":amLng,
                                          @"address":amLocation
                                          },
                                          @"night_location": @{
                                          @"postal_code":pmPostalCode,
                                          @"latitude":pmLat,
                                          @"longitude":pmLng,
                                          @"address":pmLocation
                                          }
                                  };
    }
    @catch (NSException *exception) {
        
        //NSLog(@"exception is %@",exception);
    }
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlsetInstallationLocation parameters:requestDict success:^(id responseObject)
     {
         //NSLog(@"Response%@", responseObject);
         
         if([[Webservice sharedManager] isStatusOK:responseObject])
         {
             [myDelegate stopIndicator];
             success(responseObject);
         }
         else {
             [myDelegate stopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate stopIndicator];
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Get installation type
- (void)getInstallationType:(NSString *)bidId campaignId:(NSString *)campaignId success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"bid_id":bidId,@"campaign_id":campaignId};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlgetInstallationType parameters:requestDict success:^(id responseObject) {
        //NSLog(@"getInstallationType Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
    {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Facebook connect service
- (void)facebookConnectService:(NSString *)facebookId success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"facebookId":facebookId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlFacebookConnect parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            [myDelegate stopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Get installation type
- (void)setInstalledSticker:(NSString *)installation_job_schedule_id stickerImageArray:(NSMutableArray *)stickerImageArray success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString * result = [stickerImageArray componentsJoinedByString:@","];
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"installation_job_schedule_id":installation_job_schedule_id, @"installation_job_pics_driver":result};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlSetInstalledSticker parameters:requestDict success:^(id responseObject) {
        //NSLog(@"getInstallationType Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         [myDelegate stopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Get remove methods service
- (void)getRemoveMethods:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [[Webservice sharedManager] post:kUrlGetRemoveMethods parameters:nil success:^(id responseObject) {
        //NSLog(@"getRemoveMethods Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Get installation type
- (void)setGPSTrackDataService:(NSMutableArray *)trackInfo success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
  
    myDelegate.testingCarId=[NSString stringWithFormat:@"%d",[[[trackInfo objectAtIndex:trackInfo.count-1] objectForKey:@"car_id"] intValue]];
    myDelegate.testingStartEndString=[NSString stringWithFormat:@"%d",[[[trackInfo objectAtIndex:trackInfo.count-1] objectForKey:@"is_start_stop"] intValue]];
    
    [UserDefaultManager setValue:@"Yes" key:@"isTrackingMethod"];
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"track_info":trackInfo,@"device_type" : [NSString stringWithFormat:@"iOS-%@",[[UIDevice currentDevice] model]]};
    //NSLog(@"getInstallationType request%@", requestDict);
    NSString *resquestStr =[NSString stringWithFormat:@"%@",requestDict];
    [[Webservice sharedManager] postTrackingData:requestDict success:^(id responseObject) {
        //NSLog(@"getInstallationType Response%@", responseObject);
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        //NSLog(@"%@",dateString);
        
        if (myDelegate.isEnableTrackLogEmail==1) {
            NSArray * DataBaseArray = [[NSArray alloc]initWithObjects:resquestStr,dateString, nil];
            [self callCrashWebservice:[NSString stringWithFormat:@"%@",[DataBaseArray componentsJoinedByString:@","]]];
        }
        

        
            success(responseObject);
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}

- (void)callCrashWebservice :(NSString *)crashString {
    
    NSDictionary *requestDict = @{@"content":crashString,@"to":@"rohit@ranosys.com",@"subject":[NSString stringWithFormat:@"Adogo tracking: userId->%@, carid->%@, startEnd->%@",[UserDefaultManager getValue:@"userId"],myDelegate.carId,myDelegate.testingStartEndString]};
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://ranosys.net/client/starrez/crash.php"]];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"data is %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [postDataTask resume];
}
#pragma mark - end

#pragma mark - Get redeem history
- (void)getRedeemHistory:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetRedeemHistory parameters:requestDict success:^(id responseObject)
    {
        [myDelegate stopIndicator];
        success(responseObject);
        
    } failure:^(NSError *error)
     {
         [myDelegate stopIndicator];
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Set campaign end
- (void)setCampaignEndData:(NSString *)campaignId carId:(NSString *)carId campaignCarsId:(NSString *)campaignCarsId installationRemoveType:(NSString *)installationRemoveType imageNames:(NSMutableDictionary *)CE success: (void (^)(id))success failure:(void (^)(NSError *))failure {

    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"campaign_id":campaignId,@"car_id":carId,@"campaign_car_id":campaignCarsId,@"installation_remove_type":installationRemoveType, @"CE":CE};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlSetCampaignEndData parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - point redemption services
- (void)getMerchantList:(void (^)(id))success failure:(void (^)(NSError *))failure
{
     NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    [[Webservice sharedManager] post:kUrlGetMerchantList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"getRemoveMethods Response%@", responseObject);
        
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}

- (void)getCategoryList:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    [[Webservice sharedManager] post:kUrlGetCategoryList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"getRemoveMethods Response%@", responseObject);
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}

- (void)getRedemptionItemList:(NSString *)categoryId merchantId:(NSString *)merchantId pageOffset:(NSString *)pageOffset success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"category_id":categoryId,@"merchant_id":merchantId,@"offset":pageOffset};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetPointRedemptionList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else
        {
            success(responseObject);
        }
    } failure:^(NSError *error)
     {
         [myDelegate stopIndicator];
         failure(error);
     }];
}
#pragma mark -end

#pragma mark - Current date time
- (void)getCurrentDateTimeService:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getAmbassadorHistory request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetCurrentDate parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Set app setting
- (void)setAppSetting:(NSString *)trackingMethod uniqueIdentifier:(NSString *)uniqueIdentifier daily_milage_report:(NSString *)daily_milage_report is_notification_on:(NSString *)is_notification_on success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"], @"tracking_method":trackingMethod, @"uniqueIdentifier":uniqueIdentifier, @"daily_milage_report":daily_milage_report, @"is_notification_on":is_notification_on};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlSetAppSetting parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Get payment history
- (void)getPaymentHistory:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getPaymentHistory request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetPaymentHistory parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Get campaign history
- (void)getCampaignHistory:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    //NSLog(@"campaign request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetCampaignHistory parameters:requestDict success:^(id responseObject)
     {
          //NSLog(@"Response%@", responseObject);
         [myDelegate stopIndicator];
         success(responseObject);
         
     } failure:^(NSError *error)
     {
         [myDelegate stopIndicator];
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Get estimated mileage
- (void)getEstimatedMileageMonthly:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getPaymentHistory request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetEstimatedMileage parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Ambassador history
- (void)getAmbassadorHistory:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getAmbassadorHistory request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetAmbassadorHistory parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        
            success(responseObject);
        
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Delete account
- (void)deleteAccount:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"deleteAccount request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlDeactivateAccount parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        
            success(responseObject);
        
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Get bonus job
- (void)getBonusJob:(NSString *)offerId campaignCarId:(NSString *)campaignCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"offer_car_id":offerId, @"campaign_car_id":campaignCarId};
    
    //NSLog(@"getBonusJob request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetBonusJob parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}

- (void)acceptRejectOffer:(NSString *)status offerCarId:(NSString *)offerCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"offer_car_id":offerCarId, @"status":status};
    
    //NSLog(@"getBonusJob request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlacceptReject parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Get profile status
- (void)getProfileStatus:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"deleteAccount request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlFetchProfile parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Notification history
- (void)getNotificationHistory:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getNotificationHistory request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetNotificationHistory parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Ambassador history
- (void)getAmbassadorPostList:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    
    //NSLog(@"getAmbassador Post list request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetAmabassdorPostList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

#pragma mark - Set app setting
- (void)getDefaultCarSetting:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    //NSLog(@"getInstallationType request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlDefaultCarAppSetting parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([[Webservice sharedManager] isStatusOK:responseObject])
        {
            success(responseObject);
        }
        else {
            failure(nil);
        }
    } failure:^(NSError *error)
     {
         failure(error);
     }];
}
#pragma mark - end

@end
