//
//  LocationViewController.m
//  Adogo
//
//  Created by Monika on 05/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "LocationViewController.h"
#import "Internet.h"
#import "SCLAlertView.h"

@import MapKit;
@import GoogleMaps;

@interface LocationViewController ()<GMSMapViewDelegate>
{
    GMSCameraPosition *camera;
    GMSMarker *marker;
    float currentZoomLevel, lastZoomLevel;
    NSMutableArray* annotations;
    CLLocationCoordinate2D globCoordinate;
    CLLocationCoordinate2D oldCoordinate;
    
    __weak IBOutlet UITextField *postalCodeField;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSString* locationAddress, *locationType;
    id json;
    NSString* lastLocationType;
    bool isDrag;
    double long isFirstTimeLoad;
    bool isSetLongPressAndDrag;
    float firstTimeZoom;
}

@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (retain, nonatomic) NSString *AddressStr;
@end

@implementation LocationViewController
@synthesize googleMapView;
@synthesize objEditCarRoute;
@synthesize isfrom;
@synthesize AddressStr;
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstTimeLoad = 1;
    self.title = @"Select Location";
    // Do any additional setup after loading the view.
    currentZoomLevel = 0.0;
    lastZoomLevel = 0.0;
    firstTimeZoom = 11.0;
    [postalCodeField addTextFieldLeftPadding:postalCodeField];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    googleMapView.myLocationEnabled = NO;
    AddressStr = [[NSString alloc]init];
}
- (void)viewWillAppear:(BOOL)animated
{
    isSetLongPressAndDrag = false;
    lastLocationType = @"";
    marker = [[GMSMarker alloc] init];
    googleMapView.delegate = self;
    currentZoomLevel = camera.zoom;
    //NSLog(@"objEditCarRoute.toAddress %@", objEditCarRoute.toAddress);
    [locationManager startUpdatingLocation];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    currentZoomLevel = 14.0;
    if (![objEditCarRoute.fromAddress isEqualToString:@""] && isfrom)
    {
        [myDelegate showIndicator];
        isFirstTimeLoad = 2;
        postalCodeField.text =objEditCarRoute.fromAddress;
        AddressStr = objEditCarRoute.fromAddress;
        [self performSelector:@selector(getLocationFromAddressString:) withObject:objEditCarRoute.fromAddress afterDelay:.1];
    }
    else if (![objEditCarRoute.toAddress isEqualToString:@""] && !isfrom)
    {
        [myDelegate showIndicator];
        isFirstTimeLoad = 2;
        postalCodeField.text =objEditCarRoute.toAddress;
        AddressStr = postalCodeField.text;
        [self performSelector:@selector(getLocationFromAddressString:) withObject:objEditCarRoute.toAddress afterDelay:.1];
    }
    else
    {
        globCoordinate.latitude =1.2845900058746338;
        globCoordinate.longitude = 103.81400299072266;
        isFirstTimeLoad = 1;
        [myDelegate showIndicator];
        [self performSelector:@selector(setpin) withObject:nil afterDelay:2.0];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Get location/address
-(id) getAddressFromLatLong:(float)latitude longitude:(float)longitude {
    
    NSString *req = [NSString stringWithFormat:@"http://gothere.sg/maps/geo?callback=&output=json&client=&sensor=false&q=%f,%f", latitude,longitude];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"result %@",result);
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    if (data != nil)
    {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        return json;
    }
    else
    {
        return data;
    }
}

-(NSString *) parseDic: (NSDictionary*)dataDic  {
    
    NSString *status =[dataDic objectForKey:@"status"];
    if ([status isEqualToString:@"OK"]) {
        status = [[dataDic[@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
        locationAddress = status;
        if (isfrom)
        {
            objEditCarRoute.fromAddress = locationAddress;
        }
        else
        {
            objEditCarRoute.toAddress = locationAddress;
        }
    }
    else{
        locationAddress = @"";
        status = @"please check your internet connection.";
    }
    return status;
}

-(CLLocationCoordinate2D) getLocationFromAddressString:(NSString*) addressStr
{
    //NSLog(@"isFirstTimeLoad is %Lf",isFirstTimeLoad);
    if (isFirstTimeLoad > 3) {
        isFirstTimeLoad = 3;
    }
    double latitude = 0, longitude = 0;
    NSString *esc_addr = [[NSString alloc]init];
    esc_addr =  [[NSString stringWithFormat:@"%@", addressStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://gothere.sg/maps/geo?callback=&output=json&client=&sensor=false&q=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    CLLocationCoordinate2D center;
    if (data != nil)
    {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [myDelegate stopIndicator];
        if (result)
        {
            if ([[[json objectForKey:@"Status"] objectForKey:@"code"]intValue] == 200)
            {
                NSArray *locationArray = [json objectForKey:@"Placemark"];
                for (int i=0; i<locationArray.count; i++)
                {
                    NSDictionary * locationDict = [locationArray objectAtIndex:i];
                    NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                    NSString *postalCode = [AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"];
                    //NSLog(@" postal code is %@ and length %lu",[AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"],(unsigned long)postalCode.length);
                    if (postalCode.length>=6)
                    {
                        NSDictionary *pointsDict = [locationDict objectForKey:@"Point"];
                        NSArray *pointsArray = [pointsDict objectForKey:@"coordinates"];
                        latitude = [[pointsArray objectAtIndex:1]floatValue];
                        longitude =[[pointsArray objectAtIndex:0]floatValue];
                        NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                        postalCodeField.text =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                        globCoordinate.latitude = latitude;
                        globCoordinate.longitude = longitude;
                        if (isfrom)
                        {
                            objEditCarRoute.fromAddress =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                            objEditCarRoute.fromCordinates =globCoordinate;
                        }
                        else
                        {
                            objEditCarRoute.toAddress =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                            objEditCarRoute.toCordinates =globCoordinate;
                        }
                        oldCoordinate = globCoordinate;
                        googleMapView.myLocationEnabled = NO;
                        
                        if (isFirstTimeLoad == 2) {
                            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                                 longitude:globCoordinate.longitude
                                                                      zoom:14.0];
                        }
                        else {
                            //                            oldCoordinate = globCoordinate;
                            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                                 longitude:globCoordinate.longitude
                                                                      zoom:currentZoomLevel];
                        }
                        googleMapView.camera = camera;
                        marker.position = globCoordinate;
                        marker.title = @"Address";
                        marker.tappable = true;
                        marker.map= googleMapView;
                        marker.draggable = true;
                        break;
                    }
                }
                isFirstTimeLoad = isFirstTimeLoad + 1;
            }
            else
            {
                googleMapView.myLocationEnabled = NO;
                
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:currentZoomLevel];
                if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                {
                    marker.position = oldCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= googleMapView;
                    marker.draggable = true;
                }
                [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
            }
        }
        else
        {
            [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark.."];
        }
        center.latitude = latitude;
        center.longitude = longitude;
    }
    else {
        center = kCLLocationCoordinate2DInvalid;
    }
    return center;
}

- (void)setpin
{
    if (isFirstTimeLoad > 3) {
        isFirstTimeLoad = 3;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        double latitude = 0, longitude = 0;
        id addressData = [self getAddressFromLatLong:globCoordinate.latitude longitude:globCoordinate.longitude];
        if (addressData!=nil)
        {
            if ([[[json objectForKey:@"Status"] objectForKey:@"code"]intValue] == 200)
            {
                googleMapView.myLocationEnabled = NO;
                if (isFirstTimeLoad == 1) {
                    
                    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                         longitude:globCoordinate.longitude
                                                              zoom:firstTimeZoom];
                }
                else if (isFirstTimeLoad == 2) {
                    
                    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                         longitude:globCoordinate.longitude
                                                              zoom:14.0];
                }
                else {
                    
                    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                         longitude:globCoordinate.longitude
                                                              zoom:self.googleMapView.camera.zoom];
                }
                [myDelegate stopIndicator];
                NSArray *locationArray = [json objectForKey:@"Placemark"];
                for (int i=0; i<locationArray.count; i++)
                {
                    NSDictionary * locationDict = [locationArray objectAtIndex:i];
                    NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                    NSString *postalCode = [AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"];
                    //NSLog(@" postal code is %@ and length %lu",[AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"],(unsigned long)postalCode.length);
                    if (postalCode.length>=6)
                    {
                        NSDictionary *pointsDict = [locationDict objectForKey:@"Point"];
                        NSArray *pointsArray = [pointsDict objectForKey:@"coordinates"];
                        latitude = [[pointsArray objectAtIndex:1]floatValue];
                        longitude =[[pointsArray objectAtIndex:0]floatValue];
                        NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                        if (isFirstTimeLoad != 1) {
                            postalCodeField.text =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                        }
                        globCoordinate.latitude = latitude;
                        globCoordinate.longitude = longitude;
                        if (isfrom)
                        {
                            if (isFirstTimeLoad != 1) {
                                objEditCarRoute.fromAddress =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                                objEditCarRoute.fromCordinates =globCoordinate;
                            }
                        }
                        else
                        {
                            if (isFirstTimeLoad != 1) {
                                objEditCarRoute.toAddress =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                                objEditCarRoute.toCordinates =globCoordinate;
                            }
                        }
                        googleMapView.myLocationEnabled = NO;
                        
                        if (isFirstTimeLoad == 1) {
                            
                            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                                 longitude:globCoordinate.longitude
                                                                      zoom:firstTimeZoom];
                        }
                        else if (isFirstTimeLoad == 2) {
                            oldCoordinate = globCoordinate;
                            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                                 longitude:globCoordinate.longitude
                                                                      zoom:14.0];
                        }
                        else {
                            oldCoordinate = globCoordinate;
                            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                                 longitude:globCoordinate.longitude
                                                                      zoom:currentZoomLevel];
                        }
                        googleMapView.camera = camera;
                        if (isFirstTimeLoad != 1) {
                            marker.position = globCoordinate;
                            marker.title = @"Address";
                            marker.tappable = true;
                            marker.map= googleMapView;
                            marker.draggable = true;
                        }
                        
                        break;
                    }
                }
                isFirstTimeLoad = isFirstTimeLoad + 1;
            }
            else
            {
                [myDelegate stopIndicator];
                googleMapView.myLocationEnabled = NO;
                
                if (isFirstTimeLoad == 1) {
                    
                    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                         longitude:globCoordinate.longitude
                                                              zoom:firstTimeZoom];
                }
                else {
                    
                    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                         longitude:globCoordinate.longitude
                                                              zoom:self.googleMapView.camera.zoom];
                }
                googleMapView.camera = camera;
                if (isFirstTimeLoad != 1) {
                    if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                    {
                        marker.position = oldCoordinate;
                        marker.title = @"Address";
                        marker.tappable = true;
                        marker.map= googleMapView;
                        marker.draggable = true;
                    }
                }
                isFirstTimeLoad = isFirstTimeLoad + 1;
                [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
            }
        }
        else
        {
            [myDelegate stopIndicator];
            googleMapView.myLocationEnabled = NO;
            
            if (isFirstTimeLoad == 1) {
                
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:firstTimeZoom];
            }
            else {
                
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:self.googleMapView.camera.zoom];
            }
            googleMapView.camera = camera;
            if (isFirstTimeLoad != 1) {
                if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                {
                    marker.position = oldCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= googleMapView;
                    marker.draggable = true;
                }
            }
            isFirstTimeLoad = isFirstTimeLoad + 1;
            [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
        }
    });
}
#pragma mark - end

