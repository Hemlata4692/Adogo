//
//  InstalledStickerViewController.m
//  Adogo
//
//  Created by Ranosys on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "InstalledStickerViewController.h"
#import "CampaignService.h"
#import "InstalledStickerCollectionViewCell.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "SCLAlertView.h"
#import <AVFoundation/AVFoundation.h>

@interface InstalledStickerViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    NSMutableArray *carPickedImages;
    int selectedIndex,isAWSAlertShow;
}
@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UICollectionView *stickerCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;
@end

@implementation InstalledStickerViewController
@synthesize carId, scheduleId, campaignId,previousView,titleLabel,notificationId;
@synthesize dashboardObj,campaignCarId;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    isAWSAlertShow=0;
    if ([previousView isEqualToString:@"InstalledStikers"]) {
        titleLabel.text = @"Photos of Advertisement";
        self.crossButton.hidden=NO;
    }
    else
    {
        self.crossButton.hidden=YES;
        titleLabel.text = @"Upload Photo";
    }
    [myDelegate.notificationDict setObject:@"other" forKey:@"isNotification"];
    //Set corner at main view
    _popupContainerView.layer.cornerRadius = 5.0f;
    _popupContainerView.layer.masksToBounds = YES;
    //end
    [self setCarImages];
    [_stickerCollectionView reloadData];
    selectedIndex = -1;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    // Do any additional setup after loading the view.
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

#pragma mark - Web serivce call
- (void)installStickerRequest {
    
    NSMutableArray *imageNames = [NSMutableArray new];
    for (int i = 0; i < carPickedImages.count; i++)
    {
        if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
            
            [imageNames addObject:[[carPickedImages objectAtIndex:i] objectForKey:@"imageName"]];
        }
    }
    if ([previousView isEqualToString:@"InstalledStikers"])
    {
        [[CampaignService sharedManager] setInstalledSticker:scheduleId stickerImageArray:imageNames success :^(id responseObject)
         {
             dashboardObj.isAskMorePhotoPopUpOpen=false;
             dashboardObj.isPopUpOpen = false;
             dashboardObj.isImagePickerPopUpOpen=false;
             [dashboardObj viewWillAppear:YES];
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
         }
                                                     failure:^(NSError *error)
         {
             
         }];
    }
    else
    {
        
        [[CampaignService sharedManager] addRequestedPhotos:campaignCarId campaignId:campaignId imageArray:imageNames latitude:dashboardObj.dashboardTrackingLatitude longitude:dashboardObj.dashboardTrackingLongitude success :^(id responseObject)
         {
//             NSLog(@"successful");
             dashboardObj.isAskMorePhotoPopUpOpen=false;
             dashboardObj.isPopUpOpen = false;
             [myDelegate.notificationDict setObject:@"No" forKey:@"isNotification"];
             dashboardObj.isImagePickerPopUpOpen=false;
             [dashboardObj viewWillAppear:YES];
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
             
         }
                                                    failure:^(NSError *error)
         {
             
         }];
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)cross:(id)sender {
    
    dashboardObj.isImagePickerPopUpOpen=false;
    dashboardObj.isAskMorePhotoPopUpOpen=false;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ok:(id)sender {
    
//    NSLog(@"((((((((((((((((((((((((((((((((((( %@,------- %@",dashboardObj.dashboardTrackingLatitude, dashboardObj.dashboardTrackingLongitude);
    isAWSAlertShow=0;
    if([self performSubmitValidation]) {
        int flag = 0;
        for (int i = 0; i < carPickedImages.count; i++)
        {
            if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
                
                if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
                    flag = flag + 1;
                    
                    break;
                }
            }
        }
        if (flag == 0) {
            [myDelegate showIndicator:@"Uploading Data..."];
            [self performSelector:@selector(installStickerRequest) withObject:nil afterDelay:.1];
            
        }
        else {
            [myDelegate showIndicator:@"Uploading Images..."];
            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.1];
        }
    }
}
#pragma mark - end

