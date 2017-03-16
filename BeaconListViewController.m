//
//  BeaconListViewController.m
//  Adogo
//
//  Created by Sumit on 12/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BeaconListViewController.h"
#import "BeaconCell.h"
@interface BeaconListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *beaconTableView;
@property (nonatomic ,retain)NSMutableArray * beaconArray;
@property (nonatomic,retain)NSTimer * beaconTimer;
@property (nonatomic,retain)ABBeacon * selectedBeacon;
@property (strong, nonatomic) IBOutlet UILabel *noiBeaconLabel;
@property (strong, nonatomic) IBOutlet UIView *beaconBackView;
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@end

@implementation BeaconListViewController
@synthesize beaconTableView;
@synthesize beaconArray;
@synthesize beaconTimer;
@synthesize selectedBeacon;
@synthesize objSettingView;
@synthesize noiBeaconLabel;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    noiBeaconLabel.hidden = YES;
    _beaconBackView.layer.cornerRadius = 5;
    _beaconBackView.layer.masksToBounds = YES;
    beaconTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    beaconArray = [[NSMutableArray alloc]init];
    beaconTimer = [NSTimer scheduledTimerWithTimeInterval: 5
                                                  target: self
                                                selector: @selector(refreshBeaconList)
                                                userInfo: nil
                                                 repeats: YES];
    [myDelegate startRangeBeacons];
    [self refreshBeaconList];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [beaconTimer invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshBeaconList
{
//    NSLog(@"beaconArray is %@",myDelegate.beaconArray);
    [beaconArray removeAllObjects];
    beaconArray = myDelegate.beaconArray;
    if (beaconArray.count == 0) {
        noiBeaconLabel.hidden = NO;
    }
    else {
        noiBeaconLabel.hidden = YES;
    }
    [beaconTableView reloadData];
}
#pragma mark - end

#pragma mark - Tableview delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return beaconArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell ;
    NSString *simpleTableIdentifier = @"BeaconCell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[BeaconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.selectBeaconRadioButton.tag = indexPath.row;
    [cell.selectBeaconRadioButton addTarget:self action:@selector(selectBeacon:) forControlEvents:UIControlEventTouchUpInside];
    [cell displayData:[beaconArray objectAtIndex:indexPath.row] selectedId:objSettingView.uniqueTrackiBeaconValue];
    return cell;
}
#pragma meak - end

#pragma mark - UIView actions
- (IBAction)crossButtonAction:(id)sender
{
    objSettingView.isBeaconCancel=YES;
    [objSettingView viewWillAppear:YES];
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonAction:(id)sender
{
    if ([objSettingView.uniqueTrackiBeaconValue isEqualToString:@""])
    {
        [UserDefaultManager showAlertMessage:@"Please select any beacon"];
        return;
    }
    [myDelegate startMonitoringForRegion:selectedBeacon];
    [objSettingView setBeaconForTracking];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectBeacon:(id)sender
{
    ABBeacon * beacon = [beaconArray objectAtIndex:[sender tag]];
    selectedBeacon = beacon;
    objSettingView.uniqueTrackiBeaconValue =[NSString stringWithFormat:@"%@.%@.%@",[beacon.proximityUUID UUIDString],[NSString stringWithFormat:@"%@",beacon.major],[NSString stringWithFormat:@"%@",beacon.minor]];
    [beaconTableView reloadData];
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
