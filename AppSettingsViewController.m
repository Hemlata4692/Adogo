//
//  AppSettingsViewController.m
//  Adogo
//
//  Created by Monika on 24/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "SwitchTableViewCell.h"
#import "TrackingTableViewCell.h"
#import "AppSettingPopUpViewController.h"
#import "MyButton.h"
#import "CampaignService.h"
#import "RedemptionViewController.h"
#import "ChangePasswordViewController.h"
#import "UserService.h"
#import "GlobalPopupViewController.h"
#import "SCLAlertView.h"
#import "BeaconListViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppSettingsViewController ()<PopupViewDelegate>
{
    NSString *pickerSelelectString;
    NSArray *trackingType;
    int selectedIndex, lastSelectedIndex;
    NSString *notificationNote, *dailyMileageNote;
    NSString *switchState0, *switchState1;
    NSString  *uniqueTrackGPSValue;
    
}
@property (strong, nonatomic) IBOutlet UITableView *appSettingsTableView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@end

@implementation AppSettingsViewController
@synthesize appSettingsTableView,pickerView,pickerToolbar,uniqueTrackiBeaconValue;
@synthesize isProfileStatusScreen;
@synthesize isBeaconCancel;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"App Settings";
    pickerView.translatesAutoresizingMaskIntoConstraints = YES;
    pickerToolbar.translatesAutoresizingMaskIntoConstraints = YES;
    [pickerView setNeedsLayout];
    notificationNote = [UserDefaultManager getValue:@"notificationNote"];
    dailyMileageNote = [UserDefaultManager getValue:@"dailMilageReportNote"];
    switchState0 = [UserDefaultManager getValue:@"isDailyMilageReportOn"];
    switchState1 = [UserDefaultManager getValue:@"isNotificationOn"];
    
    uniqueTrackGPSValue = @"";
    uniqueTrackiBeaconValue = @"";
    
    trackingType = @[@"Phone Mileage Track", @"Auto Mileage Tracker", @"Hardware GPS Track"];
    if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Phone"]) {
        
         selectedIndex = 0;
    }
    else if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Ibeacon"]) {
         selectedIndex = 1;
        uniqueTrackiBeaconValue = [UserDefaultManager getValue:@"iBeaconSerialNumber"];
    }
    else if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Gps"]) {
         selectedIndex = 2;
        uniqueTrackGPSValue = [UserDefaultManager getValue:@"gpsIMEINumber"];
    }
    pickerSelelectString = [trackingType objectAtIndex:selectedIndex];
    
    isBeaconCancel=NO;
    [myDelegate showIndicator];
    [self performSelector:@selector(getDefaultCarInformation) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (isBeaconCancel) {
        isBeaconCancel=NO;
        selectedIndex=lastSelectedIndex;
    }
    
    //Add back button
    if (isProfileStatusScreen) {
        [self addLeftBackBarButtonWithImage:[UIImage imageNamed:@"back_white.png"]];
    }
}

