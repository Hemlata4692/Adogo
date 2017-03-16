//
//  CarService.h
//  Adogo
//
//  Created by Sumit on 29/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarService : NSObject

//Shared instance
+ (id)sharedManager;
//end
//Car listing service
- (void)getCarListing:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Set default
- (void)setDefaultCar:(NSString *)carId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get car brand list
- (void)getCarBrandListing:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get car brand list
- (void)getCarModelListing:(NSString *)brandId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Add car
- (void)addEditCarService:(NSString *)plate_number imageDict:(NSDictionary *)imageDict car_id:(NSString *)car_id brand:(NSString *)brand model:(NSString *)model color:(NSString *)color car_type:(NSString *)car_type is_owner:(NSNumber *)is_owner owner_name:(NSString *)owner_name owner_nric:(NSString *)owner_nric special_note:(NSString *)special_note awsFolderName:(NSString *)awsFolderName is_default_car:(NSString *)is_default_car old_plate_number:(NSString *)old_plate_number success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get car details
- (void)carDetailService:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Get car route listing
- (void)carRouteService:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Edit/Add car route
- (void)addEditCarRouteService:(NSString *)carId routeId:(NSString *)routeId routeData:(NSArray *)routeData success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Add car measurement
- (void)addCarMeasurementService:(NSString *)carId measurementData:(NSMutableArray*) measurementData isUpdated:(NSString *)isUpdated success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Delete car
- (void)deleteCar:(NSString *)carId deletedReason:(NSString *)deletedReason newDefaultCarId:(NSString *)newDefaultCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Parking Data Service
- (void)setParkingDataService:(NSString *)installation_job_schedule_id car_owner_status:(NSString *)car_owner_status car_parking_block:(NSString *)car_parking_block car_parking_level:(NSString *)car_parking_level car_parking_lotno:(NSString *)car_parking_lotno car_parking_note:(NSString *)car_parking_note car_parking_lat:(NSString *)car_parking_lat car_parking_long:(NSString *)car_parking_long imageName:(NSMutableArray *)imageName carId:(NSString *)carId address:(NSString *)address success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Redeem Point
- (void)redeemProductdetail:(NSString *)productId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
//Redeem porduct apply service
- (void)redeemProductAppleyService:(NSString *)productId success: (void (^)(id))success failure:(void (^)(NSError *))failure;
//end
@end
