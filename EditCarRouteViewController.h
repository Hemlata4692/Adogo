//
//  EditCarRouteViewController.h
//  Adogo
//
//  Created by Monika on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCarRouteViewController : GlobalBackViewController

@property(nonatomic,retain)NSString * fromAddress;
@property(nonatomic,retain)NSString * toAddress;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, assign) NSString *routeId;
@property(nonatomic,retain) NSString * startTime;
@property (nonatomic,retain)NSString* endTime;
@property(nonatomic,retain)NSMutableArray * selectedDays;
@property (nonatomic,assign)CLLocationCoordinate2D fromCordinates;
@property (nonatomic,assign)CLLocationCoordinate2D toCordinates;
@end
