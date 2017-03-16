//
//  DriverProfileViewController.m
//  Adogo
//
//  Created by Sumit on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "DriverProfileViewController.h"
#import "DriverProfileCell.h"
#import "NRICImageCell.h"
#import "UserService.h"
#import "RegistrationViewControllerStepTwo.h"
#import "ProfileCompletionStatusViewController.h"
@interface DriverProfileViewController ()
{
    NSMutableArray * UserDataArray;
    NSMutableDictionary * responseDict;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DriverProfileViewController
@synthesize tableView;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Profile";
    [myDelegate.notificationDict setObject:@"" forKey:@"isNotification"];
    UserDataArray = [[NSMutableArray alloc]init];
    myDelegate.selScreenState = 1;
    [self addDashboardMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [myDelegate showIndicator];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self performSelector:@selector(getUserData) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -end

#pragma mark - Webservice method
- (void)getUserData
{
    [[UserService sharedManager] getUserProfile:^(id responseObject) {
        responseDict=[responseObject mutableCopy];
        [UserDataArray removeAllObjects];
        [self setProfileDatainArray:responseObject];
    } failure:^(NSError *error) {
        
//        NSLog(@"log");
    }];
}
-(NSString*)formateDate:(NSString *)dateStr
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    
    [formatter setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [formatter setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (void)setProfileDatainArray :(id)response
{
    NSDictionary *userDataDict = [[response objectForKey:@"userdetails"] objectForKey:@"basic"];
    [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"nric"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"nric"], @"NRIC No.", nil]];
    [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"gender"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"gender"], @"Gender", nil]];
    [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"dob"] isEqualToString:@""] ? @"NA" : [self formateDate:[userDataDict objectForKey:@"dob"]], @"Date of Birth", nil]];
    [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"profession"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"profession"], @"Occupation", nil]];
    NSString * addressString;
    if ([[userDataDict objectForKey:@"address_unit"] isEqualToString:@""]) {
        addressString = [NSString stringWithFormat:@"%@, %@\n %@ %@",[userDataDict objectForKey:@"address_block"],[userDataDict objectForKey:@"address_street"],[userDataDict objectForKey:@"country"],[userDataDict objectForKey:@"postal_code"]];
    }
    else
    {
     addressString = [NSString stringWithFormat:@"%@, %@\n %@\n %@ %@",[userDataDict objectForKey:@"address_block"],[userDataDict objectForKey:@"address_street"],[userDataDict objectForKey:@"address_unit"],[userDataDict objectForKey:@"country"],[userDataDict objectForKey:@"postal_code"]];
    }
    [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:addressString.length<=6 ? @"NA" : addressString, @"Address", nil]];
    
    if ([[userDataDict objectForKey:@"preferred_payment"] isEqualToString:@"Cheque"])
    {
        [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"check_payable_name"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"check_payable_name"], @"Payee Name", nil]];
    }
    else
    {
        [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"bank_name"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"bank_name"], @"Bank Name", nil]];
        [UserDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[userDataDict objectForKey:@"bank_account_number"] isEqualToString:@""] ? @"NA" : [userDataDict objectForKey:@"bank_account_number"], @"Account Number", nil]];
    }
    [tableView reloadData];
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return 1;
    }
    else if (section==1)
    {
        return 1;
    }
    else
    {
        return UserDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        DriverProfileCell *profileCell ;
        NSString *simpleTableIdentifier = @"DriverProfileCell";
        profileCell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (profileCell == nil)
        {
            profileCell = [[DriverProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        [tableView1 setSeparatorColor:[UIColor colorWithRed:218.0/255.0 green:219.0/255.0 blue:223.0/255.0 alpha:1.0]];
        [profileCell displayData:[[responseDict objectForKey:@"userdetails"] objectForKey:@"basic"]];
        [profileCell.editProfileButton addTarget:self action:@selector(editDriverProfile) forControlEvents:UIControlEventTouchUpInside];
        return profileCell;
    }
    else if (indexPath.section==1)
    {
        NRICImageCell *nricCell ;
        NSString *simpleTableIdentifier = @"NRICImageCell";
        nricCell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (nricCell == nil)
        {
            nricCell = [[NRICImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        [tableView1 setSeparatorColor:[UIColor colorWithRed:218.0/255.0 green:219.0/255.0 blue:223.0/255.0 alpha:1.0]];
        [nricCell displayData:[[responseDict objectForKey:@"userdetails"] objectForKey:@"basic"]];
        return nricCell;
    }
    else
    {
        UITableViewCell *otherCell ;
        NSString *simpleTableIdentifier = @"ProfileCell";
        otherCell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (otherCell == nil)
        {
            otherCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        [tableView1 setSeparatorColor:[UIColor clearColor]];
        UILabel * cellLbl = (UILabel *)[otherCell.contentView viewWithTag:1];
        NSDictionary *dataDict = [UserDataArray objectAtIndex:indexPath.row];
        cellLbl.text =  [[dataDict allKeys] objectAtIndex:0];
        UILabel * infoLbl = (UILabel *)[otherCell.contentView viewWithTag:2];
        infoLbl.numberOfLines = 4;
        if (indexPath.row==4)
        {
            infoLbl.translatesAutoresizingMaskIntoConstraints = YES;
            cellLbl.translatesAutoresizingMaskIntoConstraints = YES;
            if ([[dataDict objectForKey:[[dataDict allKeys] objectAtIndex:0]] isEqualToString:@"NA"]) {
                cellLbl.frame = CGRectMake(8, (42/2) - 10, 100, 20);
                infoLbl.frame = CGRectMake(self.view.bounds.size.width - 8 - 100 - 40 , (42/2) - 10, self.view.bounds.size.width - 16 - 100 - 40, 20);
            }
            else
            {
                float height = [self getDynamicLabelHeight:[dataDict objectForKey:[[dataDict allKeys] objectAtIndex:0]] font:[UIFont railwayRegularWithSize:14] widthValue:[[UIScreen mainScreen] bounds].size.width - 16 - 70 - 40];
                if (height < 20) {
                    height = 22;
                }
                infoLbl.numberOfLines = 0;
                infoLbl.frame = CGRectMake(8 + 70 + 40 , ((height + 20) / 2) - (height / 2) , [[UIScreen mainScreen] bounds].size.width - 16 - 70 - 40, height+1);
                cellLbl.frame = CGRectMake(8, infoLbl.frame.origin.y + (infoLbl.frame.size.height/2) - 10, 70, 20);
            }
        }
        else
        {
            infoLbl.translatesAutoresizingMaskIntoConstraints = NO;
            infoLbl.frame = CGRectMake(infoLbl.frame.origin.x, infoLbl.frame.origin.y, infoLbl.frame.size.width, 40);
        }
            infoLbl.text =[dataDict objectForKey:[[dataDict allKeys] objectAtIndex:0]];
        return otherCell;
    }
}

- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,1000);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView1 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataDict;
    if (UserDataArray.count>0)
    {
        dataDict = [UserDataArray objectAtIndex:indexPath.row];
    }
    
    if (indexPath.section==0)
    {
        return 110.0;
    }
    else if (indexPath.section==1)
    {
        return 122.0;
    }
    else
    {
        if (indexPath.row==4)
        {
            if (![[dataDict objectForKey:[[dataDict allKeys] objectAtIndex:0]] isEqualToString:@"NA"])
            {
//                return 90.0;
                float height = [self getDynamicLabelHeight:[dataDict objectForKey:[[dataDict allKeys] objectAtIndex:0]] font:[UIFont railwayRegularWithSize:14] widthValue:[[UIScreen mainScreen] bounds].size.width - 16 - 70 - 40];
                
                if (height < 20) {
                    height = 22;
                }
                return height + 20+1;
            }
            else
            {
                return 42.0;
            }
        }
        else
        {
            return 42.0;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (void)editDriverProfile {
    
    if (responseDict.count > 0) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RegistrationViewControllerStepTwo *driverProfileObj =[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewStepTwo"];
        driverProfileObj.isEditProfile = YES;
        NSMutableDictionary *tempDriverProfileDetail = [NSMutableDictionary new];
        [tempDriverProfileDetail setObject:[[[responseDict objectForKey:@"userdetails"] objectForKey:@"basic"] objectForKey:@"profession"] forKey:@"profession"];
        [tempDriverProfileDetail setObject:([[[[responseDict objectForKey:@"userdetails"] objectForKey:@"basic"] objectForKey:@"preferred_payment"] isEqualToString:@"Bank Transfer"] ? @"true":@"false") forKey:@"isBankTransfer"];
        [tempDriverProfileDetail setObject:[[responseDict objectForKey:@"userdetails"] objectForKey:@"basic"] forKey:@"profileDetail"];
        driverProfileObj.profileData = [tempDriverProfileDetail mutableCopy];
        [self.navigationController pushViewController:driverProfileObj animated:YES];
    }
}


- (IBAction)viewProfileButtonAction:(id)sender {
    
    ProfileCompletionStatusViewController * profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileCompletionStatusViewController"];
    profileView.shouldShowBackButton = YES;
    [self.navigationController pushViewController:profileView animated:YES];
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
