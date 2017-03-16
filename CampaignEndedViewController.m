//
//  CampaignEndedViewController.m
//  Adogo
//
//  Created by Hema on 18/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CampaignEndedViewController.h"
#import "CamapignEndedViewCell.h"
#import "LBorderView.h"
#import "SignatureViewController.h"
#import "CmsContentViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCLAlertView.h"
#import "CampaignService.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "BidPreviewViewController.h"
#import "BidInfoModel.h"
#import "Internet.h"

#define kCellsPerRow 2
@interface CampaignEndedViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIToolbarDelegate>
{
    NSMutableArray *imagesArray;
    NSMutableArray *nameLabelArray;
    NSMutableArray *removeMethodArray;
    int selectedIndex;
    NSString *selectImagePickerView;
    int selectedPickerIndex;
    int isAWSAlertShow;
}
@property (weak, nonatomic) IBOutlet UIScrollView *campaignEndedScrollView;
@property (weak, nonatomic) IBOutlet UIView *campaignEndedView;
@property (weak, nonatomic) IBOutlet UILabel *campaignEndedTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *setImagesCollectionView;
@property (strong, nonatomic) IBOutlet UIView *selectRemoveMeasureView;
@property (weak, nonatomic) IBOutlet UITextField *selectRemoveMeasureTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectRemoveMeasureBtn;
@property (weak, nonatomic) IBOutlet UIButton *signatureBtn;
@property (weak, nonatomic) IBOutlet UIButton *dropDownBtn;
@property (weak, nonatomic) IBOutlet UIButton *chkUnchkBtn;
@property (weak, nonatomic) IBOutlet UIButton *trmsChkUnchkBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@property (strong, nonatomic) IBOutlet UIImageView *signatureImageView;
@end

@implementation CampaignEndedViewController
@synthesize campaignEndedScrollView,campaignEndedView,campaignEndedTitleLabel,setImagesCollectionView,selectRemoveMeasureTextField,selectRemoveMeasureBtn,signatureBtn,dropDownBtn,trmsChkUnchkBtn,chkUnchkBtn,signatureImageName,carId,campaignId,campaignCarId,cmsContent,carImagesArray, isUpdated, signatureId,isSignatureApproved;
@synthesize dashboardObj, signatureImage, campaignSubmitPreview;
@synthesize resetData;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isAWSAlertShow=0;
    self.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0.6f];
    [self addBorderCornerRadius];
    removeMethodArray = [NSMutableArray new];
    nameLabelArray=[[NSMutableArray alloc] initWithObjects:@"Odometer Photo",@"Front",@"Left Side",@"Right Side",@"Rear", nil];
    imagesArray=[[NSMutableArray alloc] initWithObjects:@"odometer.png",@"car_front.png",@"car_left.png",@"car_right.png",@"car_rear.png", nil];
    _pickerView.translatesAutoresizingMaskIntoConstraints = YES;
    _pickerToolBar.translatesAutoresizingMaskIntoConstraints = YES;
    [self hidePickerView];
    if (!isUpdated) {
        
        resetData=[NSMutableArray new];
        [self setCarImages];
    }
    selectedPickerIndex = 0;
    isSignatureApproved = @"Accepted";
    signatureImageName = @"";
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    
    [myDelegate showIndicator];
    [self performSelector:@selector(getRemoveMethodData) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBorderCornerRadius
{
    [campaignEndedView setCornerRadius:3.0f];
    _selectRemoveMeasureView.layer.cornerRadius = 3.0f;
    _selectRemoveMeasureView.layer.masksToBounds = YES;
    _selectRemoveMeasureView.layer.borderWidth = 1.5f;
    _selectRemoveMeasureView.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    _selectRemoveMeasureView.backgroundColor = [UIColor clearColor];
    [signatureBtn setCornerRadius:3.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES];
    
    [self signatureImageFraming];
}

- (void)signatureImageFraming {

    self.signatureImageView.translatesAutoresizingMaskIntoConstraints=YES;
    self.campaignEndedView.translatesAutoresizingMaskIntoConstraints=YES;
    if ([signatureImageName isEqualToString:@""]) {
        
        self.signatureImageView.frame=CGRectMake(8, 640, [[UIScreen mainScreen] bounds].size.width-36, 0);
        self.campaignEndedView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 750);
    }
    else {
        
        self.signatureImageView.image=signatureImage;
        self.signatureImageView.frame=CGRectMake(8, 640, [[UIScreen mainScreen] bounds].size.width-36, 105);
        self.campaignEndedView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, 856);
    }
    
    self.campaignEndedScrollView.contentSize = CGSizeMake(0,self.campaignEndedView.frame.size.height);
}

