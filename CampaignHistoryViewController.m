//
//  CarHistoryViewController.m
//  Adogo
//
//  Created by Hema on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CampaignHistoryViewController.h"
#import "CamapaignHistoryTableViewCell.h"
#import "CampaignService.h"

@interface CampaignHistoryViewController ()
{
    NSMutableArray *campaignHistoryArray;
}
@property (weak, nonatomic) IBOutlet UITableView *campaignHistoryTableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultFound;
@end

@implementation CampaignHistoryViewController
@synthesize campaignHistoryTableView,noResultFound;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title=@"Campaign History";
    campaignHistoryArray=[[NSMutableArray alloc]init];
    noResultFound.hidden=YES;
    [myDelegate showIndicator];
    [self performSelector:@selector(getCampaignHistory) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - tableview methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return campaignHistoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"carHistoryCell";
    CamapaignHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[CamapaignHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    [cell.mainContainerView setCornerRadius:5.0f];
    [self downloadImages:cell imageUrl:[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"campaign_image"] placeholderImage:@"campaignLogoPlaceholder"];
    cell.campaignIdLabel.text=[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"campaign_id"];
    cell.companyNameLabel.text=[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    if ([[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"distance_coverd"] isEqualToString:@""]) {
        cell.distanceLabel.text = @"- -";
    }
    else
    {
        cell.distanceLabel.text=[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"distance_coverd"];
    }
    if ([[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"total_earning"] isEqualToString:@""]) {
        cell.earningLabel.text =@"- -";
    }
    else
    {
        cell.earningLabel.text=[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"total_earning"];
    }
    cell.durationLabel.text=[NSString stringWithFormat:@"%d Days [%@ to %@]",[self getDurationInDays:[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"start_date"] end:[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"end_date"]],[self formateDate:[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"start_date"]],[self formateDate:[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"end_date"]]];
    cell.carPlateNoLabel.text=[[campaignHistoryArray objectAtIndex:indexPath.row] objectForKey:@"plate_number"];
    return cell;
}
#pragma mark - end

#pragma mark - Webservice method
- (void)getCampaignHistory
{
    [[CampaignService sharedManager] getCampaignHistory:^(id responseObject)
     {
         campaignHistoryArray = [[responseObject objectForKey:@"history"]mutableCopy];
         if (campaignHistoryArray.count==0) {
             noResultFound.hidden=NO;
             campaignHistoryTableView.hidden=YES;
         }
         else{
             noResultFound.hidden=YES;
             campaignHistoryTableView.hidden=NO;
         }
         [campaignHistoryTableView reloadData];
     }
                                                failure:^(NSError *error)
     {
         
     }];
}

- (void)downloadImages:(CamapaignHistoryTableViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = cell.comapnyImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.comapnyImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

#pragma mark - Date formatting
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
#pragma mark - end

#pragma mark - Get day duration b/w start and end date/time
-(int)getDurationInDays:(NSString *)start end :(NSString *)end
{
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy/MM/dd"];
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:NSCalendarWrapComponents];
//    NSLog(@"%ld",(long)components.day);
    return (int)components.day;
}
#pragma mark - end
@end
