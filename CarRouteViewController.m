//
//  CarRouteViewController.m
//  Adogo
//
//  Created by Monika on 03/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarRouteViewController.h"
#import "CarRouteTableViewCell.h"
#import "CarService.h"
#import "EditCarRouteViewController.h"
@interface CarRouteViewController ()
{
    NSMutableArray *carRouteArray;
    NSString *newDayStr;
    __weak IBOutlet UILabel *noRecordLabel;
}
@property (weak, nonatomic) IBOutlet UITableView *carRouteTableView;
@property (strong, nonatomic) IBOutlet UIButton *addCarRouteButton;
@property (strong, nonatomic) IBOutlet UILabel *noRecordTopText;
@end

@implementation CarRouteViewController
@synthesize carId;
@synthesize addCarRouteButton;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title = @"Car Routes Listing";
    newDayStr = @"";
    
    self.noRecordTopText.hidden=YES;
    addCarRouteButton.layer.cornerRadius = 3.0f;
    addCarRouteButton.layer.masksToBounds = YES;
    addCarRouteButton.layer.borderColor = [UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f].CGColor;
    addCarRouteButton.layer.borderWidth = 1.0f;
    [myDelegate showIndicator];
    [self performSelector:@selector(carRouteList) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return carRouteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CarRouteCell";
    CarRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[CarRouteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.locationFromLabel.text =  [[[carRouteArray objectAtIndex:indexPath.row] objectForKey:@"from_address"] objectForKey:@"postal_code"];
    cell.locationToLabel.text =  [[[carRouteArray objectAtIndex:indexPath.row] objectForKey:@"to_address"] objectForKey:@"postal_code"];
    cell.timeFromLabel.text =  [self convertTimeFormat:[[carRouteArray objectAtIndex:indexPath.row] objectForKey:@"from_time"]];
    cell.timeToLabel.text =  [self convertTimeFormat:[[carRouteArray objectAtIndex:indexPath.row] objectForKey:@"to_time"]];
    
    NSMutableArray * daysArray =[[carRouteArray objectAtIndex:indexPath.row] objectForKey:@"day"];
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [daysArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSString *dayStr =@"";
    for (int i=0; i<daysArray.count; i++)
    {
        if ([[daysArray objectAtIndex:i] isEqualToString:@"1"])
        {
            dayStr = [NSString stringWithFormat:@"%@ Mon",dayStr];
        }
        else if ([[daysArray objectAtIndex:i] isEqualToString:@"2"])
        {
            dayStr = [NSString stringWithFormat:@"%@, Tue",dayStr];
        }
        else if ([[daysArray objectAtIndex:i] isEqualToString:@"3"])
        {
            dayStr = [NSString stringWithFormat:@"%@, Wed",dayStr];
        }
        else if ([[daysArray objectAtIndex:i] isEqualToString:@"4"])
        {
            dayStr = [NSString stringWithFormat:@"%@, Thu",dayStr];
        }
        else if ([[daysArray objectAtIndex:i] isEqualToString:@"5"])
        {
            dayStr = [NSString stringWithFormat:@"%@, Fri",dayStr];
        }
        else if ([[daysArray objectAtIndex:i] isEqualToString:@"6"])
        {
            dayStr = [NSString stringWithFormat:@"%@, Sat",dayStr];
        }
        else
        {
            dayStr = [NSString stringWithFormat:@"%@, Sun",dayStr];
        }
    }
    if ([dayStr hasPrefix:@","] && [dayStr length] > 1) {
        dayStr = [dayStr substringFromIndex:1];
    }
    cell.daysLabel.text=dayStr;
    //Corner radius
    cell.cellContainerView.layer.cornerRadius = 5.0;
    cell.cellContainerView.layer.masksToBounds = YES;
    cell.editDetailsButton.tag = indexPath.row;
    [cell.editDetailsButton addTarget:self action:@selector(editDetailsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(NSString *)convertTimeFormat : (NSString *)timeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *pmamDateString = [dateFormatter stringFromDate:date];
    return pmamDateString;
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)editDetailsButtonClick:(id)sender
{
    CLLocationCoordinate2D fromCordinates;
    CLLocationCoordinate2D toCordinates;
    EditCarRouteViewController * objEditView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditCarRouteViewController"];
    objEditView.fromAddress =  [[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"from_address"] objectForKey:@"postal_code"];
    objEditView.toAddress =  [[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"to_address"]objectForKey:@"postal_code"];
    objEditView.startTime =  [[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"from_time"];
    objEditView.endTime =  [[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"to_time"];
    objEditView.routeId = [[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"id"];
    objEditView.carId = [[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"car_id"];
    fromCordinates.latitude = [[[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"from_address"]objectForKey:@"lat"] doubleValue];
    fromCordinates.longitude = [[[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"from_address"]objectForKey:@"lng"] doubleValue];
    objEditView.fromCordinates = fromCordinates;
    toCordinates.latitude = [[[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"to_address"]objectForKey:@"lat"] doubleValue];
    toCordinates.longitude = [[[[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"to_address"]objectForKey:@"lng"] doubleValue];
    objEditView.toCordinates = toCordinates;
    NSMutableArray * tmpArray = [[carRouteArray objectAtIndex:[sender tag]] objectForKey:@"day"];
    objEditView.selectedDays = [tmpArray mutableCopy];
    [self.navigationController pushViewController:objEditView animated:YES];
}

- (IBAction)addNewRoute:(id)sender
{
    EditCarRouteViewController * objEditView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditCarRouteViewController"];
    objEditView.routeId = @"0";
    objEditView.carId = carId;
    [self.navigationController pushViewController:objEditView animated:YES];
}
#pragma mark - end

#pragma mark - Call webservices
- (void)carRouteList
{
    [[CarService sharedManager] carRouteService:carId success:^(id responseObject)
     {
//         NSLog(@"responseObject is %@",responseObject);
         NSMutableArray *tmpArray = [[responseObject objectForKey:@"carroutes"]mutableCopy];
         carRouteArray = [tmpArray mutableCopy];
         if(carRouteArray.count<1)
         {
             noRecordLabel.hidden = NO;
             self.noRecordTopText.hidden=NO;
         }
         else
         {
             noRecordLabel.hidden = YES;
             self.noRecordTopText.hidden=YES;
         }
         [_carRouteTableView reloadData];
     }
                                        failure:^(NSError *error) {
                                        }];
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
