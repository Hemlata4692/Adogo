//
//  AmbassadorHistoryViewController.m
//  Adogo
//
//  Created by Monika on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AmbassadorHistoryViewController.h"
#import "AmbassadorHistoryTableViewCell.h"
#import "CampaignService.h"
#import <Social/Social.h>
#import "SCLAlertView.h"
#import "FbAmbassadorPostViewController.h"
#import "UserService.h"

@interface AmbassadorHistoryViewController ()<FBSDKSharingDelegate>
{
    SLComposeViewController *slComposerSheet;
    int selectedIndex;
    NSString *postId;
    FbAmbassadorPostViewController *fbAmbassadorPostObj;
    int checkCount;
}
@property (strong, nonatomic) IBOutlet UITableView *ambassadorHistoryTableView;
@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@end

@implementation AmbassadorHistoryViewController
@synthesize ambassadorHistoryTableView;
@synthesize isDashBoard, isPosted;
@synthesize ambassadorHistoryArray, currentDate;
@synthesize hitoryTimer;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ambassadorListUpdate) name:@"AmbassadorList" object:nil];
    if (isDashBoard) {
        self.navigationItem.title=@"Ambassador Posts";
    }
    else {
        self.navigationItem.title=@"Ambassador History";
        ambassadorHistoryArray=[[NSMutableArray alloc]init];
        [myDelegate showIndicator];
        [self performSelector:@selector(getAmbassadorHistory) withObject:nil afterDelay:.1];
    }
    postId = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[self navigationController] setNavigationBarHidden:NO];
    if (isDashBoard) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.hidesBackButton = YES;
        [self addLeftBarButtonWithImageBack:[UIImage imageNamed:@"back_white"]];
        myDelegate.isAmbassadorPostListing = true;
        if ([hitoryTimer isValid]) {
            [hitoryTimer invalidate];
            hitoryTimer = nil;
        }
        ambassadorHistoryArray=[[NSMutableArray alloc]init];
        [ambassadorHistoryTableView reloadData];
        
        [myDelegate showIndicator];
        [self performSelector:@selector(getAmbassadorPostList) withObject:nil afterDelay:.1];
    }
}

- (void)addLeftBarButtonWithImageBack:(UIImage *)backImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:framing];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Notification handling method
- (void)ambassadorListUpdate{
    
    [myDelegate stopIndicator];
    [myDelegate showIndicator];
    [self performSelector:@selector(getAmbassadorPostList) withObject:nil afterDelay:.1];
}
#pragma mark - end

