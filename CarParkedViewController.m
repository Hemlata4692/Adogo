//
//  CarParkedViewController.m
//  Adogo
//
//  Created by Ranosys on 17/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarParkedViewController.h"
#import "CarService.h"
#import "Internet.h"
#import "CarParkedCollectionViewCell.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "SCLAlertView.h"
#import <AVFoundation/AVFoundation.h>

@import MapKit;
@import GoogleMaps;

@interface CarParkedViewController ()<BSKeyboardControlsDelegate, GMSMapViewDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    GMSCameraPosition *camera;
    GMSMarker *marker;
    float currentZoomLevel, lastZoomLevel;
    CLLocationCoordinate2D globCoordinate;
    CLLocationCoordinate2D oldCoordinate;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSString* locationAddress, *locationType;
    id json;
    NSString* lastLocationType;
    
    NSArray *textFieldArray;
    NSString *addressString,*AddressForBackend;
    
    NSMutableArray *carPickedImages;
    int selectedIndex;
    float firstTimeZoom;
    int isFirstTimeLoad;
    BOOL isFirstLoad;
    bool isSetLongPressAndDrag;
    int isAWSAlertShow;
    BOOL isFirstLoadMap;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *popUpView;
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UILabel *AlertLabel;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UIButton *locationBtn;
@property (strong, nonatomic) IBOutlet UITextField *parkedBlockField;
@property (strong, nonatomic) IBOutlet UITextField *parkedLevelField;
@property (strong, nonatomic) IBOutlet UITextField *lotNumberField;
@property (strong, nonatomic) IBOutlet UICollectionView *carParkedCollectionView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *installNote;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation CarParkedViewController
@synthesize scrollView, popUpView, alertView, AlertLabel, mapView, locationField, parkedBlockField, parkedLevelField, lotNumberField, locationBtn;
@synthesize carId,scheduleId, carOwnerStatus, campaignId, dashboardObj,noteFromAdmin;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAWSAlertShow=0;
     isFirstTimeLoad = 1;
     firstTimeZoom = 10.0;
    
    currentZoomLevel = 0.0;
    lastZoomLevel = 0.0;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    addressString = @"";
    [self viewCustomization];
    [self setCarImages];
    [_carParkedCollectionView reloadData];
    selectedIndex = -1;
    
    textFieldArray = @[parkedBlockField, parkedLevelField, lotNumberField, _installNote];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    lastLocationType = @"";
    marker = [[GMSMarker alloc] init];
    mapView.delegate = self;
    currentZoomLevel = camera.zoom;
    globCoordinate.latitude = 0.0f;
    globCoordinate.longitude = 0.0f;
     currentZoomLevel = 14.0;
    isFirstLoad=false;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    
    isFirstLoadMap=true;
    globCoordinate.latitude =1.2845900058746338;
    globCoordinate.longitude = 103.81400299072266;
    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                         longitude:globCoordinate.longitude
                                              zoom:firstTimeZoom];
    mapView.camera = camera;
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    isSetLongPressAndDrag = false;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCarImages {
    
    carPickedImages = [NSMutableArray new];
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [carPickedImages addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [carPickedImages addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [carPickedImages addObject:tempDic];
}
#pragma mark - end

#pragma mark - Location methods
- (void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation{
    
    if (!isFirstLoad) {
        isFirstLoadMap=true;
        isFirstLoad=true;
        globCoordinate=newLocation.coordinate;
        mapView.myLocationEnabled = NO;
        camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                             longitude:globCoordinate.longitude
                                                  zoom:firstTimeZoom];
        [myDelegate showIndicator];
        [self performSelector:@selector(setpin) withObject:nil afterDelay:.1];
    }
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            [myDelegate showIndicator];
            isFirstLoadMap=false;
            addressString=@"569139";
            [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            [myDelegate showIndicator];
            addressString=@"569139";
            isFirstLoadMap=false;
            [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
//            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//            [alert addButton:@"Settings" actionBlock:^(void) {
//                
//                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                [[UIApplication sharedApplication] openURL:url];
//            }];
//            [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            [myDelegate showIndicator];
            addressString=@"569139";
            isFirstLoadMap=false;
            [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
//            if ([CLLocationManager locationServicesEnabled]) {
            
//                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//                [alert addButton:@"Settings" actionBlock:^(void) {
//                    
//                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                    [[UIApplication sharedApplication] openURL:url];
//                }];
//                [alert showWarning:nil title:@"Alert" subTitle:@"Turn on Location Services to allow Adogo to determine your location." closeButtonTitle:@"Cancel" duration:0.0f];
                
//            }
            
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
    }
    [manager stopUpdatingLocation];
}

- (void) mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{
    
}

- (void) mapView:(GMSMapView *)mapView1 didEndDraggingMarker:(GMSMarker *)marker1
{
    isSetLongPressAndDrag = true;
    [self.view endEditing:YES];
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        mapView.myLocationEnabled = NO;
        
        camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                             longitude:globCoordinate.longitude
                                                  zoom:self.mapView.camera.zoom];
        mapView.camera = camera;
        marker.position = globCoordinate;
        marker.title = @"Address";
        marker.snippet = locationAddress;
        locationField.text = locationAddress;
        marker.tappable = true;
        marker.map= mapView;
        marker.draggable = true;
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

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    isSetLongPressAndDrag = true;
    [self.view endEditing:YES];
    //NSLog(@"sdaf");
    
    Internet *internet=[[Internet alloc] init];
    if ([internet start])
    {
        self.mapView.myLocationEnabled = NO;
        
        if (isFirstTimeLoad == 2) {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:14.0];
        }
        else {
            camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                 longitude:globCoordinate.longitude
                                                      zoom:self.mapView.camera.zoom];
        }
        isFirstTimeLoad = isFirstTimeLoad + 1;
        self.mapView.camera = camera;
        marker.position = globCoordinate;
        marker.title = @"Address";
        marker.snippet = locationAddress;
        marker.tappable = true;
        marker.map= self.mapView;
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


- (id) getAddressFromLatLong:(float)latitude longitude:(float)longitude {
    
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

- (NSString *)parseDic:(NSDictionary*)dataDic {
    
    NSString *status =[dataDic objectForKey:@"status"];
    if ([status isEqualToString:@"OK"]) {
        status = [[dataDic[@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
        locationAddress = status;
    }
    else{
        locationAddress = @"";
        locationAddress = @"please check your internet connection.";
    }
    return status;
}

- (void) getLocationFromAddressString {
    
    if (isFirstTimeLoad > 3) {
        isFirstTimeLoad = 3;
    }
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://gothere.sg/maps/geo?callback=&output=json&client=&sensor=false&q=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    CLLocationCoordinate2D center;
    [myDelegate stopIndicator];
    if (data != nil)
    {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [myDelegate stopIndicator];
        if (result)
        {
            if ([[[json objectForKey:@"Status"] objectForKey:@"code"]intValue] == 200)
            {
                NSArray *locationArray = [json objectForKey:@"Placemark"];
                NSDictionary * locationDict = [locationArray objectAtIndex:0];
                NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                AddressForBackend = [NSString stringWithFormat:@"%@,%@,%@",[[[AddressDict objectForKey:@"Country"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"],[[AddressDict objectForKey:@"Country"] objectForKey:@"CountryName"],[[[[AddressDict objectForKey:@"Country"] objectForKey:@"Thoroughfare"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]];
                NSString *postalCode = [AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"];
                //NSLog(@" postal code is %@ and length %lu",[AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"],(unsigned long)postalCode.length);
                
                NSDictionary *pointsDict = [locationDict objectForKey:@"Point"];
                NSArray *pointsArray = [pointsDict objectForKey:@"coordinates"];
                latitude = [[pointsArray objectAtIndex:1]doubleValue];
                longitude =[[pointsArray objectAtIndex:0]doubleValue];
                globCoordinate.latitude = latitude;
                globCoordinate.longitude = longitude;
                oldCoordinate = globCoordinate;
                mapView.myLocationEnabled = NO;
                locationField.text =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:currentZoomLevel];
                mapView.camera = camera;
                marker.position = globCoordinate;
                marker.title = @"Address";
                marker.tappable = true;
                marker.map= mapView;
                marker.draggable = true;
                isFirstTimeLoad = isFirstTimeLoad + 1;
            }
            else
            {
                mapView.myLocationEnabled = NO;
                
                if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                {
                    camera = [GMSCameraPosition cameraWithLatitude:oldCoordinate.latitude
                                                         longitude:oldCoordinate.longitude
                                                              zoom:currentZoomLevel];
                    
                    marker.position = oldCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= mapView;
                    marker.draggable = true;
                }
                [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
            }
        }
        else
        {
            [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
        }
        center.latitude = latitude;
        center.longitude = longitude;
    }
    else {
        center = kCLLocationCoordinate2DInvalid;
    }
}

- (void)setpin
{
    if (isFirstTimeLoad > 3) {
        isFirstTimeLoad = 3;
    }

    if (!isFirstLoad&&isFirstTimeLoad<2) {
        isFirstTimeLoad=2;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        double latitude = 0, longitude = 0;
        id addressData = [self getAddressFromLatLong:globCoordinate.latitude longitude:globCoordinate.longitude];
        
        if (addressData!=nil)
        {
            if ([[[json objectForKey:@"Status"] objectForKey:@"code"]intValue] == 200)
            {
                mapView.myLocationEnabled = NO;
                
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
                                                              zoom:self.mapView.camera.zoom];
                }
                
                [myDelegate stopIndicator];
                NSArray *locationArray = [json objectForKey:@"Placemark"];
                
                isFirstLoadMap=false;
                NSDictionary * locationDict = [locationArray objectAtIndex:0];
                NSDictionary * AddressDict = [locationDict objectForKey:@"AddressDetails"];
                NSString *postalCode = [AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"];
                //NSLog(@" postal code is %@ and length %lu",[AddressDict valueForKeyPath:@"Country.Thoroughfare.PostalCode.PostalCodeNumber"],(unsigned long)postalCode.length);
                AddressForBackend = [NSString stringWithFormat:@"%@,%@,%@",[[[AddressDict objectForKey:@"Country"] objectForKey:@"Thoroughfare"] objectForKey:@"ThoroughfareName"],[[AddressDict objectForKey:@"Country"] objectForKey:@"CountryName"],[[[[AddressDict objectForKey:@"Country"] objectForKey:@"Thoroughfare"] objectForKey:@"PostalCode"] objectForKey:@"PostalCodeNumber"]];
                NSDictionary *pointsDict = [locationDict objectForKey:@"Point"];
                NSArray *pointsArray = [pointsDict objectForKey:@"coordinates"];
                latitude = [[pointsArray objectAtIndex:1]floatValue];
                longitude =[[pointsArray objectAtIndex:0]floatValue];
                
//                if (isFirstTimeLoad != 1) {
                    locationField.text =[[[[AddressDict objectForKey:@"Country"]objectForKey:@"Thoroughfare"]objectForKey:@"PostalCode"]objectForKey:@"PostalCodeNumber"];
//                }
                
                globCoordinate.latitude = latitude;
                globCoordinate.longitude = longitude;
                mapView.myLocationEnabled = NO;
                
                oldCoordinate = globCoordinate;
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
                                                              zoom:currentZoomLevel];
                }
                mapView.camera = camera;
//                if (isFirstTimeLoad != 1) {
                    marker.position = globCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= mapView;
                    marker.draggable = true;
//                }
                isFirstTimeLoad = isFirstTimeLoad + 1;
            }
            else
            {
                [myDelegate stopIndicator];
                
                if (isFirstLoadMap) {
                    [myDelegate showIndicator];
                    addressString=@"569139";
                    isFirstLoadMap=false;
                    [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
                }
                else {
                mapView.myLocationEnabled = NO;
                
                if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                {
                    camera = [GMSCameraPosition cameraWithLatitude:oldCoordinate.latitude
                                                         longitude:oldCoordinate.longitude
                                                              zoom:self.mapView.camera.zoom];
                    mapView.camera = camera;
                    marker.position = oldCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= mapView;
                    marker.draggable = true;
                }
                [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
                }
            }
        }
        else
        {
            [myDelegate stopIndicator];
            
            if (isFirstLoadMap) {
                [myDelegate showIndicator];
                addressString=@"569139";
                isFirstLoadMap=false;
                [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
            }
            else {
            mapView.myLocationEnabled = NO;
            
            if (isFirstTimeLoad == 2) {
                
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:14.0];
            }
            else if (isFirstTimeLoad != 1) {
                
                camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                                     longitude:globCoordinate.longitude
                                                          zoom:self.mapView.camera.zoom];
            }
            mapView.camera = camera;
            if (isFirstTimeLoad != 1) {
                if (oldCoordinate.latitude!=0.0 && oldCoordinate.longitude!=0.0)
                {
                    marker.position = oldCoordinate;
                    marker.title = @"Address";
                    marker.tappable = true;
                    marker.map= mapView;
                    marker.draggable = true;
                }
            }
            isFirstTimeLoad = isFirstTimeLoad + 1;
            [UserDefaultManager showAlertMessage:@"Invalid location. Kindly select an appropriate location or nearby landmark."];
            }
        }
    });
}
#pragma mark - end

#pragma mark - UIView customization
- (void)viewCustomization {
    
    //Set corner at main view
    popUpView.layer.cornerRadius = 5.0f;
    popUpView.layer.masksToBounds = YES;
    //end
    //Set left padding in textfields
    [locationField addTextFieldLeftPadding:locationField];
    [parkedBlockField addTextFieldLeftPadding:parkedBlockField];
    [parkedLevelField addTextFieldLeftPadding:parkedLevelField];
    [lotNumberField addTextFieldLeftPadding:lotNumberField];
     //end
    //add right padding
    UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    locationField.rightView = rightPadding;
    locationField.rightViewMode = UITextFieldViewModeAlways;
    //end
    //Set placeholder in textView
    _installNote.placeholder = @"Note for Installer";
    _installNote.placeholderTextColor = [UIColor colorWithRed:(237.0/255.0) green:(238.0/255.0) blue:(240.0/255.0) alpha:1.0f];
    //end
    //View customization
    [self removeAutolayout];
    [self changeFrame];
    //end
    //set data to alert label sent by adogo admin.
    AlertLabel.text = noteFromAdmin;
}

- (void)removeAutolayout {
    
    alertView.translatesAutoresizingMaskIntoConstraints = YES;
    AlertLabel.translatesAutoresizingMaskIntoConstraints = YES;
    locationField.translatesAutoresizingMaskIntoConstraints = YES;
    locationBtn.translatesAutoresizingMaskIntoConstraints = YES;
    _installNote.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)changeFrame {

    float height = [self getDynamicLabelHeight:@"Kindly do not part near to the wall" font:[UIFont railwayRegularWithSize:12] widthValue: self.view.bounds.size.width - 50];
    alertView.frame = CGRectMake(0, 44, self.view.bounds.size.width - 20, height + 10);
    AlertLabel.frame = CGRectMake(15, 0, self.view.bounds.size.width - 50, height + 10);
    locationField.frame = CGRectMake(12, alertView.frame.origin.y + alertView.frame.size.height + 8, self.view.bounds.size.width - 44, 44);
    locationBtn.frame = CGRectMake(locationField.frame.origin.x + locationField.frame.size.width - 34, locationField.frame.origin.y, 34, 44);
    float installerNoteHeight = [_installNote sizeThatFits:_installNote.frame.size].height;
    if (installerNoteHeight > 60.0) {
        installerNoteHeight = 60.0;
    }    
    _installNote.frame = CGRectMake(45, (455.0 + (65.0/2.0)) - (installerNoteHeight / 2.0), self.view.bounds.size.width - 20 - 45 - 10 , installerNoteHeight);
}
#pragma mark - end

#pragma mark - Textfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    scrollView.scrollEnabled = YES;
    if (!isSetLongPressAndDrag) {
        if (textField == locationField && ![textField isEmpty]) {
            //NSLog(@"%@",textField.text);
            addressString = textField.text;
            [myDelegate showIndicator];
            [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
        }
    }
    else {
        isSetLongPressAndDrag = false;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
    if (textField != locationField) {
         [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 90) animated:YES];
    }
   
    scrollView.scrollEnabled = NO;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}
#pragma mark - end

#pragma mark - Textview delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self.keyboardControls setActiveField:textView];
    [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 90) animated:YES];
    scrollView.scrollEnabled = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    float installerNoteHeight = [_installNote sizeThatFits:_installNote.frame.size].height;
    if (installerNoteHeight > 60.0) {
        installerNoteHeight = 60.0;
    }
    _installNote.frame = CGRectMake(45, (455.0 + (65.0/2.0)) - (installerNoteHeight / 2.0), self.view.bounds.size.width - 20 - 45 - 10 , installerNoteHeight);
}
#pragma mark - end


#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls1 selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls {
    
    scrollView.scrollEnabled = YES;
   [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Car submit validation
- (BOOL)performSubmitValidation {
    
    if ([parkedBlockField isEmpty] || [parkedLevelField isEmpty]  || [lotNumberField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if ((oldCoordinate.latitude == 0.0 && oldCoordinate.longitude == 0.0) || [locationField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please choose location."];
        return NO;
    }
    else {
                    return YES;
                }
//    else {
//    
//        int flag = 0;
//        for (int i = 0; i < carPickedImages.count; i++) {
//            
//            if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
//                
//                flag = flag + 1;
//                if (flag == 2) {
//                    break;
//                }
//            }
//        }
//        if (flag < 2) {
//            [UserDefaultManager showAlertMessage:@"Please upload atleast two images."];
//            return NO;
//        }
//        else {
//            return YES;
//        }
//    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)crossAction:(UIButton *)sender {
    
    dashboardObj.isPopUpOpen = false;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)locationAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    scrollView.scrollEnabled = YES;
    if (![locationField isEmpty]) {
        addressString = locationField.text;
        [myDelegate showIndicator];
        [self performSelector:@selector(getLocationFromAddressString) withObject:nil afterDelay:.1];
    }
}

- (IBAction)reset:(UIButton *)sender {
    
    locationField.text = @"";
    
    isFirstTimeLoad = 1;
    lotNumberField.text = @"";
    addressString = @"";
    parkedBlockField.text = @"";
    parkedLevelField.text = @"";
    currentZoomLevel = 14.0;
    
    lastZoomLevel = 0.0;
    lastLocationType = @"";
    oldCoordinate.latitude = 0.0f;
    oldCoordinate.longitude = 0.0f;
    _installNote.text = @"";
isFirstLoad=false;
    globCoordinate.latitude =1.2845900058746338;
    globCoordinate.longitude = 103.81400299072266;
    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                         longitude:globCoordinate.longitude
                                              zoom:firstTimeZoom];
    mapView.camera = camera;
    marker.map=nil;
    [locationManager startUpdatingLocation];
       [self setCarImages];
    [_carParkedCollectionView reloadData];
}

- (IBAction)submit:(id)sender {
    
    [self.view endEditing:YES];
    isAWSAlertShow=0;
    scrollView.scrollEnabled = YES;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if([self performSubmitValidation])
    {
        int flag = 0;
        for (int i = 0; i < carPickedImages.count; i++) {
            
            if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
                
                if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
                    flag = flag + 1;

                    break;
                }
            }
        }
        if (flag == 0) {
            
            [myDelegate showIndicator:@"Uploading Data..."];
            [self performSelector:@selector(carParkedService) withObject:nil afterDelay:.1];
        }
        else {
            
            [myDelegate showIndicator:@"Uploading Images..."];
            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.1];
        }
    }
}
#pragma mark - end

#pragma mark - Call webservices
- (void)carParkedService {
    
    NSMutableArray *imageNames = [NSMutableArray new];
    
    for (int i = 0; i < carPickedImages.count; i++) {
        
        if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
            
            [imageNames addObject:[[carPickedImages objectAtIndex:i] objectForKey:@"imageName"]];
        }
    }
    [[CarService sharedManager] setParkingDataService:scheduleId car_owner_status:carOwnerStatus car_parking_block:parkedBlockField.text car_parking_level:parkedLevelField.text car_parking_lotno:lotNumberField.text car_parking_note:_installNote.text car_parking_lat:[NSString stringWithFormat:@"%f",globCoordinate.latitude] car_parking_long:[NSString stringWithFormat:@"%f",globCoordinate.longitude] imageName:imageNames carId:carId address:AddressForBackend success:^(id responseObject) {
        
        dashboardObj.isPopUpOpen = false;
        [dashboardObj viewWillAppear:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        failure:^(NSError *error) {
                                                     
        }];
}
#pragma mark - end

#pragma mark - Get dynamic height of UILabel
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}
#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (carPickedImages.count == 0) {
        return 0;
    }
    else {
        if (carPickedImages.count == 5) {
            return carPickedImages.count;
        }
        else {
            return carPickedImages.count + 1;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier;
    CarParkedCollectionViewCell *cell;
    
    if (carPickedImages.count == 5) {
        identifier = @"carParkedCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [cell displayData:[carPickedImages objectAtIndex:indexPath.row]];
        cell.imagePickerBtn.tag = indexPath.row;
    }
    else {
        if (indexPath.row != carPickedImages.count) {
            identifier = @"carParkedCell";
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell displayData:[carPickedImages objectAtIndex:indexPath.row]];
            cell.imagePickerBtn.tag = indexPath.row;
        }
        else {
            identifier = @"addImageCell";
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell displayData];
            cell.addMoreBtn.tag = indexPath.row;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (carPickedImages.count == 5) {
        selectedIndex = (int)indexPath.row;
        [self showActionSheet];
    }
    else {
        if (indexPath.row != carPickedImages.count) {
            selectedIndex = (int)indexPath.row;
            [self showActionSheet];
        }
        else {
            NSMutableDictionary *tempDic = [NSMutableDictionary new];
            [tempDic setObject:@"false" forKey:@"isSet"];
            [carPickedImages addObject:tempDic];
            [_carParkedCollectionView reloadData];
        }
    }
}
#pragma mark - end

#pragma mark - Actionsheet method
- (void)showActionSheet {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    scrollView.scrollEnabled = YES;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select Photo"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                             if(authStatus == AVAuthorizationStatusAuthorized) {
                                                                 
                                                                 [self openDefaultCamera];
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusDenied){
                                                                 
                                                                 [self showAlertCameraAccessDenied];
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusRestricted){
                                                                 
                                                                 [self showAlertCameraAccessDenied];
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusNotDetermined){
                                                                 
                                                                 [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                                                                     if(granted){
                                                                         
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                            
                                                                             [self openDefaultCamera];
                                                                         });
                                                                     }
                                                                 }];
                                                             }
                                                         }];
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                              picker.delegate = self;
                                                              picker.allowsEditing = NO;
                                                              picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              picker.navigationBar.tintColor = [UIColor whiteColor];
                                                              
                                                              [self presentViewController:picker animated:YES completion:NULL];
                                                          }];
    
    UIAlertAction * defaultAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alert addAction:cameraAction];
    [alert addAction:galleryAction];
    [alert addAction:defaultAct];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openDefaultCamera {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showAlertCameraAccessDenied {
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        [self showAlertMessage:@"Camera Access" message:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission."];
    }
    else {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Settings" actionBlock:^(void) {
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert showWarning:nil title:@"Camera Access" subTitle:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission." closeButtonTitle:@"Cancel" duration:0.0f];
    }
}
#pragma mark - end

#pragma mark - ImagePicker delegate
- (NSString *)getImageName:(UIImage*)image {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpeg",datestr,[UserDefaultManager getValue:@"userId"]];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
    NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
    [imageData writeToFile:filePath atomically:YES];
    return fileName;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)info {
    
    UIImage *image = [image1 fixOrientation];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    tempDict = [carPickedImages objectAtIndex:selectedIndex];
    [tempDict setObject:image forKey:@"image"];
    [tempDict setObject:@"true" forKey:@"isSet"];
    [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
    [tempDict setObject:@"false" forKey:@"isUploaded"];
    [carPickedImages replaceObjectAtIndex:selectedIndex withObject:tempDict];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_carParkedCollectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Upload AWS images
- (void)uploadAWSImages {
    
    for (int i = 0; i < carPickedImages.count; i++) {
        if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]){
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:[[carPickedImages objectAtIndex:i] objectForKey:@"imageName"]];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.contentType = @"image";
            uploadRequest.key = [[carPickedImages objectAtIndex:i] objectForKey:@"imageName"];
            uploadRequest.bucket = [NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%@/campaign_%@", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],carId, campaignId];
            [self upload:uploadRequest index:i];
        }
    }
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest index:(int)index {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        [UserDefaultManager showAlertMessage:@"There was an error faced while uploading the image. Please try again."];
                        
                        //                        return;
                    }
                    
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        [UserDefaultManager showAlertMessage:@"There was an error faced while uploading the image. Please try again."];
                        
                        //                        return;
                    }
                    
                });
            }
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"complete");
                
                NSMutableDictionary *tempDict = [NSMutableDictionary new];
                tempDict = [carPickedImages objectAtIndex:index];
                [tempDict setObject:@"true" forKey:@"isUploaded"];
                [carPickedImages replaceObjectAtIndex:index withObject:tempDict];
                
                int flag = 0;
                for (int i = 0; i < carPickedImages.count; i++) {
                    
                    if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
                        
                        if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
                            flag = flag + 1;
                            
                            break;
                        }
                    }
                }
                if (flag == 0) {
                    [myDelegate stopIndicator];
                    [myDelegate showIndicator:@"Uploading Data..."];
                    [self performSelector:@selector(carParkedService) withObject:nil afterDelay:.1];
                }
            });
        }
        return nil;
    }];
}
#pragma mark - end

#pragma mark - Show alert message method
- (void)showAlertMessage:(NSString *)title message:(NSString*)message {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showWarning:nil title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
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
