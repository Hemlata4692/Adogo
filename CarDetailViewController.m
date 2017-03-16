//
//  CarDetailViewController.m
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarDetailViewController.h"
#import "CarService.h"
#import "CarDetailTableViewCell.h"
#import "AddNewCarViewController.h"
#import "CarImageCollectionViewCell.h"
#import "CarRouteViewController.h"
#import "AddCarDimensionViewController.h"
#import "CarRouteViewController.h"

#define adminImagesNotAvailable @"Please wait for Adogo to provide area for measurement."
#define adminImagesAvailable @"Please measure the marked area as indicated in the photo as soon as possible by clicking on Add Car Dimensions below the car setting."
#define adminWaiting @"Please wait while your car dimensions are approved by Adogo."
#define adminRedimension @"Please provide dimensions again for the unapproved sides."

@interface CarDetailViewController () {

    NSMutableDictionary *carDetailResponse ,*carDetails;
    int carStatus;
    UIView *tempView;
    UIImageView *popImage;
}
@end

@implementation CarDetailViewController
@synthesize carId, carModel, isApprovedCarDetail;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [myDelegate.notificationDict setObject:@"CarDetailView" forKey:@"ScreenType"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carDetailNotification:) name:@"carDetail" object:nil];
    self.title = @"Car Details";
    carStatus = 0;
    carDetailResponse = [NSMutableDictionary new];
    carDetails = [NSMutableDictionary new];
    [[self navigationController] setNavigationBarHidden:NO];
    [self addRightBarButtonWithImage:[UIImage imageNamed:@"editCar"]];
    if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Yes"]) {
        
        [myDelegate.notificationDict setObject:@"No" forKey:@"isNotification"];
        carId = [[[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"extra_params"] objectForKey:@"car_id"];
    }
    [myDelegate showIndicator];
    [self performSelector:@selector(getCarDetail) withObject:nil afterDelay:.1];
}

