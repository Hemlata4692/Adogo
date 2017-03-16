//
//  FbAmbassadorPostViewController.m
//  Adogo
//
//  Created by Ranosys on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "FbAmbassadorPostViewController.h"
#import <Social/Social.h>
#import "DashboardViewController.h"
#import "SCLAlertView.h"
#import "UserService.h"
#import "CampaignService.h"

@interface FbAmbassadorPostViewController ()<FBSDKSharingDelegate> {

    SLComposeViewController *slComposerSheet;
    NSTimer *myAmbassadorTimer;
    long long hours;
   long long minutes;
    NSString *postId;
    BOOL presentFbView;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIButton *timerBtn;
@property (strong, nonatomic) IBOutlet UIView *postView;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (strong, nonatomic) IBOutlet UILabel *shareTitle;
@property (strong, nonatomic) IBOutlet UILabel *shareDescription;
@property (strong, nonatomic) IBOutlet UIImageView *downArrow;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@end

@implementation FbAmbassadorPostViewController
@synthesize previousScreen;
@synthesize startDateTime, endDateTime, ambassadorId, numberOfPost, content, imageUrl, shareTitleText, seconds;
@synthesize ambassadorHistoryObj, sharedUrl;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeFraming];
    [self viewCustomization];
    presentFbView = false;
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        [_shareBtn setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    }
    else {
        [_shareBtn setTitle:@"Share/Post to Facebook" forState:UIControlStateNormal];
    }
    myDelegate.facebookCount = 1;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (!presentFbView) {
        myDelegate.isAmbassadorPost = true;
        [[self navigationController] setNavigationBarHidden:YES];
        if (previousScreen == 2){
            
            hours = seconds / (60 * 60);
            minutes = (seconds / 60) % 60;
            [_timerBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
            _shareDescription.text = content;
            _shareTitle.text = shareTitleText;
            
            [myDelegate showIndicator];
            [self performSelector:@selector(downloadImages) withObject:nil afterDelay:.1];
        }
        else {
            if (previousScreen == 1) {
                [_timerBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"00:00"] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
                _shareDescription.text = content;
                _shareTitle.text = shareTitleText;
                
                [myDelegate showIndicator];
                [self performSelector:@selector(getCurrentDateTimeService) withObject:nil afterDelay:.1];
            }
            else {
                hours = seconds / (60 * 60);
                minutes = (seconds / 60) % 60;
                [_timerBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
                myAmbassadorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                     target:self
                                                                   selector:@selector(startTimer)
                                                                   userInfo:nil
                                                                    repeats:YES];
                [myDelegate showIndicator];
                [self performSelector:@selector(postAmbassordorPostService) withObject:nil afterDelay:.1];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View customization
- (void)viewCustomization {

    _postView.layer.cornerRadius = 5.0f;
    _postView.layer.masksToBounds = YES;
    _postImage.backgroundColor = [UIColor colorWithRed:(218.0/255.0) green:(218.0/255.0) blue:(218.0/255.0) alpha:1.0f];
    _postImage.image = [UIImage imageNamed:@"FBPostPlaceholder"];
    _shareBtn.layer.cornerRadius = 3.0f;
    _shareBtn.layer.masksToBounds = YES;
    _timerBtn.layer.cornerRadius = 3.0f;
    _timerBtn.layer.masksToBounds = YES;
}

- (void)customizeFraming {
    
    [self removeAutolayout];
    _postView.frame = CGRectMake(10, 186, [[UIScreen mainScreen] bounds].size.width - 20, 248);
    _postImage.frame = CGRectMake(8, 15, [[UIScreen mainScreen] bounds].size.width - 36, (((float)152/(float)290) * self.postView.frame.size.width));
    
    float height = [self getDynamicLabelHeight:_shareTitle.text font:[UIFont railwayBoldWithSize:17] widthValue:_postImage.frame.size.width - 20];
    _shareTitle.numberOfLines = 0;
    _shareTitle.frame = CGRectMake(18, _postImage.frame.size.height + _postImage.frame.origin.y + 15, _postImage.frame.size.width - 20, height + 6);
    height = [self getDynamicLabelHeight:content font:[UIFont railwayRegularWithSize:13] widthValue:_postImage.frame.size.width - 14];
    _shareDescription.numberOfLines = 0;
    _shareDescription.frame = CGRectMake(15, _shareTitle.frame.origin.y + _shareTitle.frame.size.height - 5, _postImage.frame.size.width - 14, height + 20);
    _postView.frame = CGRectMake(10, 186, [[UIScreen mainScreen] bounds].size.width - 20, _shareDescription.frame.origin.y + _shareDescription.frame.size.height);
    _downArrow.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) - 15, _postView.frame.origin.y + _postView.frame.size.height - 2, 30, 12);
    _shareBtn.frame = CGRectMake(25, _downArrow.frame.origin.y + _downArrow.frame.size.height + 2, [[UIScreen mainScreen] bounds].size.width - 50, 46);
    _mainView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _shareBtn.frame.origin.y + _shareBtn.frame.size.height + 70);
    _scrollView.contentSize = CGSizeMake(0,_mainView.frame.size.height);
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

- (void)removeAutolayout {

    _mainView.translatesAutoresizingMaskIntoConstraints = YES;
    _postView.translatesAutoresizingMaskIntoConstraints = YES;
    _postImage.translatesAutoresizingMaskIntoConstraints = YES;
    _shareTitle.translatesAutoresizingMaskIntoConstraints = YES;
    _shareDescription.translatesAutoresizingMaskIntoConstraints = YES;
    _shareBtn.translatesAutoresizingMaskIntoConstraints = YES;
    _downArrow.translatesAutoresizingMaskIntoConstraints = YES;
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)backAction:(id)sender {
    
    myDelegate.isAmbassadorPost = false;
    if ([myAmbassadorTimer isValid]) {
        [myAmbassadorTimer invalidate];
    }
    
    if ([ambassadorHistoryObj.hitoryTimer isValid]) {
        [ambassadorHistoryObj.hitoryTimer invalidate];
    }
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [myDelegate.window setRootViewController:objReveal];
    [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
    [myDelegate.window makeKeyAndVisible];
}

- (IBAction)postSharing:(UIButton *)sender {
    
    int flag = 0;
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        flag = 1;
    }
    else if(![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        flag = 2;
    }
    
    if ([FBSDKAccessToken currentAccessToken] == nil || ![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        
        _shareBtn.userInteractionEnabled = NO;
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        presentFbView = true;
        
        login.defaultAudience = FBSDKDefaultAudienceEveryone;  //This code sets public post as default
        [login
         logInWithPublishPermissions: @[@"publish_actions"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 [UserDefaultManager showAlertMessage:@"A temporary error occurred, please try again later."];
                 //NSLog(@"Process error");
                 _shareBtn.userInteractionEnabled = YES;
             } else if (result.isCancelled) {
                 //NSLog(@"Cancelled");
                 _shareBtn.userInteractionEnabled = YES;
             } else {
                 //NSLog(@"Logged in");
                 NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                 //NSLog(@"fbAccessToken is %@", fbAccessToken);
                 [_shareBtn setTitle:@"Share/Post to Facebook" forState:UIControlStateNormal];
                 if (flag == 2) {
                    [myDelegate showIndicator];
                    if ([FBSDKAccessToken currentAccessToken]) {
                     
                        [self fetchFBData];
                    }
                 }
                 else {
                     _shareBtn.userInteractionEnabled = YES;
                 }
             }
         }];
    }
    else {
        presentFbView = true;
        [myDelegate showIndicator];
        [self fetchFBData];
    }
}

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
            //NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}


- (BOOL) emptyString:(NSString *)string{
    return ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0);
}

- (void)fetchFBData {
    
    NSDictionary *properties;
    sharedUrl=[sharedUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog(@"%@,%@",([self emptyString:sharedUrl] ?@"true":@"false"),([self isValidURL:[sharedUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]?@"true":@"false"));
    
    if (![self emptyString:sharedUrl]&&![sharedUrl containsString:@"http://"]&&![sharedUrl containsString:@"https://"]) {
        sharedUrl=[NSString stringWithFormat:@"http://%@",sharedUrl];
    }
    if (sharedUrl==nil||[self emptyString:sharedUrl]||![self isValidURL:[sharedUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
        properties = @{
                       @"og:type": @"share_adogo:post",
                       @"og:title": shareTitleText,
                       @"og:description": content,
                       @"og:image": imageUrl,
                       @"og:url": @"https://www.facebook.com/AdogoSG/"
                       };
    }
    else {
        properties = @{
                       @"og:type": @"share_adogo:post",
                       @"og:title": shareTitleText,
                       @"og:description": content,
                       @"og:image": imageUrl,
                       @"og:url": sharedUrl
                       };
    }
    

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

#pragma mark - Facebook SDK post share delegates
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    presentFbView = false;
    //NSLog(@"%@",[results objectForKey:@"postId"]);
    postId = [results objectForKey:@"postId"];
    [self performSelector:@selector(setFacebookShare) withObject:nil afterDelay:.1];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [myDelegate stopIndicator];
    _shareBtn.userInteractionEnabled = YES;
    //NSLog(@"canceled!");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [myDelegate stopIndicator];
    _shareBtn.userInteractionEnabled = YES;
    //NSLog(@"sharing error:%@", error);
    NSString *message = @"There was a problem sharing. Please try again!";
    [UserDefaultManager showAlertMessage:message];
}
#pragma mark - end

#pragma mark - Webservice
- (void)downloadImages {
    
    __weak UIImageView *weakRef = _postImage;
    __weak typeof(self) weakSelf = self;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [_postImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"FBPostPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
        [myDelegate stopIndicator];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //NSLog(@"fail");
        [myDelegate stopIndicator];
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Retry" actionBlock:^(void) {
            
            [myDelegate showIndicator];
            [weakSelf performSelector:@selector(downloadImages) withObject:nil afterDelay:.1];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"Slow internet, retry to download the image." closeButtonTitle:nil duration:0.0f];
    }];
}

- (void)postAmbassordorPostService {
    
    [[UserService sharedManager] userAmbassodorPostService:ambassadorId success:^(id responseObject) {
        
        [myDelegate stopIndicator];
        
        imageUrl = [[responseObject objectForKey:@"data"] objectForKey:@"post_image"];
        content = [[responseObject objectForKey:@"data"] objectForKey:@"post_content"];
        _shareDescription.text = content;
        shareTitleText = [[responseObject objectForKey:@"data"] objectForKey:@"title"];
        _shareTitle.text = shareTitleText;
        [self customizeFraming];
        [self viewCustomization];
        
        [myDelegate showIndicator];
        [self performSelector:@selector(downloadImages) withObject:nil afterDelay:.1];
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Retry" actionBlock:^(void) {
            
            [myDelegate showIndicator];
            [self performSelector:@selector(postAmbassordorPostService) withObject:nil afterDelay:.1];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"Slow internet, Please try again." closeButtonTitle:nil duration:0.0f];
        //NSLog(@"log");
    }] ;
}

- (void)getCurrentDateTimeService {
    
    [[CampaignService sharedManager] getCurrentDateTimeService:^(id responseObject) {
        
        [myDelegate stopIndicator];
        seconds = [[UserDefaultManager formateDate:endDateTime] timeIntervalSinceDate:[UserDefaultManager formateDate:[responseObject objectForKey:@"current_date"]]] + 59;
        if (seconds <= 59) {
            
            myDelegate.isAmbassadorPost = false;
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [myDelegate.window setRootViewController:objReveal];
            [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
            [myDelegate.window makeKeyAndVisible];
        }
        else {
            hours = seconds / (60 * 60);
            minutes = (seconds / 60) % 60;
            [_timerBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
            myAmbassadorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                 target:self
                                                               selector:@selector(startTimer)
                                                               userInfo:nil
                                                                repeats:YES];
            [myDelegate showIndicator];
            [self performSelector:@selector(downloadImages) withObject:nil afterDelay:.1];
        }
    } failure:^(NSError *error) {
        [myDelegate stopIndicator];
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Retry" actionBlock:^(void) {
            
            [myDelegate showIndicator];
            [self performSelector:@selector(getCurrentDateTimeService) withObject:nil afterDelay:.1];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"Slow internet, Please try again." closeButtonTitle:nil duration:0.0f];
        //NSLog(@"log");
    }] ;
}

- (void)setFacebookShare {
    
    [[UserService sharedManager] SaveFacebookShareId:ambassadorId referenceId:postId success:^(id responseObject) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            myDelegate.isAmbassadorPost = false;
            if (numberOfPost == 1) {
                
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                [myDelegate.window setRootViewController:objReveal];
                [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
                [myDelegate.window makeKeyAndVisible];
            }
            else {
                ambassadorHistoryObj.isPosted = true;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
    } failure:^(NSError *error) {
        
        //NSLog(@"log");
    }] ;
}
#pragma mark - end

#pragma mark - Set timer
- (void)startTimer {
    
    seconds = seconds - 5;
    [self setTimerValue:[NSNumber numberWithLongLong:seconds]];
}

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

- (void)setTimerValue:(NSNumber*)timeInSecond {
    
    //NSLog(@"----------------lsdjfklsd-----------%lld", [timeInSecond longLongValue]);
    hours = [timeInSecond longLongValue] / (60 * 60);
    minutes = ([timeInSecond longLongValue] / 60) % 60;
    [_timerBtn setAttributedTitle:[self setAttributrdStringAtButton:[NSString stringWithFormat:@"%02lld:%02lld", hours, minutes] selectedString:@"Hrs" unselecteFont:[UIFont railwayBoldWithSize:20] selectedFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    if ([timeInSecond longLongValue] <= 59) {
        
        if ([myAmbassadorTimer isValid]) {
            [myAmbassadorTimer invalidate];
        }
        myDelegate.isAmbassadorPost = false;
        if (numberOfPost == 1) {
            
            [myDelegate stopIndicator];
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [myDelegate.window setRootViewController:objReveal];
            [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
            [myDelegate.window makeKeyAndVisible];
        }
        else {
            
            [myDelegate stopIndicator];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
