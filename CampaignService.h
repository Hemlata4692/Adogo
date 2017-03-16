//
//  CampaignService.h
//  Adogo
//
//  Created by Sumit on 03/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BidInfoModel.h"

@interface CampaignService : NSObject
{
    bool isTrackingService;
}

//Shared instance
+ (id)sharedManager;
//end
//Dashboard service
- (void)getDashboardDetail:(NSString *)dashboardTrackingLongitude dashboardLatitude:(NSString *)dashboardTrackingLatitude onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Fetch question detail
- (void)getQuestionDetail:(NSString *)questionId onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Fetch question detail
- (void)setQuestionDetail:(NSString *)questionId submitText:(NSString *)submitText onSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;
//Set question detail
//Get installation type
- (void)getInstallationType:(NSString *)bidId campaignId:(NSString *)campaignId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//Get bid info service
- (void)getBidInfoService:(NSString *)bidId carId:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Accept reject campaign bid service
- (void)acceptRejectCampaignbidService:(NSString *)bidId campaignId:(NSString *)campaignId bidAmount:(NSString *)bidAmount signatureImage:(NSString *)signatureImage rejectReason:(NSString *)rejectReason isAccept:(NSString *)isAccept previewDataModel:(BidInfoModel*)previewData success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Facebook connect service
- (void)facebookConnectService:(NSString *)facebookId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Accept reject installer request service
- (void)acceptRejectInstallerRequest:(NSString *)scheduleId scheduleStatus:(NSString *)scheduleStatus campaignId:(NSString *)campaignId defaultCarId:(NSString *)defaultCarId campaignCarId:(NSString *)campaignCarId installationJobId:(NSString *)installationJobId installerId:(NSString *)installerId platNumber:(NSString *)platNumber success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Set location service
- (void)setInstallationService:(NSString *)bidId carId:(NSString *)carId InstallationType:(NSString *)InstallationType InstallationNote:(NSString *)InstallationNote amLocation:(NSString *)amLocation amPostalCode:(NSString *)amPostalCode amLat:(NSString *)amLat amLng:(NSString *)amLng pmLocation:(NSString *)pmLocation pmPostalCode:(NSString *)pmPostalCode pmLat:(NSString *)pmLat pmLng:(NSString *)pmLng success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Set installed sticker
- (void)setInstalledSticker:(NSString *)installation_job_schedule_id stickerImageArray:(NSMutableArray *)stickerImageArray success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get remove methods service
- (void)getRemoveMethods:(void (^)(id))success failure:(void (^)(NSError *))failure;
//Set GPS track data service
- (void)setGPSTrackDataService:(NSMutableArray *)trackInfo success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Set campaign end data
- (void)setCampaignEndData:(NSString *)campaignId carId:(NSString *)carId campaignCarsId:(NSString *)campaignCarsId installationRemoveType:(NSString *)installationRemoveType imageNames:(NSMutableDictionary *)CE success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//point redemption services
- (void)getMerchantList:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)getCategoryList:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)getRedemptionItemList:(NSString *)categoryId merchantId:(NSString *)merchantId pageOffset:(NSString *)pageOffset success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//Set app setting service
- (void)setAppSetting:(NSString *)trackingMethod uniqueIdentifier:(NSString *)uniqueIdentifier daily_milage_report:(NSString *)daily_milage_report is_notification_on:(NSString *)is_notification_on success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Redeem history
- (void)getRedeemHistory:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get payment history
- (void)getPaymentHistory:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Campaign history
- (void)getCampaignHistory:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Ambassador history
- (void)getAmbassadorHistory:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Delete account
- (void)deleteAccount:(void (^)(id))success failure:(void (^)(NSError *))failure;
//Current date time
- (void)getCurrentDateTimeService:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Set installed sticker
- (void)addRequestedPhotos:(NSString *)carId campaignId:(NSString *)campaignId imageArray:(NSMutableArray *)imageArray latitude:(NSString *)latitude longitude:(NSString *)longitude success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get bonus job
- (void)getBonusJob:(NSString *)offerId campaignCarId:(NSString *)campaignCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Accept/Reject bonus job
- (void)acceptRejectOffer:(NSString *)status offerCarId:(NSString *)offerCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Get estimated mileage
- (void)getEstimatedMileageMonthly:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get profile status
- (void)getProfileStatus:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get notification history
- (void)getNotificationHistory:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//pragma mark - Ambassador history
- (void)getAmbassadorPostList:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get default car information
- (void)getDefaultCarSetting:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
@end
