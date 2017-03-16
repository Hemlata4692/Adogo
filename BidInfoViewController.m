//
//  BidInfoViewController.m
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BidInfoViewController.h"
#import "CampaignService.h"
#import "BidInfoTableViewCell.h"
#import "BidInfoCollectionViewCell.h"
#import "CmsContentViewController.h"
#import "GlobalPopupViewController.h"
#import "GlobalPopUpImageViewController.h"
#import "FacebookConenctPopViewController.h"
#import "SignatureViewController.h"
#import "ChatHistoryViewController.h"
#import "SCLAlertView.h"
#import "NotificationHistoryViewController.h"
#import "BidPreviewViewController.h"
#import "BidInfoModel.h"
#import "Internet.h"

@interface BidInfoViewController ()<BSKeyboardControlsDelegate,PopupViewDelegate, FacebookConenctPopupViewDelegate> {
    
    NSMutableDictionary *biddingDetail;
    NSMutableArray *biddingImages;
    NSString *bidAmountText, *reasonText;
    BOOL isSetTime;
    NSTimer *bidTimer;
    float maxBidValue;
}

@property (strong, nonatomic) IBOutlet UITableView *bidInfoTableView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation BidInfoViewController
@synthesize bidId, signatureImageName, hours, minutes, seconds ,bidTimer, isTimeEnd;
@synthesize isBidExist,carId,signatureImage;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    bidAmountText = @"";
    signatureImageName = @"";
    reasonText = @"";
    maxBidValue = 0.0;
    biddingDetail = [NSMutableDictionary new];
    biddingImages = [NSMutableArray new];
    isSetTime = NO;
    
    if (isBidExist) {
        _bidInfoTableView.backgroundColor = [UIColor colorWithRed:(77.0/255.0) green:(81.0/255.0) blue:(97.0/255.0) alpha:1.0f];
    }
    [myDelegate showIndicator];
    [self performSelector:@selector(getBidInformation) withObject:nil afterDelay:.1];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_bidInfoTableView reloadData];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.title = @"Bid Info";
