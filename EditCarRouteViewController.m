//
//  EditCarRouteViewController.m
//  Adogo
//
//  Created by Monika on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "EditCarRouteViewController.h"
#import "LocationViewController.h"
#import "CarService.h"
#import "SCLAlertView.h"
#define kCellPerRow 3

@interface EditCarRouteViewController ()
{
    NSMutableArray *weekdaysArray;
    NSMutableArray * selDaysArray;
    int isTimeFromBtn;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *daysCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *locationFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationToLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@end

@implementation EditCarRouteViewController
@synthesize fromAddress;
@synthesize toAddress;
@synthesize scrollView,daysCollectionView,locationFromLabel,locationToLabel,timeFromLabel,containerView,datePicker,pickerToolbar,timeToLabel,carId,routeId;
@synthesize startTime;
@synthesize endTime;
@synthesize selectedDays;
@synthesize fromCordinates;
@synthesize toCordinates;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selDaysArray = [NSMutableArray new];
    isTimeFromBtn=0;
    weekdaysArray=[NSMutableArray arrayWithObjects:@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat",nil];
    if ([routeId intValue]==0)
    {
        self.title = @"Add Car Route";
        fromAddress = @"";
        toAddress = @"";
        selectedDays = [NSMutableArray new];
    }
    else
    {
        self.title = @"Edit Car Route";
        timeFromLabel.text = startTime;
        timeToLabel.text = endTime;
    }
    [containerView setViewBorder:containerView color:[UIColor whiteColor]];
    [containerView setCornerRadius:5];
    pickerToolbar.translatesAutoresizingMaskIntoConstraints=YES;
    datePicker.translatesAutoresizingMaskIntoConstraints=YES;
    datePicker.backgroundColor=[UIColor whiteColor];
    [self setAllElementofArrayToOne];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAllElementofArrayToOne
{
    for(int i = 0;i < 7 ;i++)
    {
        [selDaysArray addObject:[NSNumber numberWithInteger:0]];
    }
    if (selectedDays.count>0)
    {
        for (int i=0; i<selectedDays.count; i++)
        {
            switch ([[selectedDays objectAtIndex:i] intValue])
            {
                case 1:
                    [selDaysArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 2:
                    [selDaysArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 3:
                    [selDaysArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 4:
                    [selDaysArray replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 5:
                    [selDaysArray replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 6:
                    [selDaysArray replaceObjectAtIndex:6 withObject:[NSNumber numberWithInteger:1]];
                    break;
                case 7:
                    [selDaysArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:1]];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![fromAddress isEqualToString:@""])
    {
        locationFromLabel.text = fromAddress;
    }
    if (![toAddress isEqualToString:@""])
    {
        locationToLabel.text = toAddress;
    }
}
#pragma mark - end

#pragma mark - UIView actions
-(BOOL)validationForRoute
{
    bool isDaySelected = false;
    for (int i=0; i<selDaysArray.count; i++)
    {
        if ([[selDaysArray objectAtIndex:i]intValue]==1)
        {
            isDaySelected = true;
        }
    }
    if (!isDaySelected)
    {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return false;
    }
    else if ([fromAddress isEqualToString:@""]||[toAddress isEqualToString:@""]|| [startTime isEqualToString:@""]||[endTime isEqualToString:@""]||startTime==nil||endTime==nil)
    {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return false;
    }
    else if (![self getTimeDifference:timeFromLabel.text endTime:timeToLabel.text])
    {
        [UserDefaultManager showAlertMessage:@"Start time should be less than end time."];
        return false;
    }
    else if ([fromAddress isEqualToString:toAddress])
    {
        [UserDefaultManager showAlertMessage:@"Source and destination cannot be same."];
        return false;
    }
    else
    {
        return true;
    }
}

-(bool)getTimeDifference :(NSString *)startingTime endTime:(NSString *)endingTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *date1= [formatter dateFromString:startingTime];
    NSDate *date2 = [formatter dateFromString:endingTime];
    NSComparisonResult result = [date1 compare:date2];
    if(result == NSOrderedDescending)
    {
        //NSLog(@"date1 is later than date2");
        return false;
    }
    else if(result == NSOrderedAscending)
    {
        return true;
    }
    else
    {
        return false;
    }
}

- (IBAction)done:(id)sender
{
    if ([self validationForRoute])
    {
        [myDelegate showIndicator];
        [self performSelector:@selector(setRouteForCar) withObject:nil afterDelay:.1];
    }
}

- (IBAction)selectFromLocationButtonClick:(id)sender
{
    LocationViewController * objLocationView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LocationViewController"];
    objLocationView.objEditCarRoute = self;
    objLocationView.isfrom = true;
    [self.navigationController pushViewController:objLocationView animated:YES];
}

- (IBAction)selectToLocationButtonClick:(id)sender
{
    LocationViewController * objLocationView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LocationViewController"];
    objLocationView.objEditCarRoute = self;
    objLocationView.isfrom = false;
    [self.navigationController pushViewController:objLocationView animated:YES];
}

- (IBAction)selectFromTimeButtonClick:(id)sender
{
    isTimeFromBtn=1;
    [self hidePickerWithAnimation];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    scrollView.scrollEnabled = NO;
    
    NSString *dateStr = timeFromLabel.text;
    if ([dateStr isEqualToString:@"Time From"]) {
        [datePicker setDate:[NSDate date]];
    }
    else {
     // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        [datePicker setDate:date];
    }
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, self.view.frame.size.height -  datePicker.frame.size.height, self.view.bounds.size.width, datePicker.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, datePicker.frame.origin.y-44, self.view.bounds.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
    [datePicker setNeedsLayout];
    
    if([[UIScreen mainScreen] bounds].size.height<568)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.frame.origin.y + 190) animated:YES];
    }
    else if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.frame.origin.y + 100) animated:YES];
    }
}

- (IBAction)selectToTimeButtonClick:(id)sender
{
    isTimeFromBtn=0;
    [self hidePickerWithAnimation];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    scrollView.scrollEnabled = NO;
    
    NSString *dateStr = timeToLabel.text;
    if ([dateStr isEqualToString:@"Time To"]) {
        [datePicker setDate:[NSDate date]];
    }
    else {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        [datePicker setDate:date];
    }
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, self.view.frame.size.height -  datePicker.frame.size.height, self.view.bounds.size.width, datePicker.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, datePicker.frame.origin.y-44, self.view.bounds.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
    [datePicker setNeedsLayout];
    if([[UIScreen mainScreen] bounds].size.height<568)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.frame.origin.y + 240) animated:YES];
    }
    else if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.frame.origin.y + 160) animated:YES];
    }
    else if([[UIScreen mainScreen] bounds].size.height < 1136)
    {
        [scrollView setContentOffset:CGPointMake(0, scrollView.frame.origin.y + 60) animated:YES];
    }
}
#pragma mark - end