- (void)setCarImages {
    
    if (resetData.count==0) {
    
    carImagesArray = [NSMutableArray new];
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [tempDic setObject:@"0" forKey:@"id"];
    [tempDic setObject:@"Pending" forKey:@"is_approved"];
    [tempDic setObject:@"false" forKey:@"isUploaded"];
    [carImagesArray addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [tempDic setObject:@"0" forKey:@"id"];
    [tempDic setObject:@"Pending" forKey:@"is_approved"];
    [tempDic setObject:@"false" forKey:@"isUploaded"];
    [carImagesArray addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [tempDic setObject:@"0" forKey:@"id"];
    [tempDic setObject:@"Pending" forKey:@"is_approved"];
    [tempDic setObject:@"false" forKey:@"isUploaded"];
    [carImagesArray addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [tempDic setObject:@"0" forKey:@"id"];
    [tempDic setObject:@"Pending" forKey:@"is_approved"];
    [tempDic setObject:@"false" forKey:@"isUploaded"];
    [carImagesArray addObject:tempDic];
    
    tempDic = [NSMutableDictionary new];
    [tempDic setObject:@"false" forKey:@"isSet"];
    [tempDic setObject:@"0" forKey:@"id"];
    [tempDic setObject:@"Pending" forKey:@"is_approved"];
    [tempDic setObject:@"false" forKey:@"isUploaded"];
    [carImagesArray addObject:tempDic];
    }
    else {
        carImagesArray=[[NSMutableArray alloc] initWithArray:resetData
                                                   copyItems:YES];
    }
    [setImagesCollectionView reloadData];
}
#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"firstCell";
    CamapignEndedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    //settinng collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.setImagesCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.setImagesCollectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow -1)-10;
    CGFloat cellWidth = (availableWidthForCells / kCellsPerRow);
    flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    cell.odometerPhototBtn.userInteractionEnabled=NO;
    [cell.odometerPhototBtn setImage:[UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    cell.odometerPhotoLabel.text=[nameLabelArray objectAtIndex:indexPath.row];
    cell.odometerPhototBtn.tag=(int)indexPath.row;
    cell.odometerPhotoView.image=[[carImagesArray objectAtIndex:indexPath.row]objectForKey:@"image"];
    cell.warningButton.tag=indexPath.row;
    
    [cell.warningButton addTarget:self action:@selector(warningPopUpView:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!isUpdated) {
        cell.warningButton.hidden=YES;
        if ([[[carImagesArray objectAtIndex:indexPath.row] objectForKey:@"isSet"] isEqualToString:@"true"])
        {
            cell.odometerPhotoLabel.hidden=YES;
            cell.odometerPhototBtn.hidden=YES;
        }
        else
        {
            cell.odometerPhotoLabel.hidden=NO;
            cell.odometerPhototBtn.hidden=NO;
        }
    }
    else {
        if ([[[carImagesArray objectAtIndex:(int)indexPath.row] objectForKey:@"isUploaded"] isEqualToString:@"true"]) {
            
            cell.warningButton.hidden=YES;
            [self downloadImages:cell imageUrl:[[carImagesArray objectAtIndex:(int)indexPath.row] objectForKey:@"imageUrl"]];
        }
        else {
            cell.warningButton.hidden=NO;
            if ([[[carImagesArray objectAtIndex:indexPath.row] objectForKey:@"isSet"] isEqualToString:@"true"])
            {
                cell.odometerPhotoLabel.hidden=YES;
                cell.odometerPhototBtn.hidden=YES;
            }
            else
            {
                cell.odometerPhotoLabel.hidden=NO;
                cell.odometerPhototBtn.hidden=NO;
            }
        }
    }
    return cell;
}

- (IBAction)warningPopUpView:(UIButton *)sender {
    
    [self showAlertMessage:@"Alert" message:[[carImagesArray objectAtIndex:[sender tag]]objectForKey:@"warning"]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[carImagesArray objectAtIndex:(int)indexPath.row] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
        if (indexPath.row == 0) {
            selectedIndex = (int)indexPath.row;
            selectImagePickerView = @"end_mileage_reading";
            
            [self openCamera];
        }
        else if (indexPath.row == 1) {
            selectedIndex = (int)indexPath.row;
            selectImagePickerView = @"front";
            
            [self openCamera];
        }
        else if (indexPath.row == 2) {
            selectedIndex = (int)indexPath.row;
            selectImagePickerView = @"left";
            
            [self openCamera];
        }
        else if (indexPath.row == 3) {
            selectedIndex = (int)indexPath.row;
            selectImagePickerView = @"right";
            
            [self openCamera];
        }
        else if (indexPath.row == 4) {
            selectedIndex = (int)indexPath.row;
            selectImagePickerView = @"rear";
            
            [self openCamera];
        }
    }
}
#pragma mark - end

#pragma mark - Camera methods
- (void)openCamera
{
    
     /* //Set for testing purpose
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
    */
    ///*
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
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
//                    NSLog(@"6");
                    
                    [self openDefaultCamera];
                });
            }
            
        }];
    }
   //  */
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