//    NSLog(@"%@", signatureImageName);
    [[self navigationController] setNavigationBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAlertIndication) name:@"NotificationAlert" object:nil];
    [self addRightBarButtonWithImage:[UIImage imageNamed:@"chat"] secondImage:[UIImage imageNamed:@"notification"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [bidTimer invalidate];
}

- (void)addRightBarButtonWithImage:(UIImage *)chatImage secondImage:(UIImage *)notificationImage {
    
    UIBarButtonItem *chatButton, *notificationButton;
    CGRect framing = CGRectMake(0, 0, chatImage.size.width+10, chatImage.size.height+10);
    UIButton *chat = [[UIButton alloc] initWithFrame:framing];
    [chat setBackgroundImage:chatImage forState:UIControlStateNormal];
    chatButton =[[UIBarButtonItem alloc] initWithCustomView:chat];
    if([[UserDefaultManager getValue:@"isNotificationAvailable"] isEqualToString:@"False"])
    {
        notificationImage = [UIImage imageNamed:@"notification"];
    }
    else {
        
        notificationImage = [UIImage imageNamed:@"notificationAlert"];
    }
    framing = CGRectMake(0, 0, notificationImage.size.width+10, notificationImage.size.height+10);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:notificationImage forState:UIControlStateNormal];
    notificationButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [chat addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(notificationAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:notificationButton,chatButton, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidLayoutSubviews {
//    [self.yourTextView setContentOffset:CGPointZero animated:NO];
//}
#pragma mark - end

#pragma mark - Notification handling
- (void)notificationAlertIndication {
    
    [self addRightBarButtonWithImage:[UIImage imageNamed:@"chat"] secondImage:[UIImage imageNamed:@"notification"]];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
    [self.bidInfoTableView setContentOffset:CGPointMake(0, 365) animated:YES];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    bidAmountText = textField.text;
    NSIndexPath *index=[NSIndexPath indexPathForRow:4 inSection:0];
    
    [self.bidInfoTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:TRUE];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}
#pragma mark - end

#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls {
    
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (biddingDetail.count > 0) {
        if (isBidExist || (hours==0&&minutes==0)) {
            return 4;
        }
        else {
            return 5;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
//        if ([biddingDetail objectForKey:@"companyName"] == nil || [[biddingDetail objectForKey:@"companyName"] isEqualToString:@""]) {
            return 192.0f;
//        }
//        else{
//            float height = [self getDynamicLabelHeight:[biddingDetail objectForKey:@"companyName"] font:[UIFont railwayBoldWithSize:13] widthValue:[[UIScreen mainScreen] bounds].size.width - 101 - 8];
//            return 117.0f - 21.0f + height;
//        }
    }
    else if (indexPath.row == 1) {
        if (biddingImages.count==0) {
            return 0.0f;
        }
        else {
        return 115.0f;
        }
    }
    else if (indexPath.row == 2) {
        if (isBidExist) {
            if ([biddingDetail objectForKey:@"location"] == nil || [[biddingDetail objectForKey:@"location"] isEqualToString:@""]) {
                return  160.0f - 35.0f + 21.0f;
            }
            else {
                float height = [self getDynamicLabelHeight:[biddingDetail objectForKey:@"location"] font:[UIFont railwayBoldWithSize:13] widthValue:[[UIScreen mainScreen] bounds].size.width - 134 - 8];
                return  160.0f - 21.0f + height - 35.0f + 21.0f;
            }
        }
        else {
            if ([biddingDetail objectForKey:@"location"] == nil || [[biddingDetail objectForKey:@"location"] isEqualToString:@""]) {
                return  160.0f;
            }
            else {
                float height = [self getDynamicLabelHeight:[biddingDetail objectForKey:@"location"] font:[UIFont railwayBoldWithSize:13] widthValue:[[UIScreen mainScreen] bounds].size.width - 134 - 8];
                return  160.0f - 21.0f + height;
            }
        }
    }
    else if (indexPath.row == 3)
    {
        if ([[biddingDetail objectForKey:@"note_for_car_owners"] isEqualToString:@""]) {
            
            return 0.0;
        }
        else{
            return 120.0;
        }
        
    }
    else if (indexPath.row == 4) {
        
        if ([signatureImageName isEqualToString:@""]) {
            
            return  401.0f;
            
        }else{
            
            return  490.0f;
        }
    }
    return  0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier;
    BidInfoTableViewCell *cell;
    
    if (indexPath.row == 0) {
        
        simpleTableIdentifier = @"campaignCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell setLayoutCampaign:biddingDetail];
        [cell displayCampaignData:biddingDetail];
        
        if (!isBidExist) {
            cell.bidTimeLeftBtn.hidden = NO;
            cell.timeLeftLabel.hidden = NO;
            
            if (![bidTimer isValid] && !isTimeEnd) {
                
                if (seconds>0) {
                    [cell.bidTimeLeftBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
                    bidTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                target:self
                                                              selector:@selector(startBidTimer)
                                                              userInfo:nil
                                                               repeats:YES];
                }
                else{
                    [cell.bidTimeLeftBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%2@:%2@", @"00", @"00"] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
                    cell.bidTimeLeftBtn.alpha = .5;
                }
                
            }
//            else{
//                [cell.bidTimeLeftBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%2@:%2@", @"00", @"00"] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
//                cell.bidTimeLeftBtn.alpha = .5;
//            }
            //
        }
        else {
            cell.bidTimeLeftBtn.hidden = YES;
            cell.timeLeftLabel.hidden = YES;
        }
    }
    else if (indexPath.row == 1) {
        
        simpleTableIdentifier = @"imageCell";
        if (biddingImages.count!=0) {
            [cell.imageCollectionView reloadData];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    else if (indexPath.row == 2) {
        
        simpleTableIdentifier = @"campaignInfoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell setLayoutCampaignInfo:biddingDetail isBidExist:isBidExist];
        [cell displayCampaignInfoData:biddingDetail isBidExist:isBidExist];
    }
    else if (indexPath.row == 3)
    {
        simpleTableIdentifier = @"NoteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        UITextView *noteView = (UITextView *)[cell.contentView viewWithTag:1];
        noteView.translatesAutoresizingMaskIntoConstraints=YES;
        noteView.frame=CGRectMake(noteView.frame.origin.x, noteView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width-31 , noteView.frame.size.height);
        noteView.text = [biddingDetail objectForKey:@"note_for_car_owners"];
        UIColor *borderColor = [UIColor colorWithRed:34.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        noteView.layer.borderColor = borderColor.CGColor;
        noteView.layer.borderWidth = 1.0;
        noteView.layer.cornerRadius = 3.0;
    
    }
    else if (indexPath.row == 4) {
        
        simpleTableIdentifier = @"buttonCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell setLayoutCampaignButton];
        [cell displayCampaignButtonData:biddingDetail];
        
        if (![bidAmountText isEqualToString:@""]) {
            cell.myBidField.text=bidAmountText;
        }
        else if ([biddingDetail objectForKey:@"my_bid"] != nil && ![[biddingDetail objectForKey:@"my_bid"] isEqualToString:@""]) {
            cell.myBidField.text=[biddingDetail objectForKey:@"my_bid"];
        }
        
        NSArray *textFieldArray = @[cell.myBidField];
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
        [self.keyboardControls setDelegate:self];
        cell.signatureImage.translatesAutoresizingMaskIntoConstraints = YES;
        if ([signatureImageName isEqualToString:@""]) {
            
            cell.signatureImage.frame = CGRectMake(cell.signatureImage.frame.origin.x, cell.signatureImage.frame.origin.y, cell.signatureBtn.frame.size.width, 0);
            
        }else{
         
            [cell.signatureImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSignatureImage:)];
            [singleTap setNumberOfTapsRequired:1];
            [cell.signatureImage addGestureRecognizer:singleTap];
            cell.signatureImage.image = signatureImage;
            cell.signatureImage.frame = CGRectMake(cell.signatureImage.frame.origin.x, cell.signatureImage.frame.origin.y, cell.signatureBtn.frame.size.width, 80);
        }
        
        [cell.checkTermCondition addTarget:self action:@selector(checkTermsCondition) forControlEvents:UIControlEventTouchUpInside];
        [cell.termsConditionBtn addTarget:self action:@selector(termsConditionAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.signatureBtn addTarget:self action:@selector(signatureAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.bidNowBtn addTarget:self action:@selector(bidNowAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.bidLaterBtn addTarget:self action:@selector(bidLaterAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.chatBtn addTarget:self action:@selector(bidChatAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.notIntersetedBtn addTarget:self action:@selector(notIntersetedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)tapOnSignatureImage:(UIGestureRecognizer *)recognizer {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GlobalPopUpImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalPopUpImageViewController"];
    popupView.imageUrl = @"";
    popupView.carImage = signatureImage;
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:popupView animated:YES completion:nil];
}
#pragma mark - end

#pragma mark - Set label dynamic height
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}
#pragma mark - end

#pragma mark - Start timer method
- (void)startBidTimer {
    seconds = seconds - 30;
    hours = seconds / (60 * 60);
    minutes = (seconds / 60) % 60;
    NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:0];
    BidInfoTableViewCell * cell = (BidInfoTableViewCell *)[self.bidInfoTableView cellForRowAtIndexPath:index];  //Use cell component
    [cell.bidTimeLeftBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    if (seconds < 1) {
        isTimeEnd = YES;
        [bidTimer invalidate];
        if (!isBidExist) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"You cannot bid as the bid has been closed." closeButtonTitle:nil duration:0.0f];
        }
    }
    [_bidInfoTableView reloadData];
}
#pragma mark - end

#pragma mark - Set attributed string
- (NSMutableAttributedString *)setAttributrdStringAtButton:(NSString *)unselectedString selectedString:(NSString *)selectedString unselecteFont:(UIFont*)unselecteFont selectedFont:(UIFont*)selectedFont selectedColor:(UIColor *)selectedColor unselectedColor:(UIColor *)unselectedColor {
    
    NSDictionary *dict1 = @{NSForegroundColorAttributeName:unselectedColor,
                            NSFontAttributeName:unselecteFont};
    NSDictionary *dict2 = @{NSForegroundColorAttributeName:selectedColor,
                            NSFontAttributeName:selectedFont};
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:unselectedString attributes:dict1]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:selectedString attributes:dict2]];
    
    return attString;
}
#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [biddingImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"carImage";
    BidInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell displayData:(int)indexPath.row data:[biddingImages objectAtIndex:(int)indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GlobalPopUpImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalPopUpImageViewController"];
    
//    if ([[[biddingImages objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"right_image"]) {
        popupView.placeHolderImage = @"carPlaceholder";
        popupView.imageUrl = [biddingImages objectAtIndex:indexPath.row];
        popupView.popupTitle = @"";
//    }
//    else  if ([[[biddingImages objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"box_on_top"]) {
//        popupView.placeHolderImage = @"boxOnTop.png";
//        popupView.imageUrl = [[biddingImages objectAtIndex:indexPath.row] objectForKey:@"image_url"];
//        popupView.popupTitle = @"Box On Top";
//    }
//    else  if ([[[biddingImages objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"left_image"]) {
//        popupView.placeHolderImage = @"leftSide.png";
//        popupView.imageUrl = [[biddingImages objectAtIndex:indexPath.row] objectForKey:@"image_url"];
//        popupView.popupTitle = @"Left Side";
//    }
//    else  if ([[[biddingImages objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"front_image"]) {
//        popupView.placeHolderImage = @"front.png";
//        popupView.imageUrl = [[biddingImages objectAtIndex:indexPath.row] objectForKey:@"image_url"];
//        popupView.popupTitle = @"Front";
//    }
//    else  if ([[[biddingImages objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"rear_image"]) {
//        popupView.placeHolderImage = @"rear.png";
//        popupView.imageUrl = [[biddingImages objectAtIndex:indexPath.row] objectForKey:@"image_url"];
//        popupView.popupTitle = @"Rear";
//    }
//    else {
//        popupView.placeHolderImage = @"OtherSide.png";
//        popupView.imageUrl = [[biddingImages objectAtIndex:indexPath.row] objectForKey:@"image_url"];
//        popupView.popupTitle = @"Optional";
//    }
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:popupView animated:YES completion:nil];
}
#pragma mark - end

#pragma mark - Call webservices
-(int)bidInfoDateComparision:(NSString *)currentDate endDate:(NSString *)endDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:s"];
    NSDate *currentTime = [f dateFromString:currentDate];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:s"];
    NSDate *endTime = [f dateFromString:endDate];
    if ([currentTime compare:endTime] == NSOrderedDescending)
    {
//        NSLog(@"date1 is later than date2");
        [UserDefaultManager setValue:@"false" key:@"isCampaignRunning"];
        return 3;
    }
    else
    {
        [UserDefaultManager setValue:@"true" key:@"isCampaignRunning"];
        return 2;
    }
}

- (void)getBidInformation {
    
    [[CampaignService sharedManager] getBidInfoService:bidId carId:carId success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        
        int campaignStatus = [self bidInfoDateComparision:[[responseObject objectForKey:@"bidding"] objectForKey:@"currentDateTime"] endDate:[[responseObject objectForKey:@"bidding"] objectForKey:@"bidClosingDateTime"]];
        if (campaignStatus==3) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"You cannot bid as the bid has been closed." closeButtonTitle:nil duration:0.0f];
        }
        else if ([[[responseObject objectForKey:@"bidding"] objectForKey:@"status"] isEqualToString:@"Discarded"]) {
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"You cannot bid as your bid has been rejected." closeButtonTitle:nil duration:0.0f];
        }
        else if ([[[responseObject objectForKey:@"bidding"] objectForKey:@"status"] isEqualToString:@"Confirmed"] && !isBidExist) {
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"OK" actionBlock:^(void) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:@"You cannot bid as your bid has already been approved by Admin." closeButtonTitle:nil duration:0.0f];
        }
        else {
            
            biddingDetail = [[responseObject objectForKey:@"bidding"] mutableCopy];
            maxBidValue = [[biddingDetail objectForKey:@"maxBid"] floatValue];
            biddingImages = [[biddingDetail objectForKey:@"campaign_images"] mutableCopy];
            
            seconds = [[UserDefaultManager formateDate:[biddingDetail objectForKey:@"bidClosingDateTime"]] timeIntervalSinceDate:[UserDefaultManager formateDate:[biddingDetail objectForKey:@"currentDateTime"]]];
            hours = seconds / (60 * 60);
            minutes = (seconds / 60) % 60;
            [_bidInfoTableView reloadData];
            
            if (!isBidExist) {
                if (([[UserDefaultManager getValue:@"isFacebookConnected"] intValue] == 0)&&[[[responseObject objectForKey:@"bidding"] objectForKey:@"fb_connect"] intValue]==1) {
                    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    FacebookConenctPopViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"FacebookConenctPopViewController"];
                    popupView.popupTitle = @"Facebook Connect";
                    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
                    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                    popupView.delegate=self;
                    [self presentViewController:popupView animated:YES completion:nil];
                }
            }
        }
    }
                                               failure:^(NSError *error) {
                                                   
                                                   if ([error isKindOfClass:[NSMutableDictionary class]]||[error isKindOfClass:[NSDictionary class]]) {
                                                       NSMutableDictionary *errorDict=[error mutableCopy];
                                                       if ([[errorDict objectForKey:@"status"] intValue]==400) {
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }
                                                   }
                                                  
                                               }];
}