#pragma mark - Set timer
- (void)startTimer {
    
    NSMutableArray *tempArray = [ambassadorHistoryArray mutableCopy];
    for (int i = 0; i < tempArray.count; i++) {
        long long seconds;
        seconds = [[[ambassadorHistoryArray objectAtIndex:[ambassadorHistoryArray indexOfObject:[tempArray objectAtIndex:i]]] objectForKey:@"second"] longLongValue];
        seconds = seconds - 5;
        
        bool checkPost = false;
        if (myDelegate.isAmbassadorPost) {
            if (i == selectedIndex) {
                checkPost = true;
                [fbAmbassadorPostObj setTimerValue:[NSNumber numberWithLongLong:seconds]];
            }
        }
        //Here check seconds <=59 because time start with +59. seconds<=59 means seconds<=0
        if (seconds <= 59) {
            
            if (!checkPost) {
                [ambassadorHistoryArray removeObject:[tempArray objectAtIndex:i]];
            }
            if (ambassadorHistoryArray.count == 0) {
                
                myDelegate.isAmbassadorPostListing = false;
                [hitoryTimer invalidate];
                hitoryTimer = nil;
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                [myDelegate.window setRootViewController:objReveal];
                [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
                [myDelegate.window makeKeyAndVisible];
            }
            else{
                [ambassadorHistoryTableView reloadData];
            }
        }
        else {
            NSMutableDictionary *tempDict = [[tempArray objectAtIndex:i] mutableCopy];
            [tempDict setObject:[NSNumber numberWithLongLong:seconds] forKey:@"second"];
            
            [ambassadorHistoryArray replaceObjectAtIndex:[ambassadorHistoryArray indexOfObject:[tempArray objectAtIndex:i]] withObject:tempDict];
        }
    }
}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"++++++++++++%ld------%@", (long)indexPath.row,[[ambassadorHistoryArray objectAtIndex:indexPath.row] objectForKey:@"post_content"]);
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 75,500);
    CGRect textRect = [[[ambassadorHistoryArray objectAtIndex:indexPath.row] objectForKey:@"post_content"]
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont railwayRegularWithSize:12]}
                       context:nil];
   
    if (textRect.size.height < 21) {
         return 70;
    }
    else{
         return 10 + textRect.size.height + 2 + 5 + 21 + 20;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ambassadorHistoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AmbassadorHistoryTableViewCell *cell;
    NSString *simpleTableIdentifier = @"AmbassadorCell";
    cell = [ambassadorHistoryTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[AmbassadorHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor clearColor];
    else
        cell.backgroundColor = [UIColor colorWithRed:(170/255.0) green:(175/255.0) blue:(193/255.0) alpha:0.5f];
    
    cell.repostButton.tag = (int)indexPath.row;
    [cell displayData:[ambassadorHistoryArray objectAtIndex:indexPath.row] currentDateStr:currentDate isDashBoard:isDashBoard];
    [cell.repostButton addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
       
    return cell;
}
#pragma mark - end

#pragma mark - Webservice method
- (void)getAmbassadorPostList
{
    ambassadorHistoryArray=[[NSMutableArray alloc]init];
    [[CampaignService sharedManager] getAmbassadorPostList:^(id responseObject)
     {
         ambassadorHistoryArray = [[responseObject objectForKey:@"ambassador_posts"]mutableCopy];
         if (ambassadorHistoryArray.count != 0) {
             currentDate = [responseObject objectForKey:@"current_server_time"];
             
             for (int i = 0; i < ambassadorHistoryArray.count; i++) {
                 NSMutableDictionary *tempDict = [[ambassadorHistoryArray objectAtIndex:i] mutableCopy];
                 [tempDict setObject:[NSNumber numberWithLongLong:[[UserDefaultManager formateDate:[[ambassadorHistoryArray objectAtIndex:i] objectForKey:@"duration"]] timeIntervalSinceDate:[UserDefaultManager formateDate:currentDate]] + 59] forKey:@"second"];
                 
                 [ambassadorHistoryArray replaceObjectAtIndex:i withObject:tempDict];
             }
             hitoryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self
                                                      selector:@selector(startTimer)
                                                      userInfo:nil
                                                       repeats:YES];
             [ambassadorHistoryTableView reloadData];
         }
         else {
         
             UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
             myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
             [myDelegate.window setRootViewController:objReveal];
             [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
             [myDelegate.window makeKeyAndVisible];
         }
     }
                                                  failure:^(NSError *error)
     {
         
     }];
}

- (void)getAmbassadorHistory
{
     ambassadorHistoryArray=[[NSMutableArray alloc]init];
    [[CampaignService sharedManager] getAmbassadorHistory:^(id responseObject)
     {
         ambassadorHistoryArray = [[responseObject objectForKey:@"history"]mutableCopy];
         currentDate = [responseObject objectForKey:@"current_date"];
         if (ambassadorHistoryArray.count<1)
         {
             _noRecordLabel.hidden = NO;
         }
         else
         {
             _noRecordLabel.hidden = YES;
         }
        [ambassadorHistoryTableView reloadData];
     }
                                               failure:^(NSError *error)
     {
         
     }];
}

- (void)setFacebookShare {
    
    [[UserService sharedManager] SaveFacebookShareId:[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"id"] referenceId:postId success:^(id responseObject) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            [myDelegate showIndicator];
            [self performSelector:@selector(getAmbassadorHistory) withObject:nil afterDelay:.1];
            
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
    } failure:^(NSError *error) {
        
//        NSLog(@"log");
    }] ;
}
#pragma mark - end

#pragma mark - UIView actions
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)repostAction:(UIButton *)sender {
    
//    NSLog(@"%d",(int)sender.tag);
    selectedIndex = (int)sender.tag;
    
    if (isDashBoard) {
        isPosted = false;
        myDelegate.isAmbassadorPostListing = false;
        fbAmbassadorPostObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FbAmbassadorPostViewController"];
        fbAmbassadorPostObj.ambassadorId = [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"id"];
        fbAmbassadorPostObj.seconds = [[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"second"] longLongValue];
        fbAmbassadorPostObj.numberOfPost = (int)ambassadorHistoryArray.count;
        fbAmbassadorPostObj.content = [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_content"];
        fbAmbassadorPostObj.imageUrl = [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_image"];
        fbAmbassadorPostObj.shareTitleText = [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"title"];
        fbAmbassadorPostObj.sharedUrl = [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"];
        fbAmbassadorPostObj.ambassadorHistoryObj = self;
        fbAmbassadorPostObj.previousScreen = 2;
        
        [self.navigationController pushViewController:fbAmbassadorPostObj animated:YES];
    }
    else {
        [self postFbContent];
    }
}
#pragma mark - end

#pragma mark - Fb post methods
- (void)postFbContent {
    
    if ([FBSDKAccessToken currentAccessToken] == nil || ![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.defaultAudience = FBSDKDefaultAudienceEveryone;  //This code sets public post as default
        [login
         logInWithPublishPermissions: @[@"publish_actions"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 [UserDefaultManager showAlertMessage:@"A temporary error occurred, please try again later."];
//                 NSLog(@"Process error");
             } else if (result.isCancelled) {
//                 NSLog(@"Cancelled");
             } else {
//                 NSLog(@"Logged in");
                 NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
//                 NSLog(@"fbAccessToken is %@", fbAccessToken);
                 
                 [myDelegate showIndicator];
                 if ([FBSDKAccessToken currentAccessToken]) {
                     [self fetchFBData];
                 }
             }
         }];
    }
    else {
        [myDelegate showIndicator];
        [self fetchFBData];
    }
}

//- (BOOL) validateUrl:(NSString *)urlString {
//    NSString *urlRegEx =
//    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*#))+";
//    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
//    return [urlTest evaluateWithObject:urlString];
//}


- (BOOL)isValidURL:(NSString *)urlString {
    NSUInteger length = [urlString length];
    // Empty strings should return NO
    if (length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:urlString options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        }
        else {
//            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}

- (BOOL) emptyString:(NSString *)string{
    return ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0);
}

- (void)fetchFBData {
    
    NSDictionary *properties;
//    NSLog(@"%@,%@",([self emptyString:[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"]] ?@"true":@"false"),([self isValidURL:[[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]?@"true":@"false"));
   
    if ([[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"]==nil||[self emptyString:[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"]]||![self isValidURL:[[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
        properties = @{
                       @"og:type": @"share_adogo:post",
                       @"og:title": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"title"],
                       @"og:description": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_content"],
                       @"og:image": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_image"],
                       @"og:url": @"https://www.facebook.com/AdogoSG/"
                       };
    }
    else {
        
        NSString *sharedUrl=[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"];
        sharedUrl=[sharedUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"] containsString:@"http://"]&&![[[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_url"] containsString:@"https://"]) {
            
            sharedUrl=[NSString stringWithFormat:@"http://%@",sharedUrl];
        }
        
        properties = @{
                       @"og:type": @"share_adogo:post",
                       @"og:title": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"title"],
                       @"og:description": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_content"],
                       @"og:image": [[ambassadorHistoryArray objectAtIndex:selectedIndex] objectForKey:@"post_image"],
                       @"og:url": sharedUrl
                       };
    }
    
    
    checkCount=0;
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"share_adogo:share";
    [action setObject:object forKey:@"share_adogo:post"];
    [action setString:@"true" forKey:@"fb:explicitly_shared"];
    FBSDKShareOpenGraphContent *content1 = [[FBSDKShareOpenGraphContent alloc] init];
    content1.action = action;
    content1.previewPropertyName = @"share_adogo:post";
    [FBSDKShareAPI shareWithContent:content1 delegate:self];   //Use for direct sharing without open dialog box.
}
#pragma mark - end

#pragma mark - Facebook share delegates
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    checkCount=1;
//    NSLog(@"%@",[results objectForKey:@"postId"]);
    postId = [results objectForKey:@"postId"];
    [self performSelector:@selector(setFacebookShare) withObject:nil afterDelay:.1];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    checkCount=checkCount+1;
    [myDelegate stopIndicator];
//    NSLog(@"canceled!");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
//    NSLog(@"sharing error:%@", error);
    if (checkCount==0) {
        NSString *message = @"There was a problem sharing. Please try again!";
        [UserDefaultManager showAlertMessage:message];
    }
    checkCount=checkCount+1;
   
    [myDelegate stopIndicator];
}
#pragma mark - end
@end
