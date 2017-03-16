//
//  CarListiewController.m
//  Adogo
//
//  Created by Sumit on 29/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarListiewController.h"
#import "CarService.h"
#import "CustomButton.h"
#import "AddNewCarViewController.h"
#import "CarDetailViewController.h"
#import "GlobalPopupViewController.h"

@interface CarListiewController ()<PopupViewDelegate>
{
    NSString * carId,*selectedCarId,*newDefaultCarId;
}
@property (weak, nonatomic) IBOutlet UITableView *carListingTableview;
@property(nonatomic,retain)NSMutableArray *carListingArray;
@property (weak, nonatomic) IBOutlet UILabel *noRecordLbl;
@end

@implementation CarListiewController
@synthesize carListingTableview;
@synthesize carListingArray;
@synthesize noRecordLbl;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Car";
    // Do any additional setup after loading the view.
    
    selectedCarId=@"10000";
    newDefaultCarId = @"";
    myDelegate.selScreenState = 2;
    [self addDashboardMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Yes"]) {
        if ([[myDelegate.notificationDict objectForKey:@"toScreen"] isEqualToString:@"CarDetail"]) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CarDetailViewController *carDetail =[storyboard instantiateViewControllerWithIdentifier:@"CarDetailViewController"];
            [self.navigationController pushViewController:carDetail animated:NO];
            return;
        }
        else if ([[myDelegate.notificationDict objectForKey:@"toScreen"] isEqualToString:@"EditCar"]) {
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AddNewCarViewController *carDetailInfo =[storyboard instantiateViewControllerWithIdentifier:@"AddNewCarView"];
            carDetailInfo.isEditCar = YES;
            carDetailInfo.isCarListing = YES;
            [self.navigationController pushViewController:carDetailInfo animated:NO];
            return;
        }
    }
    [myDelegate.notificationDict setObject:@"No" forKey:@"isNotification"];
    carListingArray = [[NSMutableArray alloc]init];
    [self.carListingTableview reloadData];
    [myDelegate showIndicator];
    [self performSelector:@selector(getCarListing) withObject:nil afterDelay:.1];
//    NSLog(@"view will appear called");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Popup delegate
- (void)popupViewDelegateMethod:(int)option reasonText:(NSString *)reasonText
{
    if (option == 1)
    {
        [myDelegate showIndicator];
        [self performSelector:@selector(deleteCar:) withObject:reasonText afterDelay:.1];
    }
}
#pragma mark - end

#pragma mark - Webservices
- (void)deleteCar:(NSString *)reasonTextView
{
    [[CarService sharedManager] deleteCar:selectedCarId deletedReason:reasonTextView newDefaultCarId:newDefaultCarId success:^(id responseObject)
     {
//         NSLog(@"responseObject is %@",responseObject);
         [self getCarListing];
     }
     failure:^(NSError *error) {
                                  }];
}

- (void)getCarListing {
    [[CarService sharedManager] getCarListing :^(id responseObject)
     {
         [myDelegate stopIndicator];
         [carListingArray removeAllObjects];
//         NSLog(@"responseObject is %@",responseObject);
         NSMutableArray *tmpArray = [[responseObject objectForKey:@"carlisting"]mutableCopy];
         carListingArray = [tmpArray mutableCopy];
         if (carListingArray.count<1)
         {
             noRecordLbl.hidden = NO;
         }
         else
         {
             noRecordLbl.hidden = YES;
         }
         NSArray * tempSortedArray = [carListingArray mutableCopy];
         NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"car_id"  ascending:YES];
         tempSortedArray=[tempSortedArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
         carListingArray = [tempSortedArray mutableCopy];
         [carListingTableview reloadData];
     }
       failure:^(NSError *error)
     {
         
     }];
}