- (void)addLeftBackBarButtonWithImage:(UIImage *)backImage {
    
    self.navigationItem.leftBarButtonItems=nil;
    self.navigationItem.leftBarButtonItem=nil;
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:framing];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - TableView delegate and datasource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (selectedIndex == 0) {
        if ((indexPath.row==0) || (indexPath.row==1) || (indexPath.row==2) || (indexPath.row==3))
        {
            return 45;
        }
        else if ((indexPath.row==4) || (indexPath.row==5)|| (indexPath.row==6))
        {
            return 60;
        }
        else
        {
            return 45;
        }
    }
    else {
        if ((indexPath.row==0) || (indexPath.row==1) || (indexPath.row==2) || (indexPath.row==3) || (indexPath.row==4))
        {
            return 45;
        }
        else if ((indexPath.row==5) || (indexPath.row==6) || (indexPath.row==7))
        {
            return 60;
        }
        else
        {
            return 45;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedIndex == 0) {
        return 7;
    }
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row==0) || (indexPath.row==1))
    {
        SwitchTableViewCell *cell;
        NSString *simpleTableIdentifier = @"SwitchCell";
        cell = [appSettingsTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.info.translatesAutoresizingMaskIntoConstraints = YES;
        if (indexPath.row==0)
        {
            cell.infoLabel.text=@"Daily Mileage Report";
            cell.info.frame = CGRectMake(135, 0, 35, 45);
        }
        else if (indexPath.row==1)
        {
            cell.infoLabel.text=@"Notification";
            cell.info.frame = CGRectMake(77, 0, 35, 45);
        }
        cell.switchBtn.Tag=(int)indexPath.row;
        cell.switchBtn.sectionTag=(int)indexPath.section;
        
        if (indexPath.row == 0)
        {
            if (![[UserDefaultManager getValue:@"isDailyMilageReportOn"] isEqualToString: @"1"])
            {
                cell.switchBtn.on=0;
                [cell.switchBtn setBackgroundImage:[UIImage imageNamed:@"off_btn.png"] forState:UIControlStateNormal];
            }
            else
            {
                cell.switchBtn.on=1;
                [cell.switchBtn setBackgroundImage:[UIImage imageNamed:@"on_btn.png"] forState:UIControlStateNormal];
            }
        }
        else
        {
            if (![[UserDefaultManager getValue:@"isNotificationOn"] isEqualToString: @"1"])
            {
                cell.switchBtn.on=0;
                [cell.switchBtn setBackgroundImage:[UIImage imageNamed:@"off_btn.png"] forState:UIControlStateNormal];
            }
            else
            {
                cell.switchBtn.on=1;
                [cell.switchBtn setBackgroundImage:[UIImage imageNamed:@"on_btn.png"] forState:UIControlStateNormal];
            }
        }
        cell.info.tag = indexPath.row;
        [cell.switchBtn addTarget:self action:@selector(switchViewChanged:) forControlEvents:UIControlEventTouchUpInside];
        [cell.info addTarget:self action:@selector(infoPopUpView:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        TrackingTableViewCell *cell ;
        NSString *simpleTableIdentifier = @"TrackCell";
        cell = [appSettingsTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[TrackingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.serialNumberText.hidden= YES;
        cell.serialNumberText.enabled = false;
        cell.buyItemsButton.hidden= YES;
        cell.trackLabel.hidden = YES;
        
        if (selectedIndex == 0) {
            cell.serialNumberText.text = @"";
            if (indexPath.row==2)
            {
                cell.trackLabel.text=@"Tracking Activation Method (Default Car)";
                cell.trackLabel.hidden= NO;
                cell.trackLabel.textColor = [UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f];
                cell.trackLabel.font = [UIFont railwayBoldWithSize:13];
            }
            else if (indexPath.row==3)
            {
                cell.trackLabel.text = pickerSelelectString;
                
                cell.trackLabel.hidden= NO;
                cell.dropdownButton.hidden = NO;
            }
            else if (indexPath.row==4)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton setTitle:@"Buy Items" forState:UIControlStateNormal];
             [cell.buyItemsButton addTarget:self action:@selector(buyItemsAction) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (indexPath.row==5)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton setTitle:@"Change Password" forState:UIControlStateNormal];
                [cell.buyItemsButton addTarget:self action:@selector(changePasswordAction) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (indexPath.row==6)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton setTitle:@"Delete Account" forState:UIControlStateNormal];
                [cell.buyItemsButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else {
            if (indexPath.row==2)
            {
                cell.trackLabel.text=@"Tracking Activation Method (Default Car)";
                cell.trackLabel.hidden= NO;
                cell.trackLabel.textColor = [UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f];
                cell.trackLabel.font = [UIFont railwayBoldWithSize:13];
            }
            else if (indexPath.row==3)
            {
                cell.trackLabel.text = pickerSelelectString;
                
                cell.trackLabel.hidden= NO;
                cell.dropdownButton.hidden = NO;
                
            }
            else if (indexPath.row==4)
            {
                cell.serialNumberText.hidden= NO;
                if (selectedIndex == 1) {
                    //Text placeholder color
                    cell.serialNumberText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Serial Number" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
                    NSArray * beaconValueArray = [uniqueTrackiBeaconValue componentsSeparatedByString:@"."];
//                    NSLog(@"beaconValueArray %@",beaconValueArray);
                    cell.serialNumberText.text = [NSString stringWithFormat:@"Major: %@ Minor: %@",[beaconValueArray objectAtIndex:1],[beaconValueArray objectAtIndex:2]];
                }
                else {
                    //Text placeholder color
                    cell.serialNumberText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"IMEI" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
                    cell.serialNumberText.text = uniqueTrackGPSValue;
                }
            }
            else if (indexPath.row==5)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton addTarget:self action:@selector(buyItemsAction) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (indexPath.row==6)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton setTitle:@"Change Password" forState:UIControlStateNormal];
                [cell.buyItemsButton addTarget:self action:@selector(changePasswordAction) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (indexPath.row==7)
            {
                cell.buyItemsButton.hidden= NO;
                [cell.buyItemsButton setCornerRadius:5];
                [cell.buyItemsButton setViewBorder:cell.buyItemsButton color:[UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]];
                [cell.buyItemsButton setTitle:@"Delete Account" forState:UIControlStateNormal];
                [cell.buyItemsButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];                
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==3)
    {
        if ([[UserDefaultManager getValue:@"carInfo"] count]<1)
        {
            [UserDefaultManager showAlertMessage:@"Please add a car to change settings."];
            return;
        }
        [self hidePickerWithAnimation];
        [self.view endEditing:YES];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [pickerView reloadAllComponents];
        [pickerView selectRow:selectedIndex inComponent:0 animated:YES];
        [pickerView setNeedsLayout];
        
        pickerView.frame = CGRectMake(pickerView.frame.origin.x, self.view.bounds.size.height-pickerView.frame.size.height , self.view.bounds.size.width, pickerView.frame.size.height);
        pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, pickerView.frame.origin.y-44, self.view.bounds.size.width, 44);
        
        [UIView commitAnimations];
    }
    if (selectedIndex != 0) {
     
        if (indexPath.row == 4) {
            if ([[UserDefaultManager getValue:@"carInfo"] count]<1)
            {
                [UserDefaultManager showAlertMessage:@"Please add a car to change settings."];
                return;
            }
            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GlobalPopupViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalPopupViewController"];
            
            popupView.isAppSetting = true;
            if (selectedIndex == 1)
            {
                popupView.popupTitle = @"Enter Serial Number";
                popupView.trackingMethod = @"Serial Number";
                popupView.reasonPrifillText = uniqueTrackiBeaconValue;
            }
            else
            {
                popupView.popupTitle = @"Enter IMEI";
                popupView.trackingMethod = @"IMEI";
                popupView.reasonPrifillText = uniqueTrackGPSValue;
                popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
                [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                popupView.delegate=self;
                [self presentViewController:popupView animated:YES completion:nil];
            }
        }
    }
}
#pragma mark - end

#pragma mark - TextField delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self hidePickerWithAnimation];
    if ([[UIScreen mainScreen] bounds].size.height < 580) {
            [self.appSettingsTableView setContentOffset:CGPointMake(0, 80) animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        TrackingTableViewCell *cell = (TrackingTableViewCell*)textField.superview.superview.superview;
        NSIndexPath *indexPath = [self.appSettingsTableView indexPathForCell:cell];
        [self.appSettingsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    else if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        TrackingTableViewCell *cell = (TrackingTableViewCell*)textField.superview.superview;
        NSIndexPath *indexPath = [self.appSettingsTableView indexPathForCell:cell];
        [self.appSettingsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - UIView actions
- (void)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteAction {
    
    [self.view endEditing:YES];
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"Confirm" actionBlock:^(void) {
        [myDelegate showIndicator];
        [self performSelector:@selector(deleteAccount) withObject:nil afterDelay:.1];
        
    }];
    [alert showWarning:nil title:@"Alert" subTitle:@"Are you sure you want to delete your account" closeButtonTitle:@"Cancel" duration:0.0f];
}

- (IBAction)changePasswordAction {
    
    [self.view endEditing:YES];
    ChangePasswordViewController *changePassViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    [self.navigationController pushViewController:changePassViewObj animated:YES];
}

- (IBAction)toolbarCancelAction:(id)sender
{
    [self hidePickerWithAnimation];
}

- (IBAction)toolbarDoneAction:(id)sender
{
    [self hidePickerWithAnimation];
    NSInteger index = [pickerView selectedRowInComponent:0];
    
    if (selectedIndex != (int)index) {
        uniqueTrackGPSValue = @"";
        lastSelectedIndex=selectedIndex;
        selectedIndex = (int)index;
        pickerSelelectString = [trackingType objectAtIndex:selectedIndex];
        if (selectedIndex == 0)
        {
            [myDelegate showIndicator];
            [self performSelector:@selector(setAppSettingService:) withObject:@"trackType" afterDelay:.1];
        }
        else if(selectedIndex==1)
        {
//            [appSettingsTableView reloadData];
            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BeaconListViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"BeaconListViewController"];
            popupView.objSettingView = self;
            popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
            [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            [self presentViewController:popupView animated:YES completion:nil];
        }
        else
        {
            if ([[UserDefaultManager getValue:@"isTrackingStart"] isEqualToString:@"true"]) {
                
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert addButton:@"OK" actionBlock:^(void) {
                    [appSettingsTableView reloadData];
                }];
                [alert showWarning:nil title:@"Alert" subTitle:@"Setting mode to GPS will stop your phone location tracking." closeButtonTitle:nil duration:0.0f];
            }
            else {
                [appSettingsTableView reloadData];
            }
        }
    }
}

- (IBAction)buyItemsAction {
    
    RedemptionViewController *redeemViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RedemptionViewController"];
    [self.navigationController pushViewController:redeemViewObj animated:YES];
}

- (IBAction)infoPopUpView:(UIButton *)sender {
    
//    NSLog(@"%ld",(long)sender.tag);
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppSettingPopUpViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"AppSettingPopUpViewController"];
    
    if (sender.tag == 0) {
        popupView.titleString = @"Daily Mileage Report";
        popupView.contentString = [UserDefaultManager getValue:@"dailMilageReportNote"];
    }
    else {
        popupView.titleString = @"Notification";
        popupView.contentString = [UserDefaultManager getValue:@"notificationNote"];
    }
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:popupView animated:YES completion:nil];
}

- (IBAction)switchViewChanged:(MyButton *)switchView
{
    if ([[UserDefaultManager getValue:@"carInfo"] count]<1)
    {
        [UserDefaultManager showAlertMessage:@"Please add a car to change settings."];
        return;
    }
    if (switchView.sectionTag==0) {
        
        if ( switchView.Tag==0) {
//            NSLog(@"Value 0: %i", switchView.on);
            if (switchView.on==1)
            {
                switchView.on=0;
                [switchView setBackgroundImage:[UIImage imageNamed:@"off_btn.png"] forState:UIControlStateNormal];
                switchState0 = @"0";
                if ([self performValidation:@"switch0"]) {
                    [myDelegate showIndicator];
                    [self performSelector:@selector(setAppSettingService:) withObject:@"switch0" afterDelay:.1];
                }
                else {
                    [appSettingsTableView reloadData];
                }
            }
            else
            {
                switchView.on=1;
                [switchView setBackgroundImage:[UIImage imageNamed:@"on_btn.png"] forState:UIControlStateNormal];
                switchState0 = @"1";
                if ([self performValidation:@"switch0"]) {
                    [myDelegate showIndicator];
                    [self performSelector:@selector(setAppSettingService:) withObject:@"switch0" afterDelay:.1];
                }
                else {
                    [appSettingsTableView reloadData];
                }
            }
        }
        else if (switchView.Tag==1)
        {
//            NSLog(@"Value 1: %i", switchView.on);
            if (switchView.on==1)
            {
                switchView.on=0;
                [switchView setBackgroundImage:[UIImage imageNamed:@"off_btn.png"] forState:UIControlStateNormal];
                switchState1 = @"0";
                if ([self performValidation:@"switch1"]) {
                    [myDelegate showIndicator];
                    [self performSelector:@selector(setAppSettingService:) withObject:@"switch1" afterDelay:.1];
                }
                else {
                    [appSettingsTableView reloadData];
                }
            }
            else
            {
                switchView.on=1;
                [switchView setBackgroundImage:[UIImage imageNamed:@"on_btn.png"] forState:UIControlStateNormal];
                switchState1 = @"1";
                if ([self performValidation:@"switch1"]) {
                    [myDelegate showIndicator];
                    [self performSelector:@selector(setAppSettingService:) withObject:@"switch1" afterDelay:.1];
                }
                else {
                    [appSettingsTableView reloadData];
                }
            }
        }
    }
}
#pragma mark - end

#pragma mark - Perform validation
- (BOOL)performValidation:(NSString *)serviceType {
    
    if (([serviceType isEqualToString:@"switch1"] || [serviceType isEqualToString:@"switch0"]) && (selectedIndex == 2)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0]; // Assuming one section
        TrackingTableViewCell *cell = [self.appSettingsTableView cellForRowAtIndexPath:indexPath];
        if ([cell.serialNumberText isEmpty]) {
            [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
            return NO;
        }
        else {
            return YES;
        }

    }
    return YES;
}
#pragma mark - end

#pragma mark - Picker view delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return trackingType.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *pickerStr;
    pickerStr = [trackingType objectAtIndex:row];
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
    pickerStr = [trackingType objectAtIndex:row];
    pickerLabel.text = pickerStr;
    return pickerLabel;
}

- (void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    pickerView.frame = CGRectMake(pickerView.frame.origin.x, 1000, self.view.bounds.size.width, pickerView.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, 1000, self.view.bounds.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - Call webservice
- (void)setAppSettingService:(NSString *)serviceType {

    NSString *uniqueNumber;
    NSString *trackingMethod;
    if (selectedIndex == 0){
       uniqueNumber = @""; 
    }
    else {
        if (selectedIndex == 1) {
            uniqueNumber = uniqueTrackiBeaconValue;
        }
        else {
            uniqueNumber = uniqueTrackGPSValue;
        }
    }
    
    pickerSelelectString = [trackingType objectAtIndex:selectedIndex];
    if ([pickerSelelectString isEqualToString:@"Phone Mileage Track"]) {
        trackingMethod = @"Phone";
        [UserDefaultManager setValue:@"Mobile GPS" key:@"TestingTrackMethod"];
    }
    else if ([pickerSelelectString isEqualToString:@"Auto Mileage Tracker"]) {
        trackingMethod = @"Ibeacon";
        [UserDefaultManager setValue:@"iBeacon" key:@"TestingTrackMethod"];
    }
    else if ([pickerSelelectString isEqualToString:@"Hardware GPS Track"]) {
        trackingMethod = @"Gps";
    }
    
    [[CampaignService sharedManager] setAppSetting:trackingMethod uniqueIdentifier:uniqueNumber daily_milage_report:switchState0 is_notification_on:switchState1 success:^(id responseObject)
     {
         
         [myDelegate stopIndicator];
         if ([serviceType isEqualToString:@"switch1"]) {
             
             bool state = [[UserDefaultManager getValue:@"isNotificationOn"] boolValue];
             if (state) {
                 [UserDefaultManager setValue:@"0" key:@"isNotificationOn"];
             }
             else {
                 [UserDefaultManager setValue:@"1" key:@"isNotificationOn"];
             }
         }
         else if ([serviceType isEqualToString:@"switch0"]) {
             
             bool state = [[UserDefaultManager getValue:@"isDailyMilageReportOn"] boolValue];
             if (state) {
                 [UserDefaultManager setValue:@"0" key:@"isDailyMilageReportOn"];
             }
             else {
                 [UserDefaultManager setValue:@"1" key:@"isDailyMilageReportOn"];
             }
         }
         else if ([serviceType isEqualToString:@"serialNumber"]) {
             
             if (selectedIndex == 1){
                 [UserDefaultManager setValue:uniqueTrackiBeaconValue key:@"iBeaconSerialNumber"];
                 [UserDefaultManager setValue:@"Ibeacon" key:@"trackingMethod"];
             }
             else if (selectedIndex == 2){
                 [UserDefaultManager setValue:uniqueTrackGPSValue key:@"gpsIMEINumber"];
                 [UserDefaultManager setValue:@"Gps" key:@"trackingMethod"];
             }
         }
         else if ([serviceType isEqualToString:@"trackType"]) {
             
             if (selectedIndex == 0) {
                 [UserDefaultManager setValue:@"Phone" key:@"trackingMethod"];
             }
             else if (selectedIndex == 1){
                 [UserDefaultManager setValue:@"Ibeacon" key:@"trackingMethod"];
             }
             else if (selectedIndex == 2){
                 [UserDefaultManager setValue:@"Gps" key:@"trackingMethod"];
             }
         }
         [appSettingsTableView reloadData];
     }
     failure:^(NSError *error)
     {
         if ([serviceType isEqualToString:@"switch1"]) {
             
             if ([switchState1 isEqualToString:@"0"]) {
                 [UserDefaultManager setValue:@"1" key:@"isNotificationOn"];
             }
             else {
                 [UserDefaultManager setValue:@"0" key:@"isNotificationOn"];
             }
         }
         else if ([serviceType isEqualToString:@"switch0"]) {
             
             if ([switchState0 isEqualToString:@"0"]) {
                 [UserDefaultManager setValue:@"1" key:@"isDailyMilageReportOn"];
             }
             else {
                 [UserDefaultManager setValue:@"0" key:@"isDailyMilageReportOn"];
             }
         }
        [appSettingsTableView reloadData];
     }];
}

- (void)getDefaultCarInformation {

    [[CampaignService sharedManager] getDefaultCarSetting:^(id responseObject)
     {
         //If get car information
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"daily_milage_report"] key:@"isDailyMilageReportOn"];
         [UserDefaultManager setValue:[responseObject  objectForKey:@"daily_mileage_note"] key:@"dailMilageReportNote"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"is_notification_on"] key:@"isNotificationOn"];
         [UserDefaultManager setValue:[responseObject  objectForKey:@"notification_note"] key:@"notificationNote"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"tracking_method"] key:@"trackingMethod"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"ibeacon_id"] key:@"iBeaconSerialNumber"];
         [UserDefaultManager setValue:[[responseObject objectForKey:@"defaultcarinfo"] objectForKey:@"gps_device_id"] key:@"gpsIMEINumber"];
         
         notificationNote = [UserDefaultManager getValue:@"notificationNote"];
         dailyMileageNote = [UserDefaultManager getValue:@"dailMilageReportNote"];
         switchState0 = [UserDefaultManager getValue:@"isDailyMilageReportOn"];
         switchState1 = [UserDefaultManager getValue:@"isNotificationOn"];
         
         uniqueTrackGPSValue = @"";
         uniqueTrackiBeaconValue = @"";
         
         trackingType = @[@"Phone Mileage Track", @"Auto Mileage Tracker", @"Hardware GPS Track"];
         if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Phone"]) {
             
             selectedIndex = 0;
         }
         else if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Ibeacon"]) {
             selectedIndex = 1;
             uniqueTrackiBeaconValue = [UserDefaultManager getValue:@"iBeaconSerialNumber"];
         }
         else if ([[UserDefaultManager getValue:@"trackingMethod"] isEqualToString:@"Gps"]) {
             selectedIndex = 2;
             uniqueTrackGPSValue = [UserDefaultManager getValue:@"gpsIMEINumber"];
         }
         pickerSelelectString = [trackingType objectAtIndex:selectedIndex];
         [appSettingsTableView reloadData];
     }
     failure:^(NSError *error)
     {
         
     }];
}

- (void)deleteAccount
{
    [[CampaignService sharedManager] deleteAccount:^(id responseObject)
     {
         [myDelegate showIndicator];
         [self performSelector:@selector(logoutUser) withObject:nil afterDelay:.1];
     }
                                                  failure:^(NSError *error)
     {
         
     }];
}

- (void)logoutUser
{
    [[UserService sharedManager] userLogout:^(id responseObject) {
        
        [UserDefaultManager setValue:nil key:@"userName"];
        [UserDefaultManager setValue:nil key:@"accessToken"];
        [UserDefaultManager setValue:nil key:@"mobileNumber"];
        [UserDefaultManager setValue:nil key:@"profileImageUrl"];
        [UserDefaultManager setValue:nil key:@"userId"];
        [UserDefaultManager setValue:nil key:@"isFacebookConnected"];
        [UserDefaultManager setValue:nil key:@"profileStatus"];
        [UserDefaultManager setValue:@"false" key:@"isCampaignRunning"];
        [UserDefaultManager setValue:@"False" key:@"isNotificationAvailable"];
        myDelegate.notificationDict = [NSMutableDictionary new];
        [myDelegate.notificationDict setObject:@"Other" forKey:@"ScreenType"];
        [myDelegate.notificationDict setObject:@"No" forKey:@"isNotification"];
        myDelegate.facebookCount = 0;
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        myDelegate.isLogout = true;
        [myDelegate unrigisterForNotification];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                                   animated: NO];
//        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        myDelegate.window.rootViewController = myDelegate.navigationController;
//        UIViewController *firstVC=[sb instantiateViewControllerWithIdentifier:@"LoginView"];
//        [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: firstVC]
//                                                   animated: YES];
    } failure:^(NSError *error) {
        
//        NSLog(@"log");
    }];
}
#pragma mark - end

#pragma mark - Delegate method for global popup
- (void)popupViewDelegateMethod:(int)option reasonText:(NSString *)myReasonText {
    
    if (option == 2) {
        uniqueTrackiBeaconValue = myReasonText;
        [appSettingsTableView reloadData];
        
        [myDelegate showIndicator];
        [self performSelector:@selector(setAppSettingService:) withObject:@"serialNumber" afterDelay:.1];
    }
    else if (option == 3){
        uniqueTrackGPSValue = myReasonText;
        [appSettingsTableView reloadData];
        
        [myDelegate showIndicator];
        [self performSelector:@selector(setAppSettingService:) withObject:@"serialNumber" afterDelay:.1];
    }
}

- (void)setBeaconForTracking
{
    [appSettingsTableView reloadData];
    [myDelegate showIndicator];
    [self performSelector:@selector(setAppSettingService:) withObject:@"serialNumber" afterDelay:.1];
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