- (void)acceptRejectCampaignbid:(NSString *)isAccept {
    
    BidInfoModel *tempModel=[[BidInfoModel alloc] init];
    tempModel.campaignId=[biddingDetail objectForKey:@"campaignId"];
    tempModel.advertiserName=[biddingDetail objectForKey:@"advertiser_name"];
    tempModel.campaignName=[biddingDetail objectForKey:@"campaign_name"];
    tempModel.brand=[biddingDetail objectForKey:@"campaign_brand"];
    tempModel.avgBidAmount=[biddingDetail objectForKey:@"avg_bid_amount"];
    tempModel.maxBid=[biddingDetail objectForKey:@"maxBid"];
    
    if (![bidAmountText isEqualToString:@""]) {
        tempModel.myBid=bidAmountText;
    }
    else if ([biddingDetail objectForKey:@"my_bid"] != nil && ![[biddingDetail objectForKey:@"my_bid"] isEqualToString:@""]) {
        tempModel.myBid=[biddingDetail objectForKey:@"my_bid"];
    }
    
    tempModel.bidId=bidId;
    tempModel.carOwnerName=[UserDefaultManager getValue:@"userName"];
    tempModel.carPlateNumber=[biddingDetail objectForKey:@"plate_number"];
    tempModel.ICNumber=[UserDefaultManager getValue:@"icNumber"];
    
    [[CampaignService sharedManager] acceptRejectCampaignbidService:bidId campaignId:[biddingDetail objectForKey:@"campaignId"] bidAmount:tempModel.myBid signatureImage:@"" rejectReason:reasonText isAccept:isAccept previewDataModel:[tempModel copy] success:^(id responseObject) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
           [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
        
    }
    failure:^(NSError *error) {
    }];
}
#pragma mark - end

