//
//  ForgotPasswordViewController.m
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "UserService.h"
#import "ForgotPasswordVerificationViewController.h"
@interface ForgotPasswordViewController () {
    UIBarButtonItem *barButton;
}
@property (weak, nonatomic) IBOutlet UITextField *emailId;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIButton *emailIcon;
@end

@implementation ForgotPasswordViewController
@synthesize emailId;
@synthesize emailView;
@synthesize emailIcon;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Forgot Password";
    [[self navigationController] setNavigationBarHidden:NO];
    [self addTextFieldPadding];
    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTextFieldPadding {
    [emailId addTextFieldLeftPadding:emailId];
}

- (void)viewCustomization
{
    //Add border on uiview
    emailView.layer.cornerRadius = 3.0f;
    emailView.layer.masksToBounds = YES;
    emailId.layer.cornerRadius = 3.0f;
    emailId.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    emailId.layer.borderWidth = 1.5;
    emailId.layer.masksToBounds = YES;
    emailIcon.layer.masksToBounds = YES;
    //end
}

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage
{
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton, nil];
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForForgotPassword {
    
    if ([emailId isEmpty])
    {
        [UserDefaultManager showAlertMessage:@"Please enter email address."];
        return NO;
    }
    else if (![emailId isValidEmail])
    {
        [UserDefaultManager showAlertMessage:@"Invalid email address."];
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender
{
    [self.view endEditing: YES];
    if([self performValidationForForgotPassword])
    {
        [myDelegate showIndicator];
        [self performSelector:@selector(forgotPasswordSendPin) withObject:nil afterDelay:.1];
    }
}
#pragma mark - end

#pragma mark - Textfield delegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Forgot password service
- (void)forgotPasswordSendPin {
    
    NSString *verificationPin =  [@"" generateRandomNumber];;
    [[UserService sharedManager] forgotPasswordVerification:emailId.text pin:verificationPin success:^(id responseObject)
     {
         if ([[responseObject objectForKey:@"status"]intValue]==400 && !([[responseObject objectForKey:@"message"] isEqualToString:@"Message sending got failed. Please try again."]))
         {
             [UserDefaultManager showAlertMessage:[responseObject objectForKey:@"message"]];
         }
         else
         {
             ForgotPasswordVerificationViewController *objPinVerification = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPasswordVerificationViewController"];
             objPinVerification.verificationPin = verificationPin;
             objPinVerification.emailId = emailId.text;
             objPinVerification.mobileNumber = [responseObject objectForKey:@"phone_number"];
             [self.navigationController pushViewController:objPinVerification animated:YES];
         }
     }
                                                    failure:^(NSError *error)
     {
         
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