#pragma mark - Car submit validation
- (BOOL)performSubmitValidation {
    
    int flag = 0;
    for (int i = 0; i < carPickedImages.count; i++) {
        
        if ([[[carPickedImages objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
            
            flag = flag + 1;
            if (flag == 3) {
                break;
            }
        }
    }
    
    if ((flag < 3)||![[[carPickedImages objectAtIndex:0] objectForKey:@"isSet"] isEqualToString:@"true"]) {
        
        [UserDefaultManager showAlertMessage:@"Please upload at least three images including odometer image."];
        return NO;
    }
    else if(![previousView isEqualToString:@"InstalledStikers"]&&[dashboardObj.dashboardTrackingLatitude floatValue]==0&&[dashboardObj.dashboardTrackingLongitude floatValue]==0) {
        [UserDefaultManager showAlertMessage:@"Turn on Location Services to allow Adogo to determine your location."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (carPickedImages.count == 0) {
        return 0;
    }
    else {
        if (carPickedImages.count == 6) {
            return carPickedImages.count;
        }
        else {
            return carPickedImages.count + 1;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier;
    InstalledStickerCollectionViewCell *cell;
    
    if (carPickedImages.count == 6) {
        identifier = @"carParkedCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [cell displayData:[carPickedImages objectAtIndex:indexPath.row]];
        if ([previousView isEqualToString:@"InstalledStikers"]) {
            switch (indexPath.row) {
                case 0:
                    cell.pickedCarLabel.text = @"Odometer Photo";
                    break;
                case 1:
                    cell.pickedCarLabel.text = @"Front Photo";
                    break;
                case 2:
                    cell.pickedCarLabel.text = @"Rear Photo";
                    break;
                case 3:
                    cell.pickedCarLabel.text = @"Right Photo";
                    break;
                case 4:
                    cell.pickedCarLabel.text = @"Left Photo";
                    break;
                default:
                    cell.pickedCarLabel.text = @"Other Photo";
                    break;
            }
        }
        else
        {
            if (indexPath.row==0) {
                cell.pickedCarLabel.text = @"Odometer Photo";
            }
            else {
                cell.pickedCarLabel.text = @"Upload Photo";
            }
        }
        cell.imagePickerBtn.tag = indexPath.row;
    }
    else {
        if (indexPath.row != carPickedImages.count) {
            identifier = @"carParkedCell";
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell displayData:[carPickedImages objectAtIndex:indexPath.row]];
            cell.imagePickerBtn.tag = indexPath.row;
            if ([previousView isEqualToString:@"InstalledStikers"]) {
                switch (indexPath.row) {
                    case 0:
                        cell.pickedCarLabel.text = @"Odometer Photo";
                        break;
                    case 1:
                        cell.pickedCarLabel.text = @"Front Photo";
                        break;
                    case 2:
                        cell.pickedCarLabel.text = @"Rear Photo";
                        break;
                    case 3:
                        cell.pickedCarLabel.text = @"Right Photo";
                        break;
                    case 4:
                        cell.pickedCarLabel.text = @"Left Photo";
                        break;
                    default:
                        cell.pickedCarLabel.text = @"Other Photo";
                        break;
                }
            }
            else
            {
                if (indexPath.row==0) {
                    cell.pickedCarLabel.text = @"Odometer Photo";
                }
                else {
                    cell.pickedCarLabel.text = @"Upload Photo";
                }
            }
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
    
    if (carPickedImages.count == 6) {
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
            [_stickerCollectionView reloadData];
        }
    }
}
#pragma mark - end

#pragma mark - Show actionsheet method
- (void)showActionSheet {
    
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
//                                                                             NSLog(@"6");
                                                                             
                                                                             [self openDefaultCamera];
                                                                             
                                                                         });
                                                                     }
                                                                     
                                                                 }];
                                                             }
                                                             
                                                         }];
    
//    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//                                                              picker.delegate = self;
//                                                              picker.allowsEditing = NO;
//                                                              picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                                                              picker.navigationBar.tintColor = [UIColor whiteColor];
//                                                              
//                                                              [self presentViewController:picker animated:YES completion:NULL];
//                                                          }];
    
    UIAlertAction * defaultAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
//    if ([previousView isEqualToString:@"InstalledStikers"]) {
        [alert addAction:cameraAction];
//    }
//    else {
//        [alert addAction:cameraAction];
//        [alert addAction:galleryAction];
//    }
    
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
    [_stickerCollectionView reloadData];
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
            
//            NSLog(@"%@",[NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%@/campaign_%@", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],carId, campaignId]);
            
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
                    
                    [self performSelector:@selector(installStickerRequest) withObject:nil afterDelay:.1];
                }
            });
        }
        return nil;
    }];
}
#pragma mark - end

#pragma mark - Show alert single method
- (void)showAlertMessage:(NSString *)title message:(NSString*)message {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showWarning:nil title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
#pragma mark - end
//end
@end
