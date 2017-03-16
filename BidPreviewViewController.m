//
//  BidPreviewViewController.m
//  Adogo
//
//  Created by Ranosys on 20/10/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BidPreviewViewController.h"
#import "BidPreviewCell.h"
#import <AWSS3/AWSS3.h>
#import "SCLAlertView.h"
#import "CampaignService.h"
#import "DashboardViewController.h"

@interface BidPreviewViewController () {

    NSArray *previewTitleArray;
    int isAWSAlertShow;
    UIImage *tempImage;
}
@property (strong, nonatomic) IBOutlet UITableView *bidPreviewTableView;
@property (strong, nonatomic) IBOutlet UIView *retryView;
@end

@implementation BidPreviewViewController
@synthesize previewData, previewSignatureImage, isCampaignEnd;
@synthesize campaignEndImageNames,campaignEndCampaignCarId,campaignEndCampaignId,campaignEndCarId,selectRemoveMeasureTextFieldText, selfRemovalContent, selfRemovalContentURl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.retryView.hidden=YES;
    isAWSAlertShow=0;
    [[self navigationController] setNavigationBarHidden:YES];
    self.bidPreviewTableView.scrollEnabled=false;
    if (isCampaignEnd) {
        previewTitleArray=@[@"Campaign Name" ,@"Car Owner Name", @"Car Plate Number", @"Duration", @"Total Points", @"Distance Covered", @"Days Travelled", @"Total Earning", @"Date Time"];
    }
    else {
        previewTitleArray=@[@"Advertiser Name", @"Campaign Name", @"Brand", @"Duration", @"Bid Price", @"Car Owner Name", @"Car Plate Number", @"IC Number", @"Date Time"];
    }
    self.bidPreviewTableView.backgroundColor=[UIColor whiteColor];
    [self.bidPreviewTableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [myDelegate showIndicator];
    [self performSelector:@selector(uploadImage) withObject:nil afterDelay:.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[self navigationController] setNavigationBarHidden:NO];
}

#pragma mark - Get image name using timeline
- (NSString *)getImageName {
    
    CGRect rect;
    rect=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    
    UIImage *screenShot=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    tempImage=screenShot;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpeg",datestr,[UserDefaultManager getValue:@"userId"]];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
    NSData * imageData = UIImageJPEGRepresentation(screenShot, 1.0);
    [imageData writeToFile:filePath atomically:YES];
    return fileName;
}
#pragma mark - end

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier;
    BidPreviewCell *cell;
    
    if (indexPath.row==9) {
        
        simpleTableIdentifier = @"TermConditionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
         if (isCampaignEnd) {
             cell.TermConditionLabel.text=@"I confirm that the campaign has been successfully advertised and that the photos & information given is real and taken on the day this is signed.";
         }
         else {
             cell.TermConditionLabel.text=@"I acknowledge and accept all terms and conditions from Adogo and confirm them.";
         }
    }
    else if (indexPath.row==10) {
        
        simpleTableIdentifier = @"signatureCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        cell.previewSignatureImage.layer.borderColor=[UIColor blackColor].CGColor;
        cell.previewSignatureImage.layer.borderWidth=1.0;
        cell.previewSignatureImage.image=previewSignatureImage;
    }
    else {
        
        simpleTableIdentifier = @"BidPreviouCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        cell.previewDetail.hidden=NO;
        cell.previewTitle.hidden=NO;
        
        if (isCampaignEnd) {
            switch (indexPath.row) {
                case 0:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:0];
                    cell.previewDetail.text=previewData.campaignName;
                    break;
                case 1:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:1];
                    cell.previewDetail.text=previewData.carOwnerName;
                    break;
                case 2:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:2];
                    cell.previewDetail.text=previewData.carPlateNumber;
                    break;
                case 3:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:3];
                    cell.previewDetail.text=previewData.duration;
                    break;
                case 4:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:4];
                    cell.previewDetail.text=previewData.totalPoints;
                    break;
                case 5:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:5];
                    cell.previewDetail.text=previewData.distanceCovered;
                    break;
                case 6:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:6];
                    cell.previewDetail.text=previewData.daysTravelled;
                    break;
                case 7:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:7];
                    cell.previewDetail.text=previewData.totalEarning;
                    break;
                case 8:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:8];
                    cell.previewDetail.text=previewData.dateTime;
                    break;
                default:
                    break;
            }
        }
        else {
            switch (indexPath.row) {
                case 0:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:0];
                    cell.previewDetail.text=previewData.advertiserName;
                    break;
                case 1:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:1];
                    cell.previewDetail.text=previewData.campaignName;
                    break;
                case 2:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:2];
                    cell.previewDetail.text=previewData.brand;
                    break;
                case 3:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:3];
                    cell.previewDetail.text=previewData.duration;
                    break;
                case 4:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:4];
                    cell.previewDetail.text=[NSString stringWithFormat:@"S$%@",previewData.myBid];
                    break;
                case 5:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:5];
                    cell.previewDetail.text=previewData.carOwnerName;
                    break;
                case 6:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:6];
                    cell.previewDetail.text=previewData.carPlateNumber;
                    break;
                case 7:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:7];
                    cell.previewDetail.text=previewData.ICNumber;
                    break;
                case 8:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:8];
                    cell.previewDetail.text=previewData.dateTime;
                    break;
                case 9:
                    cell.previewTitle.text=[previewTitleArray objectAtIndex:8];
                    cell.previewDetail.text=previewData.dateTime;
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.row==10) {
        return ([[UIScreen mainScreen] bounds].size.height-440.0);
    }
    else {
        return 44.0;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
}

