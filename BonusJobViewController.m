//
//  BonusJobViewController.m
//  Adogo
//
//  Created by Monika on 01/06/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BonusJobViewController.h"
#import "BonusJobTableViewCell.h"
#import "CampaignService.h"
#import "SCLAlertView.h"
@interface BonusJobViewController ()
{
    NSMutableArray *bonusJobArray;
    NSMutableArray *bonusJobInfoArray;
    NSString *status;
    NSString *currentStatus;
    __weak IBOutlet UIButton *acceptButton;
    __weak IBOutlet UIButton *rejectButton;
}
@property (strong, nonatomic) IBOutlet UILabel *infoText;
@property (strong, nonatomic) IBOutlet UIImageView *infoImageView;
@property (strong, nonatomic) IBOutlet UITableView *bonusJobTableView;
@property (strong, nonatomic) IBOutlet UIImageView *mapImageView;

@end
@implementation BonusJobViewController
@synthesize infoText,infoImageView,bonusJobTableView,mapImageView;
@synthesize isNotificationHistory,offerCarId,offerCampaignId;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    bonusJobArray = [NSMutableArray arrayWithObjects:@"Date",@"Time",@"Min.Mileage", nil];
    bonusJobInfoArray = [[NSMutableArray alloc]init];
     self.title=@"Bonus Job";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"BonusJobScreen" object:nil];
    
    [myDelegate showIndicator];
    [self performSelector:@selector(getBonusJob) withObject:nil afterDelay:.1];
}

- (void)refreshView {
    
    [myDelegate showIndicator];
    [self performSelector:@selector(getBonusJob) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
   myDelegate.isValidDate = true;
    myDelegate.currentPresentViewName = @"BonusJob";
    
    if (isNotificationHistory) {
        [self addBackLeftBarButtonWithImage:[UIImage imageNamed:@"back_white.png"]];
    }
}

#pragma mark - Add left bar button
- (void)addBackLeftBarButtonWithImage:(UIImage *)menuImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:framing];
    [backButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    myDelegate.isValidDate = false;
    myDelegate.currentPresentViewName = @"Other";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

- (void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BonusJobTableViewCell *cell;
    NSString *simpleTableIdentifier = @"BonusJobCell";
    cell = [bonusJobTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[BonusJobTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.dateLabel.text = [bonusJobArray objectAtIndex:indexPath.row];
    if (bonusJobInfoArray.count > 0) {
        cell.dateInfoLabel.text = [bonusJobInfoArray objectAtIndex:indexPath.row];
    }
    return cell;
}
#pragma mark - end
- (IBAction)acceptOfferAction:(id)sender {
    
    status = @"Accepted";
    [myDelegate showIndicator];
    [self performSelector:@selector(acceptRejectOffer) withObject:nil afterDelay:.2];
    
}

- (IBAction)rejectOfferAction:(id)sender {
    
    status = @"Rejected";
    [myDelegate showIndicator];
    [self performSelector:@selector(acceptRejectOffer) withObject:nil afterDelay:.2];
}
#pragma mark - Call webservice
- (void)getBonusJob
{
    
    if (!isNotificationHistory) {
        offerCarId=[[[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"extra_params"] objectForKey:@"offer_car_id"];
        offerCampaignId=[[[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"extra_params"] objectForKey:@"campaign_car_id"];
    }
    [[CampaignService sharedManager] getBonusJob:offerCarId campaignCarId:offerCampaignId success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        NSMutableDictionary *data = [responseObject objectForKey:@"data"];
//        NSLog(@"data %@",data);
        currentStatus = [data objectForKey:@"offer_status"];
        [bonusJobInfoArray addObject:[self formateDate:[data objectForKey:@"start_time"]]];
        [bonusJobInfoArray addObject:[NSString stringWithFormat:@"%@ to %@",[self timeFormate:[data objectForKey:@"start_time"]],[self timeFormate:[data objectForKey:@"end_time"]]]];
        [bonusJobInfoArray addObject:[NSString stringWithFormat:@"%@ Km",[data objectForKey:@"minimum_mileage"]]];
        infoText.text = [data objectForKey:@"description"];
        [self downloadImages:[data objectForKey:@"image"] placeholderImage:@"carPlaceholder.png"];
        int campaignStatus = [UserDefaultManager dateComparision:[responseObject objectForKey:@"current_server_time"] endDate:[data objectForKey:@"end_time"] startTime:[data objectForKey:@"start_time"]];
        if ([currentStatus isEqualToString:@"Accepted"]||[currentStatus isEqualToString:@"Rejected"]) {
            
            acceptButton.enabled = NO;
            rejectButton.enabled = NO;

        }else if (campaignStatus!=2){
            acceptButton.enabled = NO;
            rejectButton.enabled = NO;
        }
        
        [bonusJobTableView reloadData];
    }
                                         failure:^(NSError *error) {
                                             
                                         }];
}

- (void)acceptRejectOffer{
    
    [[CampaignService sharedManager] acceptRejectOffer:status offerCarId:offerCarId success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        NSMutableDictionary *data = [responseObject objectForKey:@"data"];
//        NSLog(@"data %@",data);
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
            [self.navigationController pushViewController:dashboard animated:YES];
            
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
        
    }
                                         failure:^(NSError *error) {
                                             
                                         }];
}

- (void)downloadImages:(NSString *)imgUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRefImage = mapImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [mapImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRefImage.contentMode = UIViewContentModeScaleAspectFit;
        weakRefImage.clipsToBounds = YES;
        weakRefImage.image = image;
        weakRefImage.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end

#pragma mark - Time/Date formatting
-(NSString*)timeFormate:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [formatter setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [formatter setDateFormat:@"hh:mm a"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

-(NSString*)formateDate:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [formatter setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [formatter setDateFormat:@"dd MMM, YY"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}
#pragma mark - end
@end