#pragma mark - Bid validation
- (BOOL)performSubmitValidation {
    
    NSIndexPath *index=[NSIndexPath indexPathForRow:4 inSection:0];
    BidInfoTableViewCell * cell = (BidInfoTableViewCell *)[self.bidInfoTableView cellForRowAtIndexPath:index];
    if ([cell.myBidField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please enter your bid amount."];
        return NO;
    }
    else if ([cell.myBidField.text intValue] < 1) {
        [UserDefaultManager showAlertMessage:@"Your bid amount should greater than zero."];
        return NO;
    }
    else if ([cell.myBidField.text floatValue] > maxBidValue) {
        [UserDefaultManager showAlertMessage:@"Your bid amount should be less than maximum bid amount."];
        return NO;
    }
    else if (!cell.checkTermCondition.selected) {
        [UserDefaultManager showAlertMessage:@"Please accept terms and conditions."];
        return NO;
    }
    else if ([signatureImageName isEqualToString:@""]) {
        [UserDefaultManager showAlertMessage:@"Please upload the signature image."];
        return NO;
    }
    //    else if ([currentDate compare:[[notificaitonHistoryArray objectAtIndex:[sender tag]] valueForKeyPath:@"extra_params.bid_end_date"]] == NSOrderedAscending)
    //    {
    //
    //    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (void)chatAction {
    
    [[ZDCChat instance].api trackEvent:@"Chat button pressed: (pre-set data)"];
    
    // before starting the chat set the visitor data
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        
        visitor.phone = [UserDefaultManager getValue:@"mobileNumber"];
        visitor.name = [UserDefaultManager getValue:@"emailId"];
        visitor.email = [UserDefaultManager getValue:@"emailId"];
    }];
    
    [ZDCChat startChatIn:[UIApplication sharedApplication].keyWindow.rootViewController.navigationController withConfig:^(ZDCConfig *config) {
        
        config.preChatDataRequirements.name = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.email = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
        config.tags = @[@"iPhoneChat"];
    }];
}

