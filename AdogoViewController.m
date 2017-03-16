//
//  AdogoViewController.m
//  Adogo
//
//  Created by Sumit on 28/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AdogoViewController.h"
#import "SWRevealViewController.h"
#import "UIImage+deviceSpecificMedia.h"
#import "HMSegmentedControl.h"
#import "CarListiewController.h"
#import "InstallationPopupViewController.h"
#import "OnsiteInstallationViewController.h"
#import "ChatHistoryViewController.h"
#import "NotificationHistoryViewController.h"

@interface AdogoViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *barButton;
    UIImageView *navBarHairlineImageView;
    UIBarButtonItem *chatButton,*notificationButton;
}
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation AdogoViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set globally background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[image imageForDeviceWithName:@"bg"]]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    //end
     myDelegate.currentNavController = self.navigationController;   //Set navigation for notification handling
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAlertIndication) name:@"NotificationAlert" object:nil];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu.png"]];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"notification"] secondImage:[UIImage imageNamed:@"chat"]];
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    revealController.panGestureRecognizer.enabled = NO;
    navBarHairlineImageView.hidden = YES;
}

- (void)notificationAlertIndication {

    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"notification"] secondImage:[UIImage imageNamed:@"chat"]];
}

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage
{
    CGRect framing = CGRectMake(0, 0, menuImage.size.width + 10, menuImage.size.height + 10);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    chatButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    if([[UserDefaultManager getValue:@"isNotificationAvailable"] isEqualToString:@"False"])
    {
        buttonImage = [UIImage imageNamed:@"notification"];
    }
    else {
        buttonImage = [UIImage imageNamed:@"notificationAlert"];
    }
    framing = CGRectMake(0, 0, buttonImage.size.width + 10, buttonImage.size.height + 10);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    notificationButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(notificationAction) forControlEvents:UIControlEventTouchUpInside];
    [menu addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:notificationButton,chatButton, nil];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - end
#pragma mark - Add sidebar
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage
{
    
    CGRect frameimg = CGRectMake(0, 0, buttonImage.size.width+5, buttonImage.size.height+5);
    UIButton *button = [[UIButton alloc] initWithFrame:frameimg];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}
#pragma mark - end
#pragma mark - Add dashboard menu bar
- (void)addDashboardMenu
{
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:@[[UIImage imageNamed:@"dashboard"], [UIImage imageNamed:@"profile"], [UIImage imageNamed:@"cars"], [UIImage imageNamed:@"payment"],[UIImage imageNamed:@"reward"]] sectionSelectedImages:@[[UIImage imageNamed:@"dashboard"], [UIImage imageNamed:@"profile"], [UIImage imageNamed:@"cars"], [UIImage imageNamed:@"payment"],[UIImage imageNamed:@"reward"]] titlesForSections:@[@"Dashboard", @"Profile", @"Car      ",@"Pay      ",@"Redemption"] ];
    
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.frame = CGRectMake(0,0, self.view.frame.size.width, 54);
    segmentedControl.selectionIndicatorHeight = 2.0f;
    segmentedControl.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    segmentedControl.selectedSegmentIndex= myDelegate.selScreenState;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
//    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        UIViewController * dashboardView = [self.storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: dashboardView]
                                             animated: NO];
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
    {
        UIViewController * profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"DriverProfileViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: profileView]
                                             animated: NO];
    }
    else  if (segmentedControl.selectedSegmentIndex == 2)
    {
        UIViewController * carListView = [self.storyboard instantiateViewControllerWithIdentifier:@"CarListiewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: carListView]
                                             animated: NO];
    }
    else if (segmentedControl.selectedSegmentIndex == 3)
    {
        UIViewController * carListView = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentHistoryViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: carListView]
                                             animated: NO];
    }
    else
    {
        UIViewController * carListView = [self.storyboard instantiateViewControllerWithIdentifier:@"RedemptionViewController"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: carListView]
                                             animated: NO];
    }
}
#pragma mark - end

#pragma mark - Add Bar button actions
- (void)notificationAction {
    
    NotificationHistoryViewController *objNotificationHistory = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"NotificationHistoryViewController"];
    objNotificationHistory.isPreviousBarButton = YES;
    
    [self.navigationController pushViewController:objNotificationHistory animated:YES];
}

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