#pragma mark - CLLocationManager authorization
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            
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
            if ([CLLocationManager locationServicesEnabled]) {
                
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"Settings" actionBlock:^(void) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
            }
            [locationManager requestAlwaysAuthorization];
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [locationManager requestAlwaysAuthorization];
        }
            break;
            
        default:
        {
            [locationManager startUpdatingLocation];
        }
            break;
    }
}
#pragma mark - end

#pragma mark - Location delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
    }
    [manager stopUpdatingLocation];
}
#pragma mark - end

#pragma mark - Textfield methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!isSetLongPressAndDrag) {
        [myDelegate showIndicator];
        AddressStr = textField.text;
        [self performSelector:@selector(getLocationFromAddressString:) withObject:textField.text afterDelay:.1];
    }
    else {
        isSetLongPressAndDrag = false;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Google map view delegate
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition*)position {
    currentZoomLevel = mapView.camera.zoom;
    // handle you zoom related logic
}

- (void) mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{
    isDrag = true;
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    isSetLongPressAndDrag = true;
    [self.view endEditing:YES];
    //NSLog(@"sdaf");
    if (isDrag)
    {
        return;
    }
    isDrag = false;
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        googleMapView.myLocationEnabled = NO;
        
        if (isFirstTimeLoad == 2) {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:14.0];
        }
        else {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:self.googleMapView.camera.zoom];
        }
        isFirstTimeLoad = isFirstTimeLoad + 1;
        googleMapView.camera = camera;
        marker.position = globCoordinate;
        marker.title = @"Address";
        marker.snippet = locationAddress;
        marker.tappable = true;
        marker.map= googleMapView;
        marker.draggable = false;
    }
    else
    {
        globCoordinate = coordinate;
        [myDelegate showIndicator];
        [self performSelector:@selector(setpin) withObject:nil afterDelay:.1];
    }
    //NSLog(@"Long press detected");
}

- (void) mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker1
{
    isSetLongPressAndDrag = true;
    [self.view endEditing:YES];
    isDrag = false;
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        googleMapView.myLocationEnabled = NO;
        
        if (isFirstTimeLoad == 2) {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:14.0];
        }
        else {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:self.googleMapView.camera.zoom];
        }
        isFirstTimeLoad = isFirstTimeLoad + 1;
        googleMapView.camera = camera;
        marker.position = globCoordinate;
        marker.title = @"Address";
        marker.snippet = locationAddress;
        marker.tappable = true;
        marker.map= googleMapView;
        marker.draggable = false;
    }
    else
    {
        globCoordinate = marker1.position;
        [myDelegate showIndicator];
        [self performSelector:@selector(setpin) withObject:nil afterDelay:.1];
    }
}

- (void) mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker
{
    
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)doneClickAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)search:(id)sender
{
    if ([postalCodeField isFirstResponder])
    {
        [postalCodeField resignFirstResponder];
    }
    else
    {
        [myDelegate showIndicator];
        AddressStr = postalCodeField.text;
        [self performSelector:@selector(getLocationFromAddressString:) withObject:postalCodeField.text afterDelay:.1];
    }
}
#pragma mark - end
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