#pragma mark - Show alert messages
- (void)showAlertMessage:(NSString *)title message:(NSString*)message {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showWarning:nil title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(CamapignEndedViewCell *)cell imageUrl:(NSString *)imageUrl {
    
    __weak CamapignEndedViewCell *weakCell = cell;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.odometerPhotoView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@""] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        weakCell.odometerPhotoLabel.hidden=YES;
        weakCell.odometerPhototBtn.hidden=YES;
        weakCell.odometerPhotoView.image=image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)info
{
    UIImage *image = [image1 fixOrientation];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    tempDict = [[carImagesArray objectAtIndex:selectedIndex] mutableCopy];
    [tempDict setObject:image forKey:@"image"];
    [tempDict setObject:@"true" forKey:@"isSet"];
    [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
    [tempDict setObject:@"false" forKey:@"isUploaded"];
    
    [carImagesArray replaceObjectAtIndex:selectedIndex withObject:tempDict];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [setImagesCollectionView reloadData];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Picker view methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return removeMethodArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *pickerStr;
    pickerStr = [[removeMethodArray objectAtIndex:row] objectForKey:@"method_name"];
    return pickerStr;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width,20)];
        pickerLabel.font = [UIFont railwayRegularWithSize:14];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    NSString *pickerStr;
    pickerStr = [[removeMethodArray objectAtIndex:row] objectForKey:@"method_name"];
    pickerLabel.text = pickerStr;
    return pickerLabel;
}

- (void)hidePickerView {
    
    campaignEndedScrollView.scrollEnabled = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _pickerView.frame = CGRectMake(_pickerView.frame.origin.x, 1000, self.view.bounds.size.width, 200);
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, 1000, self.view.bounds.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}

- (void)showPickerView {
    
    [_pickerView reloadAllComponents];
      [_pickerView selectRow:selectedPickerIndex inComponent:0 animated:YES];
    _pickerView.backgroundColor=[UIColor whiteColor];
    campaignEndedScrollView.scrollEnabled = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _pickerView.frame = CGRectMake(_pickerView.frame.origin.x, self.view.frame.size.height -  _pickerView.frame.size.height, self.view.bounds.size.width, 200);
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, _pickerView.frame.origin.y-44, self.view.bounds.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
    [_pickerView setNeedsLayout];
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)cancelToolBarButtonAction:(id)sender {
    [self hidePickerView];
}

- (IBAction)toolBarDoneClicked:(id)sender
{
    [self hidePickerView];
    
    if ((removeMethodArray != nil)&&removeMethodArray.count!=0)
    {
        NSInteger index = [_pickerView selectedRowInComponent:0];
        selectedPickerIndex = (int)index;
        selectRemoveMeasureTextField.text = [[removeMethodArray objectAtIndex:index] objectForKey:@"method_name"];
    }
}