#pragma mark - Date picker methods
- (void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    scrollView.scrollEnabled = YES;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, 1000, self.view.frame.size.width, 44);
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, 1000, self.view.frame.size.width, datePicker.frame.size.height);
    [UIView commitAnimations];
}
- (IBAction)toolbarCancelAction:(id)sender
{
    [self hidePickerWithAnimation];
}
- (IBAction)toolbarDoneAction:(id)sender
{
    [self hidePickerWithAnimation];
    
    if (isTimeFromBtn)
    {
        NSDateFormatter * tf = [[NSDateFormatter alloc] init];
        [tf setDateFormat:@"hh:mm a"]; // from here u can change format..
        NSString *timeStr = [tf stringFromDate:datePicker.date];
        timeFromLabel.text=[self changeTimeFormate:timeStr];
        startTime = timeFromLabel.text;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [UIView commitAnimations];
    }
    else
    {
        NSDateFormatter * tf = [[NSDateFormatter alloc] init];
        [tf setDateFormat:@"hh:mm a"]; // from here u can change format..
        NSString *timeStr = [tf stringFromDate:datePicker.date];
        timeToLabel.text=[self changeTimeFormate:timeStr];
        endTime = timeToLabel.text;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [UIView commitAnimations];
    }
}
#pragma mark - end
#pragma mark - Collectionview methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(daysCollectionView.frame.size.width/3.1 , daysCollectionView.frame.size.height/3.1);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [daysCollectionView
                                    dequeueReusableCellWithReuseIdentifier:@"EditCarRoute"
                                    forIndexPath:indexPath];
    UIImageView * weekDaysIcon = (UIImageView *)[myCell.contentView viewWithTag:1];
    UILabel * weekDaysLabel = (UILabel *)[myCell.contentView viewWithTag:2];
    weekDaysLabel.text=[weekdaysArray objectAtIndex:indexPath.row];
    //NSLog(@"daysArr **** %@",selDaysArray);
    if ([selDaysArray objectAtIndex:indexPath.row] == [NSNumber numberWithInteger:0])
    {
        [weekDaysIcon setImage:[UIImage imageNamed:@"check_white"]];
    }
    else
    {
        [weekDaysIcon setImage:[UIImage imageNamed:@"check"]];
    }
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([selDaysArray objectAtIndex:indexPath.row] == [NSNumber numberWithInteger:0])
    {
        [selDaysArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:1]];
        if (indexPath.row==0)
        {
            [selectedDays addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:7]]];
        }
        else
        {
        [selectedDays addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
        }
    }
    else
    {
        if (indexPath.row==0)
        {
            [selectedDays removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:7]]];
        }
        else
        {
            [selectedDays removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
        }
        [selDaysArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:0]];
    }
    [daysCollectionView reloadData];
}
#pragma mark - end

#pragma mark - Call webservices
-(NSString *)changeTimeFormate :(NSString *)convertTime
{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm a";
        NSDate *date = [dateFormatter dateFromString:convertTime];
        dateFormatter.dateFormat = @"HH:mm";
        NSString *time24 = [dateFormatter stringFromDate:date];
        return time24;
}

- (void)setRouteForCar
{
    NSString * result = [selectedDays componentsJoinedByString:@","];
    NSDictionary * fromDict = @{@"postal_code":fromAddress,@"lat":[NSNumber numberWithDouble:fromCordinates.latitude],@"lng":[NSNumber numberWithDouble:fromCordinates.longitude]};
    NSDictionary * toDict = @{@"postal_code":toAddress,@"lat":[NSNumber numberWithDouble:toCordinates.latitude],@"lng":[NSNumber numberWithDouble:toCordinates.longitude]};
    NSMutableArray *routeData = [NSMutableArray arrayWithObjects:@{@"days":result,@"to_time":timeToLabel.text,@"from_time":timeFromLabel.text,@"from_address":fromDict,@"to_address":toDict}, nil];
    [[CarService sharedManager] addEditCarRouteService:carId routeId:routeId routeData:routeData success:^(id responseObject)
     {
         //NSLog(@"responseObject is %@",responseObject);
         if ([[responseObject objectForKey:@"status"]intValue]==200) {
             
             SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
             [alert addButton:@"OK" actionBlock:^(void) {
                 [self goBack];
                 
             }];
             [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
         }
     }
      failure:^(NSError *error) {
    }];
}

- (void)goBack
{
   [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - endð
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
