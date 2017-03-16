//
//  ViewController.m
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RegistrationViewControllerStepOne.h"
#import "UserService.h"
#import "ExploreViewController.h"
#import "FacebookConnect.h"

@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate,FacebookDelegate> {
    
    NSArray *textFieldArray;
    BOOL isFbLogin;
    UITextField *currentTextField;
    NSString *fbEmailId, *fbName;
}

@property (weak, nonatomic) IBOutlet UILabel *versionLbl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *tabView;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@property (strong, nonatomic) IBOutlet UIView *emailView;
@property (strong, nonatomic) IBOutlet UIButton *emailIcon;
@property (strong, nonatomic) IBOutlet UITextField *emailId;

@property (strong, nonatomic) IBOutlet UIView *passwordView;
@property (strong, nonatomic) IBOutlet UIButton *passwordIcon;
@property (strong, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) IBOutlet UIButton *loginWithFacebookOutlet;
@property (strong, nonatomic) IBOutlet UIButton *guestOutlet;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) NSString *fbAccessToken;
@end

@implementation LoginViewController
@synthesize scrollView, mainView, tabView, loginView, loginWithFacebookOutlet, guestOutlet;
@synthesize emailView, emailIcon, emailId, passwordView, passwordIcon, password;
@synthesize keyboardControls, fbAccessToken;
@synthesize faceBookId, loginName, loginEmailId, facebookImageUrl, mobileNo, mobileCode, passwordString, termsConditionSelected,versionLbl;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [myDelegate registerDeviceForNotification];
    //versionLbl.text = [NSString stringWithFormat:@"Beta build %@",[self build]];
    versionLbl.text = @"";
    [self addTextFieldPadding];
    [self viewCustomization];
    isFbLogin = NO;
    faceBookId = @"";
    facebookImageUrl = @"";
    fbName = @"";
    fbEmailId = @"";
    loginName = @"";
    loginEmailId = @"";
    mobileNo = @"";
    mobileCode = @"";
    passwordString = @"";
    termsConditionSelected = NO;
    //NSLog(@"mail id is %@",[UserDefaultManager getValue:@"emailId"]);
    emailId.text = [UserDefaultManager getValue:@"emailId"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    textFieldArray = @[emailId, password];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UIView customization
- (void)viewCustomization {
    
    if ([[UIScreen mainScreen] bounds].size.height > 580) {
        scrollView.scrollEnabled = NO;
    }
    //Add border on uiview
    tabView.layer.cornerRadius = 3.0f;
    tabView.layer.masksToBounds = YES;
    
    emailView.layer.cornerRadius = 3.0f;
    emailView.layer.masksToBounds = YES;
    emailId.layer.cornerRadius = 3.0f;
    emailId.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    emailId.layer.borderWidth = 1.5;
    emailId.layer.masksToBounds = YES;
    emailIcon.layer.masksToBounds = YES;
    
    passwordView.layer.cornerRadius = 3.0f;
    passwordView.layer.masksToBounds = YES;
    password.layer.cornerRadius = 3.0f;
    password.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    password.layer.borderWidth = 1.5;
    password.layer.masksToBounds = YES;
    passwordIcon.layer.masksToBounds = YES;
    
    loginWithFacebookOutlet.layer.cornerRadius = 3.0f;
    loginWithFacebookOutlet.layer.masksToBounds = YES;
    
    guestOutlet.layer.cornerRadius = 3.0f;
    guestOutlet.layer.masksToBounds = YES;
    guestOutlet.layer.borderColor = [UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f].CGColor;
    guestOutlet.layer.borderWidth = 1.5f;
    //end
}

- (void)addTextFieldPadding {
    
    [emailId addTextFieldLeftPadding:emailId];
    [password addTextFieldLeftPadding:password];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + 80) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //NSLog(@"return");
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == password)
    {
        if (range.length > 0 && [string length] == 0)
        {
            return YES;
        }
        if (textField.text.length > 14 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
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
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForLogin {
    
    if ([emailId isEmpty] || [password isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (![emailId isValidEmail]) {
        [UserDefaultManager showAlertMessage:@"Invalid email address."];
        return NO;
    }
    else if (password.text.length < 6) {
        [UserDefaultManager showAlertMessage:@"Password length must be 6 to 15."];
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)performValidationForLoginWithFB {
    
    if ([fbEmailId isEqualToString:@""] || fbEmailId.length == 0) {
        [myDelegate stopIndicator];
        [UserDefaultManager showAlertMessage:@"Error in fetching FB Email Address. Please go to Privacy Settings in App Setting on Facebook, and edit the settings to allow email address to be seen."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)signUpTapClick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegistrationViewControllerStepOne *signUpView =[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
    
    if (!myDelegate.isLogout) {
        
        signUpView.signUpName = loginName;
        signUpView.signUpEmailId = loginEmailId;
        signUpView.faceBookId = faceBookId;
        signUpView.facebookImageUrl = facebookImageUrl;
        signUpView.mobileNo = mobileNo;
        signUpView.mobileCode = mobileCode;
        signUpView.passwordString = passwordString;
        signUpView.termsConditionSelected = termsConditionSelected;
        signUpView.loginViewObj = self;
        [self.navigationController popViewControllerAnimated:NO];
    }
    else {
        signUpView.signUpName = loginName;
        signUpView.signUpEmailId = loginEmailId;
        signUpView.faceBookId = faceBookId;
        signUpView.facebookImageUrl = facebookImageUrl;
        signUpView.mobileNo = mobileNo;
        signUpView.mobileCode = mobileCode;
        signUpView.passwordString = passwordString;
        signUpView.termsConditionSelected = termsConditionSelected;
        signUpView.loginViewObj = self;
        [self.navigationController pushViewController:signUpView animated:NO];
    }
}

- (IBAction)guest:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    ExploreViewController * objExploreView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ExploreViewController"];
    objExploreView.isAsGuest=YES;
    [self.navigationController pushViewController:objExploreView animated:YES];
}

- (IBAction)loginWithFacebook:(UIButton *)sender {
    
    [self.view endEditing:YES];
    isFbLogin = YES;
    
    FacebookConnect *fbConnectObject = [[FacebookConnect alloc]init];
    fbConnectObject.delegate = self;
    [fbConnectObject facebookLoginWithReadPermission:self];
}

- (IBAction)login:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    isFbLogin = NO;
    
    if([self performValidationForLogin]) {
        faceBookId = @"";
        facebookImageUrl = @"";
        fbName = @"";
        fbEmailId = emailId.text;
        [myDelegate showIndicator];
        [self performSelector:@selector(userLogin) withObject:nil afterDelay:.1];
    }
}

- (IBAction)forgotPassword:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    UIViewController * objForgotPwdView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    [self.navigationController pushViewController:objForgotPwdView animated:YES];
}
#pragma mark - end

#pragma mark - Webservice
- (void)userLogin {
    
    [[UserService sharedManager] userLogin:fbEmailId facebookId:faceBookId password:password.text deviceToken:[UserDefaultManager getValue:@"DeviceToken"] isLoginFacebook:isFbLogin success:^(id responseObject)
     {
         if ([[responseObject objectForKey:@"type"] isEqualToString:@"O"]||[responseObject objectForKey:@"type"]==nil||[responseObject objectForKey:@"type"]==NULL) {
             
             if(isFbLogin && [responseObject[@"status"] intValue] == 400 && ![responseObject[@"isExist"] boolValue]) {
                 [self.view endEditing:YES];
                 [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                 UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 RegistrationViewControllerStepOne *signUpView =[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
                 signUpView.signUpName = fbName;
                 signUpView.signUpEmailId = fbEmailId;
                 signUpView.faceBookId = faceBookId;
                 signUpView.facebookImageUrl = facebookImageUrl;
                 signUpView.mobileNo = mobileNo;
                 signUpView.mobileCode = mobileCode;
                 signUpView.passwordString = passwordString;
                 signUpView.termsConditionSelected = termsConditionSelected;
                 signUpView.loginViewObj = self;
                 myDelegate.alertCount = 0;
                 [self.navigationController pushViewController:signUpView animated:NO];
             }
             else if([responseObject[@"status"] intValue] == 200) {
                 
                 [UserDefaultManager setValue:emailId.text key:@"emailId"];
                 //NSLog(@"mail id is %@",[UserDefaultManager getValue:@"emailId"]);
                 [UserDefaultManager setValue:[responseObject objectForKey:@"name"] key:@"userName"];
                 [UserDefaultManager setValue:[responseObject objectForKey:@"access-token"] key:@"accessToken"];
                 
                 if ([[responseObject objectForKey:@"mobilenumber"] containsString:@"+91"]) {
                     [UserDefaultManager setValue:[NSString stringWithFormat:@"+91 %@", [[[responseObject objectForKey:@"mobilenumber"] componentsSeparatedByString:@"+91"] objectAtIndex:1]] key:@"mobileNumber"];
                 }
                 else {
                     [UserDefaultManager setValue:[NSString stringWithFormat:@"+65 %@", [[[responseObject objectForKey:@"mobilenumber"] componentsSeparatedByString:@"+65"] objectAtIndex:1]] key:@"mobileNumber"];
                 }
                 
                 NSArray *imageNameSeparation = [[responseObject objectForKey:@"profileimageurl"] componentsSeparatedByString:@"/"];
                 NSString *imageName = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
                 
                 if (![imageName isEqualToString:@""] && imageName != nil) {
                     
                     [UserDefaultManager setValue:[responseObject objectForKey:@"profileimageurl"] key:@"profileImageUrl"];
                 }
                 else {
                     
                     if (![[responseObject objectForKey:@"facebook_image_url"] isEqualToString:@""]) {
                         
                         [UserDefaultManager setValue:[responseObject objectForKey:@"facebook_image_url"] key:@"profileImageUrl"];
                     }
                 }
                 [UserDefaultManager setValue:[responseObject objectForKey:@"isFacebookConnected"] key:@"isFacebookConnected"];
                 //            end
                 [UserDefaultManager setValue:[responseObject objectForKey:@"user_id"] key:@"userId"];
                 [UserDefaultManager setValue:[responseObject objectForKey:@"driverProfileStatus"] key:@"profileStatus"];
                 if([[responseObject objectForKey:@"driverProfileStatus"] intValue] == 3){
                     [UserDefaultManager setValue:@"False" key:@"isDriverProfileCompleted"];
                 }
                 else {
                     [UserDefaultManager setValue:@"True" key:@"isDriverProfileCompleted"];
                 }
                 
                 [UserDefaultManager setValue:[responseObject objectForKey:@"nric"] key:@"icNumber"];
                 //NSLog(@"%@",[UserDefaultManager getValue:@"profileImageUrl"]);
                 
                 [UserDefaultManager setValue:[responseObject objectForKey:@"aws_access_key"] key:@"AccessKey"];
                 [UserDefaultManager setValue:[responseObject objectForKey:@"aws_secret_key"] key:@"Secretkey"];
                 [UserDefaultManager setValue:[responseObject objectForKey:@"bucket_name"] key:@"BucketName"];
//                 UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                 UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
//                 myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//                 [myDelegate.window setRootViewController:objReveal];
//                 [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
//                 [myDelegate.window makeKeyAndVisible];
                 UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                 [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                                      animated: NO];
             }
             else
             {
                 [UserDefaultManager showAlertMessage:@"Either user does not exist or deleted."];
             }
         }
         else
         {
             [UserDefaultManager showAlertMessage:@"Either user does not exist or deleted."];
         }
     } failure:^(NSError *error) {
         
         //NSLog(@"log");
     }] ;
    
}
#pragma mark - end

#pragma mark - FacebookConnect delegates
- (void) facebookLoginWithReadPermissionResponse:(id)fbResult status:(int)status {
    
    if (status == 1) {
        
        fbEmailId = [fbResult objectForKey:@"email"];
        emailId.text =fbEmailId;
        faceBookId=[fbResult objectForKey:@"id"];
        facebookImageUrl = [[[fbResult objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        fbName = [fbResult objectForKey:@"name"];
        if([self performValidationForLoginWithFB]) {
            [self performSelector:@selector(userLogin) withObject:nil afterDelay:.1];
        }
    }
    else if(status != 3) {
        
        [UserDefaultManager showAlertMessage:@"A temporary error occurred, please try again later."];
    }
}
#pragma mark - end
@end
