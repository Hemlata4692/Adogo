//
//  CarService.m
//  Adogo
//
//  Created by Sumit on 29/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarService.h"

#define kUrlCarListing                 @"getcarlisting"
#define kUrlSetDefaultCar              @"setdefaultcar"
#define kUrlGetBrandList               @"brands"
#define kUrlGetModelList               @"fetchbrandmodels"
#define kUrlAddEditCar                 @"addeditcar"
#define kUrlCarDetail                  @"cardetail"
#define kUrlCarRouteList               @"carroutelist"
#define kUrlEditAddCarRoute            @"addeditcarroutes"
#define kUrlDeleteCar                  @"deletecar"
#define kUrlAddCarMeasurement          @"addcarmeasurement"
#define kUrlSetParkingData             @"setparkingdata"
#define kUrlRedeemProductDetail        @"productdetail"
#define kUrlRedeemProductApply         @"redeemproductapply"

@implementation CarService

#pragma mark - Shared instance
+ (id)sharedManager {
    static CarService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    return self;
}
#pragma mark - end

#pragma mark - Car listing service
- (void)getCarListing:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlCarListing parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        
       
             success(responseObject);
        
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Set default car
- (void)setDefaultCar:(NSString *)carId success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlSetDefaultCar parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
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

#pragma mark - Car brand listing service
- (void)getCarBrandListing:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"]};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetBrandList parameters:requestDict success:^(id responseObject) {
        
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([responseObject[@"status"] intValue] == 200)
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

#pragma mark - Car model listing service
- (void)getCarModelListing:(NSString *)brandId success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"brand_id":brandId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlGetModelList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if([responseObject[@"status"] intValue] == 200)
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

#pragma mark - Add edit car service
- (void)addEditCarService:(NSString *)plate_number imageDict:(NSDictionary *)imageDict car_id:(NSString *)car_id brand:(NSString *)brand model:(NSString *)model color:(NSString *)color car_type:(NSString *)car_type is_owner:(NSNumber *)is_owner owner_name:(NSString *)owner_name owner_nric:(NSString *)owner_nric special_note:(NSString *)special_note awsFolderName:(NSString *)awsFolderName is_default_car:(NSString *)is_default_car old_plate_number:(NSString *)old_plate_number success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"car_id":car_id ,@"user_id":[UserDefaultManager getValue:@"userId"],@"plate_number" :plate_number,@"plate_color":@"", @"brand":brand, @"model":model,@"year":@"", @"color" :color, @"car_type":car_type,@"is_owner":is_owner,@"owner_name":owner_name, @"owner_nric" :owner_nric, @"is_default_car":is_default_car, @"advertisement_type":@"",@"special_note" :special_note, @"gps_device_id":@"", @"is_ibeacon":@"",@"carImages":imageDict ,@"awsFolderName":awsFolderName, @"old_plate_number":old_plate_number};
        
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlAddEditCar parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
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

#pragma mark - Get car route listing
- (void)addCarMeasurementService:(NSString *)carId measurementData:(NSMutableArray *) measurementData isUpdated:(NSString *)isUpdated success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    NSMutableArray *carMeasurementDetails = [NSMutableArray new];
    for (int i = 0; i < measurementData.count; i++) {
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setObject:[[measurementData objectAtIndex:i] objectForKey:@"id"] forKey:@"field_id"];
        [tempDict setObject:[[measurementData objectAtIndex:i] objectForKey:@"measurLength"] forKey:@"length"];
        [tempDict setObject:[[measurementData objectAtIndex:i] objectForKey:@"measurHeigth"] forKey:@"width"];
        [carMeasurementDetails addObject:tempDict];
    }
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId, @"carMeasurementDetails": carMeasurementDetails, @"isUpdated":[ NSNumber numberWithInt:[isUpdated intValue]]};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlAddCarMeasurement parameters:requestDict success:^(id responseObject) {
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

#pragma mark - Car detail service
- (void)carDetailService:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlCarDetail parameters:requestDict success:^(id responseObject) {
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

#pragma mark - Get car route listing
- (void)carRouteService:(NSString *)carId success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlCarRouteList parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        
            success(responseObject);
        
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        failure(error);
    }];
}
#pragma mark - end

#pragma mark - Edit/Add car route
- (void)addEditCarRouteService:(NSString *)carId routeId:(NSString *)routeId routeData:(NSArray *)routeData success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary * routeDict = @{@"days":[[routeData objectAtIndex:0] objectForKey:@"days"],@"to_time":[[routeData objectAtIndex:0] objectForKey:@"to_time"],@"from_time":[[routeData objectAtIndex:0] objectForKey:@"from_time"]};
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId,@"route_id":routeId,@"from_address":[[routeData objectAtIndex:0] objectForKey:@"from_address"],@"to_address":[[routeData objectAtIndex:0] objectForKey:@"to_address"],@"route_data":routeDict};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlEditAddCarRoute parameters:requestDict success:^(id responseObject) {
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

#pragma mark - Delete car
- (void)deleteCar:(NSString *)carId deletedReason:(NSString *)deletedReason newDefaultCarId:(NSString *)newDefaultCarId success: (void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"car_id":carId,@"deleted_reason":deletedReason,@"default_car_id":newDefaultCarId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlDeleteCar parameters:requestDict success:^(id responseObject) {
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

#pragma mark - Parking data service
- (void)setParkingDataService:(NSString *)installation_job_schedule_id car_owner_status:(NSString *)car_owner_status car_parking_block:(NSString *)car_parking_block car_parking_level:(NSString *)car_parking_level car_parking_lotno:(NSString *)car_parking_lotno car_parking_note:(NSString *)car_parking_note car_parking_lat:(NSString *)car_parking_lat car_parking_long:(NSString *)car_parking_long imageName:(NSMutableArray *)imageName carId:(NSString *)carId address:(NSString *)address success: (void (^)(id))success failure:(void (^)(NSError *))failure {
    
    NSDictionary *locationDict = @{@"lat":car_parking_lat, @"lng":car_parking_long, @"car_parking_address":address};
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"], @"installation_job_schedule_id":installation_job_schedule_id, @"car_owner_status":car_owner_status,@"car_parking_block":car_parking_block, @"car_parking_level":car_parking_level, @"car_parking_lotno":car_parking_lotno, @"car_parking_pic" :imageName , @"car_parking_note" : car_parking_note,@"car_id":carId,@"car_parking_location":locationDict};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlSetParkingData parameters:requestDict success:^(id responseObject) {
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

#pragma mark - Redeem product detail service
- (void)redeemProductdetail:(NSString *)productId success: (void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"product_id":productId};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlRedeemProductDetail parameters:requestDict success:^(id responseObject) {
        //NSLog(@"Response%@", responseObject);
        [myDelegate stopIndicator];
        if(([responseObject[@"status"] intValue] == 400) || [[Webservice sharedManager] isStatusOK:responseObject])
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

#pragma mark - Redeem product detail service
- (void)redeemProductAppleyService:(NSString *)productId success: (void (^)(id))success failure:(void (^)(NSError *))failure {
  
    NSDictionary *requestDict = @{@"user_id":[UserDefaultManager getValue:@"userId"],@"product_id":productId, @"default_car_plate_number":[UserDefaultManager getValue:@"defaultCarPlatNumber"],@"carowner_name":[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"],@"default_car_id":[UserDefaultManager getValue:@"defaultCarId"]};
    //NSLog(@"request%@", requestDict);
    
    [[Webservice sharedManager] post:kUrlRedeemProductApply parameters:requestDict success:^(id responseObject) {
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
@end
