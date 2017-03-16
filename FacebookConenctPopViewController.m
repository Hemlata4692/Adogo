//
//  FacebookConenctPopViewController.m
//  Adogo
//
//  Created by Ranosys on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "FacebookConenctPopViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CampaignService.h"
#import "FacebookConnect.h"

@interface FacebookConenctPopViewController ()<FacebookDelegate> {

    NSString *facebookId;
}

@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UILabel *popupTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *facebookConnect;
@property (strong, nonatomic) IBOutlet UILabel *facebookConnectText;

@property (strong, nonatomic) NSString *fbAccessToken;
@end

@implementation FacebookConenctPopViewController
@synthesize popupTitle, popupContainerView, popupTitleLabel;
@synthesize fbAccessToken;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    popupTitleLabel.text=popupTitle;
    _facebookConnectText.text = @"Please connect your facebook account to view this bid. \n\n To connect your Facebook account, please tap the blue button below.";
    [self setBorderAndCornerRadius];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    facebookId = @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View border and corner radius
- (void)setBorderAndCornerRadius {
    
    [popupContainerView setCornerRadius:5];
    [_cancelBtn add3DEffect:[UIColor colorWithRed:(43.0f/255.0f) green:(151.0f/255.0f) blue:(145.0f/255.0f) alpha:1.0]];
    [_facebookConnect add3DEffect:[UIColor colorWithRed:(53.0f/255.0f) green:(76.0f/255.0f) blue:(135.0f/255.0f) alpha:1.0]];
    _facebookConnect.layer.cornerRadius = 0.0;
    _cancelBtn.layer.cornerRadius = 0.0;
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)okButtonAction:(id)sender {
    
    FacebookConnect *fbConnectObject = [[FacebookConnect alloc]init];
    fbConnectObject.delegate = self;
    [fbConnectObject facebookLoginWithReadPermission:self];
}

- (IBAction)crossButtonAction:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate facebookConenctPopupViewDelegateMethod:0];
}
#pragma mark - end

#pragma mark - Call webservices
- (void)facebookConnectService {
    
    [[CampaignService sharedManager] facebookConnectService:facebookId success:^(id responseObject) {
        [UserDefaultManager setValue:@"1" key:@"isFacebookConnected"];
        [_delegate facebookConenctPopupViewDelegateMethod:1];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
                                               failure:^(NSError *error) {
                                                   
                                               }];
}
#pragma mark - end

#pragma mark - FacebookConnect delegates
- (void) facebookLoginWithReadPermissionResponse:(id)fbResult status:(int)status {
    
    if (status == 1) {
        facebookId=[fbResult objectForKey:@"id"];
        [self performSelector:@selector(facebookConnectService) withObject:nil afterDelay:.1];
    }
    else if(status != 3) {
        [UserDefaultManager showAlertMessage:@"A temporary error occurred, please try again later."];
    }
}
#pragma mark - end
/*ð
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
