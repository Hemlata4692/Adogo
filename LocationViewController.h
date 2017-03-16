//
//  LocationViewController.h
//  Adogo
//
//  Created by Monika on 05/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EditCarRouteViewController.h"
@interface LocationViewController : GlobalBackViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property(nonatomic,assign)bool isfrom;
@property(nonatomic,retain)EditCarRouteViewController * objEditCarRoute;
@end