- (void)notificationAction {
    NotificationHistoryViewController *objNotificationHistory = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"NotificationHistoryViewController"];
    objNotificationHistory.isPreviousBarButton = YES;
    
    [self.navigationController pushViewController:objNotificationHistory animated:YES];
}

- (void)checkTermsCondition {
    
    NSIndexPath *index=[NSIndexPath indexPathForRow:4 inSection:0];
    BidInfoTableViewCell * cell = (BidInfoTableViewCell *)[self.bidInfoTableView cellForRowAtIndexPath:index];
    if (cell.checkTermCondition.selected) {
        cell.checkTermCondition.selected = NO;
    }
    else {
        cell.checkTermCondition.selected = YES;
    }
}

- (void)termsConditionAction {
    
    CmsContentViewController *objCms = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CmsContentViewController"];
    objCms.cmsId = @"BidInfo";
    objCms.title = @"Terms and Conditions";
    objCms.cmsContent = [biddingDetail objectForKey:@"termsandconditions"];
    objCms.gotItString = self.title;
    [self.navigationController pushViewController:objCms animated:YES];
}

- (void)signatureAction {
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignatureViewController *signatureViewObj =[storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
    signatureViewObj.bidInfoObj=self;
    signatureViewObj.bidId = bidId;
    signatureViewObj.previousView = @"bidInfo";
    
    [self presentViewController:signatureViewObj animated:YES completion:nil];
}

- (void)bidNowAction {
    
    Internet *internet=[[Internet alloc] init];
    if ([self performSubmitValidation]&&![internet start]) {
        
        reasonText = @"";
        
        BidInfoModel *tempModel=[[BidInfoModel alloc] init];
        tempModel.campaignId=[biddingDetail objectForKey:@"campaignId"];
        tempModel.advertiserName=[biddingDetail objectForKey:@"advertiser_name"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *fromDateTime = [dateFormatter dateFromString:[biddingDetail objectForKey:@"durationFromtime"]];
        NSDate *ToDateTime = [dateFormatter dateFromString:[biddingDetail objectForKey:@"durationTotime"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
         tempModel.duration = [NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:fromDateTime],[dateFormatter stringFromDate:ToDateTime]];
        
        tempModel.campaignName=[biddingDetail objectForKey:@"campaign_name"];
        tempModel.brand=[biddingDetail objectForKey:@"campaign_brand"];
        tempModel.avgBidAmount=[biddingDetail objectForKey:@"avg_bid_amount"];
        tempModel.maxBid=[biddingDetail objectForKey:@"maxBid"];
        if (![bidAmountText isEqualToString:@""]) {
            tempModel.myBid=bidAmountText;
        }
        else if ([biddingDetail objectForKey:@"my_bid"] != nil && ![[biddingDetail objectForKey:@"my_bid"] isEqualToString:@""]) {
            tempModel.myBid=[biddingDetail objectForKey:@"my_bid"];
        }
        
        tempModel.bidId=bidId;
        tempModel.carOwnerName=[UserDefaultManager getValue:@"userName"];
        tempModel.carPlateNumber=[biddingDetail objectForKey:@"plate_number"];
        tempModel.ICNumber=[UserDefaultManager getValue:@"icNumber"];
        
        
        NSString *currentDateTimeString=[biddingDetail objectForKey:@"currentDateTime"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
        NSDate *currentDate=[dateFormatter dateFromString:currentDateTimeString];
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
        tempModel.dateTime = [dateFormatter stringFromDate:currentDate];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BidPreviewViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"BidPreviewViewController"];
        nextView.previewData=[tempModel copy];
        nextView.previewSignatureImage=signatureImage;
        [self.navigationController pushViewController:nextView animated:YES];
    }
}

- (void)bidLaterAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bidChatAction {
    
    [[ZDCChat instance].api trackEvent:@"Chat button pressed: (pre-set data)"];
    
    // before starting the chat set the visitor data
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        
        visitor.phone = [UserDefaultManager getValue:@"mobileNumber"];
        visitor.name = [UserDefaultManager getValue:@"emailId"];
        visitor.email = [UserDefaultManager getValue:@"emailId"];
    }];
    
    [ZDCChat startChatIn:[UIApplication sharedApplication].keyWindow.rootViewController.navigationController withConfig:^(ZDCConfig *config) {
        
        config.preChatDataRequirements.name = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.email = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
        config.tags = @[@"iPhoneChat"];
    }];
}

- (void)notIntersetedAction {
    
    if (isTimeEnd) {
//        NSLog(@"end");
    }
    else {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GlobalPopupViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalPopupViewController"];
        popupView.popupTitle = @"Not Interested";
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        popupView.delegate=self;
        [self presentViewController:popupView animated:YES completion:nil];
    }
}
#pragma mark - end

#pragma mark - Delegate method for global popup
- (void)popupViewDelegateMethod:(int)option reasonText:(NSString *)myReasonText {
    
    if (option == 1) {
        bidAmountText = @"";
        signatureImageName = @"";
        reasonText = myReasonText;
        [myDelegate showIndicator];
        [self performSelector:@selector(acceptRejectCampaignbid:) withObject:@"false" afterDelay:.1];
    }
}
#pragma mark - end

#pragma mark - Delegate method for facebook connect popup
- (void)facebookConenctPopupViewDelegateMethod:(int)option {
    
    if (option == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