- (void)uploadImage {

    isAWSAlertShow=0;
    previewData.signaturePath = [self getImageName];
//    [myDelegate showIndicator];
    [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:0.0];
}
#pragma mark - Upload AWS images
- (void)uploadAWSImages {

    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:previewData.signaturePath];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.contentType = @"image";
    uploadRequest.key = previewData.signaturePath;
    if (isCampaignEnd) {
        
        uploadRequest.bucket = [NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%@/campaign_%@", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],campaignEndCarId, campaignEndCampaignId];
    }
    else {
        uploadRequest.bucket = [NSString stringWithFormat:@"%@/uploads/biddings/bid_%@", [UserDefaultManager getValue:@"BucketName"], previewData.bidId];
    }
    [self upload:uploadRequest];
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addButton:@"Retry" actionBlock:^(void) {
                            
                            [myDelegate showIndicator];
                            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.0];
                        }];
                        [alert showWarning:nil title:@"Alert" subTitle:@"There was an error faced while uploading the image. Please try again." closeButtonTitle:nil duration:0.0f];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addButton:@"Retry" actionBlock:^(void) {
                            
                            [myDelegate showIndicator];
                            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.0];
                        }];
                        [alert showWarning:nil title:@"Alert" subTitle:@"There was an error faced while uploading the image. Please try again." closeButtonTitle:nil duration:0.0f];
                    }
                });
            }
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (isCampaignEnd) {
                    [self performSelector:@selector(campaignEndedService) withObject:nil afterDelay:0.0];
                }
                else {
                    [self performSelector:@selector(acceptRejectCampaignbid) withObject:nil afterDelay:0.0];
                }
            });
        }
        return nil;
    }];
}
#pragma mark - end