- (void)setDefaultCar:(NSString *)carid
{
    carId = carid;
    [[CarService sharedManager] setDefaultCar:carid success: ^(id responseObject)
     {
         //NSLog(@"responseObject is %@",responseObject);
         
         if ([[responseObject objectForKey:@"photos_asked"] intValue]==1) {
             UIViewController * dashboardView = [self.storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
             [self.navigationController setViewControllers: [NSArray arrayWithObject: dashboardView]
                                                  animated: NO];
         }
         else {
             [self updateListArray];
         }
     }
       failure:^(NSError *error)
     {
         
     }];
}

- (void)updateListArray
{
    NSMutableArray *tempCarArray = [carListingArray mutableCopy];
    for (int i=0; i<carListingArray.count; i++)
    {
        NSMutableDictionary *TempDict =[carListingArray objectAtIndex:i];
        if ([[TempDict objectForKey:@"car_id"]isEqualToString:carId])
        {
            [TempDict setObject:@"1" forKey:@"is_default_car"];
            [tempCarArray replaceObjectAtIndex:i withObject:TempDict];
        }
        else
        {
            [TempDict setObject:@"0" forKey:@"is_default_car"];
            [tempCarArray replaceObjectAtIndex:i withObject:TempDict];
        }
    }
    [carListingArray removeAllObjects];
    carListingArray = [tempCarArray mutableCopy];
    [carListingTableview reloadData];
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return carListingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"CarListingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSDictionary * carDataDict = [carListingArray objectAtIndex:indexPath.row];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.contentView.layer.cornerRadius = 3.0;
    
    //setting car image
    UIImageView * carImage = (UIImageView *)[cell.contentView viewWithTag:1];
    carImage.layer.cornerRadius = 3.0;
    __weak UIImageView *weakRef = carImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[carDataDict objectForKey:@"carimage"]]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [carImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.layer.cornerRadius = 3.0;
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    //end
    //setting car model and serial no.
    UILabel *carlabel = (UILabel *)[cell.contentView viewWithTag:2];
    carlabel.text = [NSString stringWithFormat:@"%@ - %@",[carDataDict objectForKey:@"plate_number"],[carDataDict objectForKey:@"brand"]];
    //end
    //default car button
    CustomButton * btn = (CustomButton *)[cell.contentView viewWithTag:3];
    btn.buttonTag = (int)indexPath.row;
    [btn addTarget:self action:@selector(defaultCarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 2.0;
    if ([[carDataDict objectForKey:@"is_default_car"] boolValue])
    {
        [UserDefaultManager setValue:carDataDict key:@"carInfo"];
        [btn setTitle:@"Default Car" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithRed:48.0/255. green:217.0/255.0 blue:196.0/255.0 alpha:1.0];
        btn.alpha = 1.0;
        btn.enabled = NO;
        btn.titleLabel.font = [UIFont railwayBoldWithSize:11.0];
    }
    else
    {
        [btn setTitle:@"Set as Default" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blackColor];
        btn.alpha = 0.8;
        btn.enabled = YES;
        btn.titleLabel.font = [UIFont railwayBoldWithSize:11.0];
    }
    //end
    //round view corner
    UIView *bgView  = (UIView *)[cell.contentView viewWithTag:5];
    bgView.translatesAutoresizingMaskIntoConstraints = YES;
    bgView.frame = CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, self.view.frame.size.width-20, bgView.frame.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:( UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    bgView.layer.mask = maskLayer;
    //end
    //Delete button
    CustomButton * deleteButton = (CustomButton *)[cell.contentView viewWithTag:4];
    deleteButton.buttonTag = (int)indexPath.row;
    [deleteButton addTarget:self action:@selector(deleteCarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //NSLog(@"selectedCarId %@",selectedCarId);
    //Set isApproved image
    UIImageView * approvedImage = (UIImageView *)[cell.contentView viewWithTag:6];
    approvedImage.hidden = YES;
    approvedImage.translatesAutoresizingMaskIntoConstraints = YES;
    carlabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    if ([[carDataDict objectForKey:@"is_approved"] boolValue]) {
        
         approvedImage.hidden = NO;
        float width = [self getDynamicLabelWidth:carlabel.text font:[UIFont railwayRegularWithSize:17] widthValue:self.view.bounds.size.width - 20 - 12 - 8 - 38 - 8 - 30];
        carlabel.frame = CGRectMake(12, 4, width, 30);
        approvedImage.frame = CGRectMake(carlabel.frame.origin.x + carlabel.frame.size.width + 8, (carlabel.frame.origin.y + (carlabel.frame.size.height / 2)) - (25 / 2) , 25, 25);
    }
    else {
        
        approvedImage.hidden = YES;
        carlabel.frame = CGRectMake(12, 4, self.view.bounds.size.width - 20 - 12 - 8 - 38, 30);
    }
    //end
    
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"check");
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CarDetailViewController *carDetail =[storyboard instantiateViewControllerWithIdentifier:@"CarDetailViewController"];
    carDetail.carId = [[carListingArray objectAtIndex:indexPath.row] objectForKey:@"car_id"];
//    carDetail.carModel = [NSString stringWithFormat:@"%@ - %@",[[carListingArray objectAtIndex:indexPath.row] objectForKey:@"plate_number"],[[carListingArray objectAtIndex:indexPath.row] objectForKey:@"model"]];
//    carDetail.isApprovedCarDetail = [[[carListingArray objectAtIndex:indexPath.row] objectForKey:@"is_approved"] boolValue];
    [self.navigationController pushViewController:carDetail animated:YES];
}
#pragma mark - end

#pragma mark - UIView actions
- (void)defaultCarBtnClicked:(CustomButton *)sender
{
    //NSLog(@"sender.buttonTag is %d",sender.buttonTag);
    NSDictionary * carDataDict =[carListingArray objectAtIndex:sender.buttonTag];
    [myDelegate showIndicator];
    [self performSelector:@selector(setDefaultCar:) withObject:[carDataDict objectForKey:@"car_id"] afterDelay:.1];
}

- (void)deleteCarBtnClicked:(CustomButton *)sender
{
    //NSLog(@"sender.buttonTag is %d",sender.buttonTag);
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GlobalPopupViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalPopupViewController"];
    NSDictionary * temp  = [carListingArray lastObject];
    if ([[temp objectForKey:@"is_default_car"] isEqualToString:@"1"] && carListingArray.count>=2)
    {
        temp = [carListingArray objectAtIndex:carListingArray.count-2];
    }
    else
    {
        temp  = [carListingArray lastObject];
    }
    newDefaultCarId = [temp objectForKey:@"car_id"];
    NSDictionary * carDataDict =[carListingArray objectAtIndex:sender.buttonTag];
    popupView.popupTitle = @"Delete Car";
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    selectedCarId=[carDataDict objectForKey:@"car_id"];
    
    popupView.delegate=self;
    [self presentViewController:popupView animated: YES completion:nil];
}

- (IBAction)addNewCar:(UIButton *)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddNewCarViewController *pinView =[storyboard instantiateViewControllerWithIdentifier:@"AddNewCarView"];
    pinView.isEditCar = NO;
    pinView.carId = @"0";
    pinView.carCount = (int)carListingArray.count + 1;
    pinView.isCarListing = YES;
    [self.navigationController pushViewController:pinView animated:YES];
}
#pragma mark - end

#pragma mark - Get gynamic height of label
- (float)getDynamicLabelWidth:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.width;
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