- (void)addRightBarButtonWithImage:(UIImage *)editImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, editImage.size.width, editImage.size.height);
    UIButton *editCar = [[UIButton alloc] initWithFrame:framing];
    [editCar setBackgroundImage:editImage forState:UIControlStateNormal];
    [editCar addTarget:self action:@selector(editCarDetail) forControlEvents:UIControlEventTouchUpInside];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:editCar];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButton1, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [myDelegate.notificationDict setObject:@"Other" forKey:@"ScreenType"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - end

#pragma mark - Car detail notification handling
- (void)carDetailNotification:(NSNotification *)notification {
    
    carId = [[[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"extra_params"] objectForKey:@"car_id"];
    [myDelegate showIndicator];
    [self performSelector:@selector(getCarDetail) withObject:nil afterDelay:.1];
}
#pragma mark - end

#pragma mark - Call webservices
- (void)getCarDetail {
    
    [[CarService sharedManager] carDetailService:carId success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        
        carDetailResponse = [[responseObject objectForKey:@"cardetail"] mutableCopy];
        carModel = [NSString stringWithFormat:@"%@ - %@",[[responseObject objectForKey:@"cardetail"] objectForKey:@"plate_number"],[[responseObject objectForKey:@"cardetail"] objectForKey:@"model"]];
        
        if ([[carDetailResponse objectForKey:@"carimg_addedbyadmin"] count] == 0)
        {
            [carDetails setObject:@"No" forKey:@"isAdminCarAvailable"];
        }
        else
        {
            [carDetails setObject:@"Yes" forKey:@"isAdminCarAvailable"];
        }
        [carDetails setObject:carDetailResponse forKey:@"cardetail"];
       
        if ([[carDetails objectForKey:@"isAdminCarAvailable"] boolValue])
        {
            [self addImagesInCarDetail:[carDetailResponse objectForKey:@"carimg_addedbyadmin"]];
            [self checkIsOtherForOwner:[carDetailResponse objectForKey:@"carimg_addedbyowner"]];
        }
        else {
            [self addImagesInCarDetail:[carDetailResponse objectForKey:@"carimg_addedbyowner"]];
            [self checkIsOtherForOwner:[carDetailResponse objectForKey:@"carimg_addedbyowner"]];
        }

        if ([[carDetailResponse objectForKey:@"is_owner"] intValue] == 0) {
            [carDetails setObject:@"No" forKey:@"is_owner"];
        }
        else {
            [carDetails setObject:@"Yes" forKey:@"is_owner"];
        }
        
        if ([[carDetails objectForKey:@"isAdminCarAvailable"] boolValue]) {
        
            NSMutableArray *checkStatus = [NSMutableArray new];
            NSArray *keys = [[carDetails objectForKey:@"carImages"] allKeys];
            for (int i = 0; i < [keys count]; i++) {
                
                if ([[keys objectAtIndex:i] isEqualToString:@"other_image"]) {
                    if ([[carDetails objectForKey:@"isOtherImage"] isEqualToString:@"Yes"]) {
                        
                        for (int j = 0; j < [[[carDetails objectForKey:@"carImages"] objectForKey:[keys objectAtIndex:i]] count]; j++) {
                            [checkStatus addObject:[self checkMeasurementExist:[[[carDetails objectForKey:@"carImages"] objectForKey:[keys objectAtIndex:i]] objectAtIndex:j]]];
                        }
                    }
                }
                else {
                    [checkStatus addObject:[self checkMeasurementExist:[[carDetails objectForKey:@"carImages"] objectForKey:[keys objectAtIndex:i]]]];
                }
            }
            
            if ([checkStatus containsObject:@"1"]) {
                carStatus = 1;  //When adogo added images for dimensions (Enter dimensions).
            }
            else if ([checkStatus containsObject:@"3"]) {
                carStatus = 3;  //when dimensions are not approved by adogo (Redimension state).
            }
            else if ([checkStatus containsObject:@"2"]) {
                carStatus = 2;  //when dimensions are not approved by adogo (Waiting state).
            }
            else if ([checkStatus containsObject:@"4"]) {
                carStatus = 4;  //when all dimensions are approved by adogo.
            }
        }
        else {
            
            carStatus = 0;  //When adogo(admin) is not added images.
        }
     
        [_carDetailTableView reloadData];
    }
    failure:^(NSError *error) {
    
    }];
}

- (NSString *)checkMeasurementExist:(NSMutableDictionary*)data {
    
    NSString *checkStatusValue;
    if ([[data objectForKey:@"is_approved"] isEqualToString:@"0"] && [[data objectForKey:@"measurLength"] isEqualToString:@""] && [[data objectForKey:@"measurHeigth"] isEqualToString:@""]) {
        
        checkStatusValue = @"1";  //When adogo added images for dimensions (Enter dimensions).
    }
    else if ([[data objectForKey:@"is_approved"] isEqualToString:@"0"] && ([[data objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)) {
        
        checkStatusValue = @"2";  //when dimensions are not approved by adogo (Waiting state).
    }
    else if ([[data objectForKey:@"is_approved"] isEqualToString:@"0"] && ([[data objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
        
        checkStatusValue = @"3";  //when dimensions are not approved by adogo (Redimension state).
    }
    else if ([[data objectForKey:@"is_approved"] isEqualToString:@"1"]) {
        
        checkStatusValue = @"4";  //when all dimensions are approved by adogo.
    }
    return checkStatusValue;
}

- (void)addImagesInCarDetail:(NSMutableDictionary *)data {
    
    NSMutableDictionary *carMainDic = [NSMutableDictionary new];
    if([data objectForKey:@"left_image"] != nil) {
        // The key existed...
        [carMainDic setObject:[data objectForKey:@"left_image"] forKey:@"left_image"];
    }
    if([data objectForKey:@"front_image"] != nil) {
        // The key existed...
        [carMainDic setObject:[data objectForKey:@"front_image"] forKey:@"front_image"];
    }
    if([data objectForKey:@"rear_image"] != nil) {
        // The key existed...
        [carMainDic setObject:[data objectForKey:@"rear_image"] forKey:@"rear_image"];
    }
    if([data objectForKey:@"right_image"] != nil) {
        // The key existed...
        [carMainDic setObject:[data objectForKey:@"right_image"] forKey:@"right_image"];;
    }
    
    if (([[data objectForKey:@"other_image"] count]>0)) {
        [carMainDic setObject:[data objectForKey:@"other_image"] forKey:@"other_image"];
        
        [carDetails setObject:@"Yes" forKey:@"isOtherImage"];
    }
    else {
        
        [carDetails setObject:@"No" forKey:@"isOtherImage"];
    }    
    [carDetails setObject:carMainDic forKey:@"carImages"];
}

- (void)checkIsOtherForOwner:(NSMutableDictionary *)data {
    
    if (([[data objectForKey:@"other_image"] count]>0)) {
        
        [carDetails setObject:@"Yes" forKey:@"isOwnerOtherImage"];
    }
    else {
        
        [carDetails setObject:@"No" forKey:@"isOwnerOtherImage"];
    }
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (carDetails.count != 0) {
        if (section == 0) {
            
            float height;
            if (carStatus == 0){
                
                height = [self getDynamicLabelHeight:adminImagesNotAvailable font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                return height + 10;
            }
            else if (carStatus == 1){
                height = [self getDynamicLabelHeight:adminImagesAvailable font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                return height + 10;
            }
            else if (carStatus == 2){
                height = [self getDynamicLabelHeight:adminWaiting font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                return height + 10;
            }
            else if (carStatus == 3){
                height = [self getDynamicLabelHeight:adminRedimension font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                return height + 10;
            }
            else{
                return 0.01;
            }
        }
        else {
            
            if ([[carDetails objectForKey:@"is_owner"] isEqualToString:@"No"]) {
                
                return  11 + 21 + 21 + 12;
            }
            else {
                return  44.0;
            }
        }
    }
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35.0)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, 35)];
    label.backgroundColor = [UIColor clearColor];
//    NSLog(@"chekc");
    if (carDetails.count != 0) {
        if (section == 0) {
            
            headerView.backgroundColor = [UIColor colorWithRed:(227.0/255.0) green:(67.0/255.0) blue:(67.0/255.0) alpha:1.0f];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont railwayRegularWithSize:13];
            label.numberOfLines = 0;
            if (carStatus == 0){
                
                label.text = adminImagesNotAvailable;
                float height = [self getDynamicLabelHeight:label.text font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                
                 height = [self getDynamicLabelHeight:adminImagesNotAvailable font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                label.frame = CGRectMake(20, 5, headerView.frame.size.width - 40, height);
                headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, label.frame.size.height + 10);
            }
            else if (carStatus == 1){
                
                label.text = adminImagesAvailable;
                float height = [self getDynamicLabelHeight:label.text font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                label.frame = CGRectMake(20, 5, headerView.frame.size.width - 40, height);
                headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, label.frame.size.height + 10);
            }
            else if (carStatus == 2){
                
                label.text = adminWaiting;
                float height = [self getDynamicLabelHeight:label.text font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                label.frame = CGRectMake(20, 5, headerView.frame.size.width - 40, height);
                headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, label.frame.size.height + 10);
            }
            else if (carStatus == 3){
                
                label.text = adminRedimension;
                float height = [self getDynamicLabelHeight:label.text font:[UIFont railwayRegularWithSize:13] widthValue:tableView.bounds.size.width - 40];
                label.frame = CGRectMake(20, 5, headerView.frame.size.width - 40, height);
                headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, label.frame.size.height + 10);
            }
            else{
            
                label.frame = CGRectMake(20, 5, headerView.frame.size.width - 40, 0);
                headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 0);
            }
            [headerView addSubview:label];
        }
        else {
        
            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44.0)];
            
            if ([[carDetails objectForKey:@"is_owner"] isEqualToString:@"No"]) {
                UILabel * myLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 11, headerView.frame.size.width - 26, 21)];
                label.frame = CGRectMake(13, label.frame.size.height, headerView.frame.size.width - 26, 21);
                myLabel.backgroundColor = [UIColor clearColor];
                label.backgroundColor = [UIColor clearColor];
                
                myLabel.text = @"I am not a car owner";
                label.text = @"I am eligible to act as an owner of this car";
                
                myLabel.textColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
                label.textColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
                
                myLabel.font = [UIFont railwayBoldWithSize:13];
                label.font = [UIFont railwayBoldWithSize:13];
                
                myLabel.textAlignment = NSTextAlignmentLeft;
                label.textAlignment = NSTextAlignmentLeft;
                
                [backView addSubview:myLabel];
                 backView.frame = CGRectMake(0, 0, tableView.frame.size.width, label.frame.origin.y + label.frame.size.height + 11);
            }
            else {
                
                label.frame = CGRectMake(13, 11, headerView.frame.size.width - 26, 21);
                label.backgroundColor = [UIColor clearColor];
                label.text = @"I am owner of this car.";
                label.textColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
                label.font = [UIFont railwayBoldWithSize:13];
                label.textAlignment = NSTextAlignmentLeft;
                 backView.frame = CGRectMake(0, 0, tableView.frame.size.width, 43);
            }
            backView.backgroundColor = [UIColor colorWithRed:(239.0/255.0) green:(240.0/255.0) blue:(245.0/255.0) alpha:1.0f];
           
            UILabel * seperatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backView.frame.size.height - 1, headerView.frame.size.width, 1)];
            seperatorLabel.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:148.0/255.0 alpha:0.5];
            [backView addSubview:seperatorLabel];
            
            [backView addSubview:label];
            headerView.backgroundColor = [UIColor whiteColor];
            headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, backView.frame.size.height + 1);
            [headerView addSubview:backView];
        }
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (carDetails.count != 0) {
        if (section == 0) {
            return  6;
        }
        else {
            if ([[carDetails objectForKey:@"is_owner"] isEqualToString:@"No"]) {
                return 3;
            }
            else {
                return 1;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (carDetails.count != 0) {
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                return 185;
            }
            else {
                return 44;
            }
        }
        else {
            if ([[carDetails objectForKey:@"is_owner"] isEqualToString:@"No"]) {
                if (indexPath.row == 2) {
                    if ([[carDetails objectForKey:@"isAdminCarAvailable"] isEqualToString:@"No"]) {
                        return 65.0;
                    }
                    else {
                        return 123.0;
                    }
                }
                else {
                    return 44.0;
                }
            }
            else {
                return 65.0;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier;
    CarDetailTableViewCell *cell;
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            simpleTableIdentifier = @"imageCell";
            cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            cell.carModel.text = carModel;
            [cell.carImageCollectionView reloadData];
        }
        else {
            
            simpleTableIdentifier = @"carDetailCell";
            cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            [cell displayCarDetailData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row];
        }
    }
    else {
        
        if ([[carDetails objectForKey:@"is_owner"] isEqualToString:@"No"]) {
            
            if (indexPath.row == 2) {
                
                simpleTableIdentifier = @"buttonCell";
                cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                if ([[carDetails objectForKey:@"isAdminCarAvailable"] isEqualToString:@"No"]) {
                    [cell displayCarButtonData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row isAdminCar:NO];
                }
                else {
                    [cell displayCarButtonData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row  isAdminCar:YES];
                    
                    if (carStatus == 2 || carStatus == 4) {
                        [cell.carDimensionBtn setTitle:@"View Car Dimensions" forState:UIControlStateNormal];
                       
                    }
                    else if (carStatus == 3) {
                        [cell.carDimensionBtn setTitle:@"Edit Car Dimensions" forState:UIControlStateNormal];
                    }
                    else {
                        [cell.carDimensionBtn setTitle:@"Add Car Dimensions" forState:UIControlStateNormal];
                    }
                }
                [cell.addCarRouteBtn addTarget:self action:@selector(addCarRouteDetail) forControlEvents:UIControlEventTouchUpInside];
                [cell.carDimensionBtn addTarget:self action:@selector(addCarDimension) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                
                simpleTableIdentifier = @"carDetailCell";
                cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
                [cell displayCarDetailData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row];
            }
        }
        else {
            
            simpleTableIdentifier = @"buttonCell";
            cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if ([[carDetails objectForKey:@"isAdminCarAvailable"] isEqualToString:@"No"]) {
                [cell displayCarButtonData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row  isAdminCar:NO];
            }
            else {
                [cell displayCarButtonData:[carDetails objectForKey:@"cardetail"] section:(int)indexPath.section row:(int)indexPath.row  isAdminCar:YES];
                if (carStatus == 2 || carStatus == 4) {
                    [cell.carDimensionBtn setTitle:@"View Car Dimensions" forState:UIControlStateNormal];
                }
                else if (carStatus == 3) {
                    [cell.carDimensionBtn setTitle:@"Edit Car Dimensions" forState:UIControlStateNormal];
                }
                else {
                    [cell.carDimensionBtn setTitle:@"Add Car Dimensions" forState:UIControlStateNormal];
                }
            }
            [cell.addCarRouteBtn addTarget:self action:@selector(addCarRouteDetail) forControlEvents:UIControlEventTouchUpInside];
            [cell.carDimensionBtn addTarget:self action:@selector(addCarDimension) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}
#pragma mark - end

#pragma mark - UIView actions
- (void)editCarDetail {
    
    NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        if (subview.tag == 23101) {
            [subview removeFromSuperview];
        }
    }
    if (![[carDetailResponse objectForKey:@"is_approved"] isEqualToString:@"1"]) {
        //navigate in edit car
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddNewCarViewController *carDetailInfo =[storyboard instantiateViewControllerWithIdentifier:@"AddNewCarView"];
        carDetailInfo.isEditCar = YES;
        carDetailInfo.carId = carId;
        carDetailInfo.isCarListing = YES;
        carDetailInfo.carDetail = [carDetailResponse mutableCopy];
        carDetailInfo.carImageFromDetail = [[carDetailResponse objectForKey:@"carimg_addedbyowner"] mutableCopy];
        
        if (![[carDetails objectForKey:@"isOwnerOtherImage"] boolValue]) {
            [carDetailInfo.carImageFromDetail removeObjectForKey:@"other_image"];
        }
        [self.navigationController pushViewController:carDetailInfo animated:YES];
    }
    else {
        [UserDefaultManager showAlertMessage:@"Please contact Adogo for any changes."];
    }
}

- (void)addCarRouteDetail {
    
    NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        if (subview.tag == 23101) {
            [subview removeFromSuperview];
        }
    }
    CarRouteViewController * nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"CarRouteViewController"];
    nextView.carId = carId;
    [self.navigationController pushViewController:nextView animated:YES];
}

- (void)addCarDimension {
    
    NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        if (subview.tag == 23101) {
            [subview removeFromSuperview];
        }
    }
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddCarDimensionViewController *carDimensionObj =[storyboard instantiateViewControllerWithIdentifier:@"AddCarDimensionViewController"];
    carDimensionObj.dimensionDetail = [[carDetails objectForKey:@"carImages"] mutableCopy];
    carDimensionObj.isOtherExist = [[carDetails objectForKey:@"isOtherImage"] boolValue];
    if (![[carDetails objectForKey:@"isOtherImage"] boolValue]) {
        [carDimensionObj.dimensionDetail removeObjectForKey:@"other_image"];
    }
    carDimensionObj.carId = carId;
    if (carStatus == 1) {
        
        carDimensionObj.isUpdatedText = @"0";
        carDimensionObj.flag = 1;
    }
    else if (carStatus == 3) {
        
        carDimensionObj.isUpdatedText = @"1";
         carDimensionObj.flag = 1;
    }
    else {
    
         carDimensionObj.flag = 0;
    }
    [self.navigationController pushViewController:carDimensionObj animated:YES];
}
#pragma mark - end

#pragma mark - Get dynamic height of uiLabel
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{

    CGSize size = CGSizeMake(widthValue,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height+1.0;
}
#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([[carDetails objectForKey:@"isOtherImage"] boolValue]) {
        return 4 + [[[carDetails objectForKey:@"carImages"] objectForKey:@"other_image"] count];
    }
    else {
        return 4;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"carImage";
    CarImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell displayData:(int)indexPath.row data:[carDetails objectForKey:@"carImages"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    tempView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height)];
    popImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    tempView.backgroundColor = [UIColor blackColor];
    popImage.contentMode = UIViewContentModeScaleAspectFit;
    popImage.backgroundColor = [UIColor clearColor];
    
    tempView.tag=23101;
    if (indexPath.row == 0) {
        [self downloadImages:popImage imageUrl:[[[carDetails objectForKey:@"carImages"] objectForKey:@"front_image"] objectForKey:@"image"] placeholderImage:@"front.png"];
    }
    else if (indexPath.row  == 1) {
        [self downloadImages:popImage imageUrl:[[[carDetails objectForKey:@"carImages"] objectForKey:@"right_image"] objectForKey:@"image"] placeholderImage:@"rightSide.png"];
    }
    else if (indexPath.row  == 2) {
        [self downloadImages:popImage imageUrl:[[[carDetails objectForKey:@"carImages"] objectForKey:@"rear_image"] objectForKey:@"image"] placeholderImage:@"rear.png"];
    }
    else if (indexPath.row  == 3) {
        [self downloadImages:popImage imageUrl:[[[carDetails objectForKey:@"carImages"] objectForKey:@"left_image"] objectForKey:@"image"] placeholderImage:@"leftSide.png"];
    }
    else{
        int indexValue = (int)indexPath.row  - 4;
        [self downloadImages:popImage imageUrl:[[[[carDetails objectForKey:@"carImages"] objectForKey:@"other_image"] objectAtIndex:indexValue] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
    }
    UIButton *close_button=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60,10,48,48)];
    [close_button setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [close_button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [tempView addSubview:popImage];
    [tempView addSubview:close_button];
    [self.view addSubview:tempView];
    
    [UIView animateWithDuration:0.3f animations:^{
        tempView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = imageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end

- (IBAction)closeAction:(id)sender {
    
    [UIView animateWithDuration:0.3f animations:^{
        tempView.frame = CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