- (void)campaignEndedService {
    
    NSMutableDictionary *tempImageDict = [NSMutableDictionary new];
    [tempImageDict setObject:[campaignEndImageNames valueForKeyPath:@"signature.id"] forKey:@"id"];
    [tempImageDict setObject:[campaignEndImageNames valueForKeyPath:@"signature.is_approved"] forKey:@"is_approved"];
    [tempImageDict setObject:previewData.signaturePath forKey:@"name"];
    [campaignEndImageNames setObject:tempImageDict forKey:@"signature"];
    
    //    NSMutableDictionary *tempImageDict = [NSMutableDictionary new];
    //    [tempImageDict setObject:signatureId forKey:@"id"];
    //    [tempImageDict setObject:isSignatureApproved forKey:@"is_approved"];
    //    [tempImageDict setObject:signatureImageName forKey:@"name"];
    //    [imageNames setObject:tempImageDict forKey:@"signature"];
    
    [[CampaignService sharedManager] setCampaignEndData:campaignEndCampaignId carId:campaignEndCarId campaignCarsId:campaignEndCampaignCarId installationRemoveType:selectRemoveMeasureTextFieldText imageNames:campaignEndImageNames success:^(id responseObject) {
        
        if ([selectRemoveMeasureTextFieldText isEqualToString:@"Self Removal"]) {
            
            NSURL *youTubeLink;
            int flag=0;
            NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
            NSArray *matches = [linkDetector matchesInString:selfRemovalContent options:0 range:NSMakeRange(0, [selfRemovalContent length])];
            for (NSTextCheckingResult *match in matches) {
                if ([match resultType] == NSTextCheckingTypeLink) {
                    youTubeLink = [match URL];
                    flag=1;
//                    NSLog(@"found URL: %@", youTubeLink);
                }
            }
            
            if (flag==0) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"OK" actionBlock:^(void) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
                    [self.navigationController pushViewController:dashboard animated:NO];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
            }
            else {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"OK" actionBlock:^(void) {
                    
                    [[UIApplication sharedApplication] openURL:youTubeLink];
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
                    [self.navigationController pushViewController:dashboard animated:NO];
                }];
                [alert addButton:@"Cancel" actionBlock:^(void) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
                    [self.navigationController pushViewController:dashboard animated:NO];
                }];
                
                [alert showWarning:nil title:@"Alert" subTitle:selfRemovalContent closeButtonTitle:nil duration:0.0f];
            }
        }
        else {
            
            
            if (((selfRemovalContent==nil)||[selfRemovalContent isEqualToString:@""])) {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"OK" actionBlock:^(void) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
                    [self.navigationController pushViewController:dashboard animated:NO];
                    
                }];
                [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
            }
            else {
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"OK" actionBlock:^(void) {
                    
                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                    [alert addButton:@"OK" actionBlock:^(void) {
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
                        [self.navigationController pushViewController:dashboard animated:NO];
                    }];
                    
                    [alert showWarning:nil title:nil subTitle:[NSString stringWithFormat:@"Workshop address and instructions\n\n%@",selfRemovalContent] closeButtonTitle:nil duration:0.0f];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
            }
        }
    }
                                                failure:^(NSError *error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [myDelegate stopIndicator];
                                                        self.retryView.hidden=NO;
                                                        
                                                    });
                                                    
                                                }];
}

- (void)acceptRejectCampaignbid {
    
    [[CampaignService sharedManager] acceptRejectCampaignbidService:previewData.bidId campaignId:previewData.campaignId bidAmount:previewData.myBid signatureImage:previewData.signaturePath rejectReason:@"" isAccept:@"true" previewDataModel:previewData success:^(id responseObject) {
        
        [myDelegate stopIndicator];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
            [self.navigationController pushViewController:dashboard animated:NO];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
        
    }failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [myDelegate stopIndicator];
            self.retryView.hidden=NO;
            
        });
        
    }];
}

- (IBAction)retryUpload:(UIButton *)sender {
    
    if (isCampaignEnd) {
        self.retryView.hidden=YES;
        [myDelegate showIndicator];
        [self performSelector:@selector(campaignEndedService) withObject:nil afterDelay:0.1];
    }
    else {
        self.retryView.hidden=YES;
        [myDelegate showIndicator];
        [self performSelector:@selector(acceptRejectCampaignbid) withObject:nil afterDelay:.1];
    }
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