- (IBAction)cancelCampaignPopUpAction:(id)sender
{
    dashboardObj.isPopUpOpen = false;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectRemoveMeasureBtnAction:(id)sender
{
    if ((removeMethodArray != nil)&&removeMethodArray.count!=0){
    [campaignEndedScrollView setContentOffset:CGPointMake(0, 315) animated:YES];
    [self showPickerView];
}
}

- (IBAction)checkTermsConditionBtnAction:(UIButton *)sender
{
    if (sender.selected) {
        sender.selected = NO;
    }
    else {
        sender.selected = YES;
    }
}

- (IBAction)termsConditionBtnAction:(id)sender
{
    CmsContentViewController *objCms = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CmsContentViewController"];
    objCms.cmsId = @"BidInfo";
    objCms.title = @"Terms and Conditions";
    objCms.cmsContent = cmsContent;
    objCms.gotItString = @"Dashboard";
    dashboardObj.isPopUpOpen = false;
    [myDelegate.currentNavController pushViewController:objCms animated:YES];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)checkUncheckBtnAction:(UIButton *)sender
{
    if (sender.selected) {
        sender.selected = NO;
    }
    else {
        sender.selected = YES;
    }
}

- (IBAction)addSignatureBtnAction:(id)sender
{
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignatureViewController *signatureViewObj =[storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
        signatureViewObj.campaignEndObj=self;
        signatureViewObj.isCampaignEndScreen = true;
        signatureViewObj.previousView = @"campaign";
        signatureViewObj.carId = carId;
    signatureViewObj.campaignId = campaignId;
    [self presentViewController:signatureViewObj animated:YES completion:nil];
}

- (IBAction)resetBtnAction:(id)sender {
    
    chkUnchkBtn.selected = NO;
    trmsChkUnchkBtn.selected = NO;
    [self setCarImages];
    selectedPickerIndex = 0;
    selectRemoveMeasureTextField.text = @"";
    signatureImage=nil;
    signatureImageName=@"";
    [self signatureImageFraming];
    [setImagesCollectionView reloadData];
}

- (IBAction)submitBtnAction:(id)sender
{
    [self.view endEditing:YES];
    isAWSAlertShow=0;
    campaignEndedScrollView.scrollEnabled = YES;
    [campaignEndedScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if([self performSubmitValidation])
    {
        int flag = 0;
        for (int i = 0; i < carImagesArray.count; i++) {
            
            if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
                
                if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
                    flag = flag + 1;
                    
                    break;
                }
            }
        }
        if (flag == 0)
        {
            
            [self campaignEndedService];
//            [myDelegate showIndicator:@"Uploading Data..."];
//            [self performSelector:@selector(campaignEndedService) withObject:nil afterDelay:.1];
        }
        else {
            
            [myDelegate showIndicator:@"Uploading Images..."];
            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.1];
        }
    }
}
#pragma mark - end

#pragma mark - Webservice method
- (void)getRemoveMethodData
{
    [[CampaignService sharedManager] getRemoveMethods:^(id responseObject)
     {
         
         removeMethodArray = [[responseObject objectForKey:@"data"]mutableCopy];
         [_pickerView reloadAllComponents];
     }
                                              failure:^(NSError *error)
     {
         dashboardObj.isPopUpOpen = false;
         [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (void)campaignEndedService {
    
    NSMutableDictionary *imageNames = [NSMutableDictionary new];
    NSMutableDictionary *tempImageDict;
    for (int i = 0; i < carImagesArray.count; i++) {
        if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
            tempImageDict = [NSMutableDictionary new];
            [tempImageDict setObject:[[carImagesArray objectAtIndex:i] objectForKey:@"id"] forKey:@"id"];
            [tempImageDict setObject:[[carImagesArray objectAtIndex:i] objectForKey:@"imageName"] forKey:@"name"];
            [tempImageDict setObject:[[carImagesArray objectAtIndex:i] objectForKey:@"is_approved"] forKey:@"is_approved"];
            
            if (i == 0) {
                [imageNames setObject:tempImageDict forKey:@"end_mileage_reading"];
            }
            else if (i == 1){
                [imageNames setObject:tempImageDict forKey:@"front"];
            }
            else if (i == 2){
                [imageNames setObject:tempImageDict forKey:@"left"];
            }
            else if (i == 3){
                [imageNames setObject:tempImageDict forKey:@"right"];
            }
            else if (i == 4){
                [imageNames setObject:tempImageDict forKey:@"rear"];
            }
        }
    }
    tempImageDict = [NSMutableDictionary new];
    [tempImageDict setObject:signatureId forKey:@"id"];
    [tempImageDict setObject:isSignatureApproved forKey:@"is_approved"];
    [tempImageDict setObject:signatureImageName forKey:@"name"];
    [imageNames setObject:tempImageDict forKey:@"signature"];

    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BidPreviewViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"BidPreviewViewController"];
        nextView.previewData=[campaignSubmitPreview copy];
        nextView.previewSignatureImage=signatureImage;
        nextView.campaignEndCarId=carId;
        nextView.campaignEndCampaignId=campaignId;
        nextView.campaignEndCampaignCarId=campaignCarId;
        nextView.selectRemoveMeasureTextFieldText=selectRemoveMeasureTextField.text;
        nextView.campaignEndImageNames=[imageNames mutableCopy];
        nextView.isCampaignEnd=YES;
        selectRemoveMeasureTextField.text = [[removeMethodArray objectAtIndex:selectedPickerIndex] objectForKey:@"method_name"];
        nextView.selfRemovalContent=[[removeMethodArray objectAtIndex:selectedPickerIndex] objectForKey:@"content"];
        [myDelegate.currentNavController pushViewController:nextView animated:NO];
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }
//    [[CampaignService sharedManager] setCampaignEndData:campaignId carId:carId campaignCarsId:campaignCarId installationRemoveType:selectRemoveMeasureTextField.text imageNames:imageNames success:^(id responseObject) {
//        
//        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//        [alert addButton:@"OK" actionBlock:^(void) {
//            
//            dashboardObj.isPopUpOpen = false;
//            [dashboardObj viewWillAppear:YES];
//            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//        }];
//        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
//    }
//                                                failure:^(NSError *error) {
//                                                    
//                                        }];
}
#pragma mark - end

#pragma mark - Submit validation
- (BOOL)performSubmitValidation
{

    int flag = 0;
    for (int i = 0; i < carImagesArray.count; i++)
    {
        if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"])
        {
            flag = flag + 1;
            if (flag == 5) {
                break;
            }
        }
    }
    if (flag < 5)
    {
        [UserDefaultManager showAlertMessage:@"Please upload all images."];
        return NO;
    }

    else if ([selectRemoveMeasureTextField isEmpty])
    {
        [UserDefaultManager showAlertMessage:@"Please select remove method."];
        return NO;
    }
    else if (!trmsChkUnchkBtn.selected)
    {
        [UserDefaultManager showAlertMessage:@"Please accept terms and conditions."];
        return NO;
    }
    else if (!chkUnchkBtn.selected)
    {
        [UserDefaultManager showAlertMessage:@"Please accept details are true."];
        return NO;
    }
    else if ([signatureImageName isEqualToString:@""])
    {
        [UserDefaultManager showAlertMessage:@"Please upload the signature image."];
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Upload AWS images
- (void)uploadAWSImages {
    
    for (int i = 0; i < carImagesArray.count; i++) {
        if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]&&[[[carImagesArray objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]){
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:[[carImagesArray objectAtIndex:i] objectForKey:@"imageName"]];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.contentType = @"image";
            uploadRequest.key = [[carImagesArray objectAtIndex:i] objectForKey:@"imageName"];
            
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
                [myDelegate stopIndicator];
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
//                NSLog(@"complete");
                
                if (isAWSAlertShow==0) {
                    NSMutableDictionary *tempDict = [NSMutableDictionary new];
                    tempDict = [carImagesArray objectAtIndex:index];
                    [tempDict setObject:@"true" forKey:@"isUploaded"];
                    [carImagesArray replaceObjectAtIndex:index withObject:tempDict];
                    
                    int flag = 0;
                    for (int i = 0; i < carImagesArray.count; i++) {
                        
                        if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isSet"] isEqualToString:@"true"]) {
                            
                            if ([[[carImagesArray objectAtIndex:i] objectForKey:@"isUploaded"] isEqualToString:@"false"]) {
                                flag = flag + 1;
                                
                                break;
                            }
                        }
                    }
                    if (flag == 0)
                    {
                        [myDelegate stopIndicator];
                        [self campaignEndedService];
                        //                    [myDelegate showIndicator:@"Uploading Data..."];
                        //                    [self performSelector:@selector(campaignEndedService) withObject:nil afterDelay:.1];
                    }
                }
                
            });
        }
        return nil;
    }];
}
#pragma mark - end
@end
