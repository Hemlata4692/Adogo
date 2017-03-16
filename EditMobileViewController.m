//
//  EditMobileViewController.m
//  Adogo
//
//  Created by Ranosys on 05/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "EditMobileViewController.h"
#import "UserService.h"
#import "PinVerificationViewController.h"

@interface EditMobileViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate> {
    
    NSArray *textFieldArray;
}
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation EditMobileViewController
@synthesize number, numberCode, numberView, numberIcon;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
   
    self.title = @"Update Mobile Number";
    [self viewCustomization];
    textFieldArray = @[number];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    [[self navigationController] setNavigationBarHidden:NO];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"]];
}

- (void)viewCustomization {
    
    [number addTextFieldLeftMobilePadding:number];
    numberView.layer.cornerRadius = 3.0f;
    numberView.layer.masksToBounds = YES;
    number.layer.cornerRadius = 3.0f;
    number.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    number.layer.borderWidth = 1.5;
    number.layer.masksToBounds = YES;
    numberIcon.layer.masksToBounds = YES;
}

- (void)addLeftBarButtonWithImage:(UIImage *)backImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:framing];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == number)
    {
        if (range.length > 0 && [string length] == 0)
        {
            return YES;
        }
        if (textField.text.length > 7 && range.length == 0)
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
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForMobileNumber {
    
    if ([number isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please enter your mobile number."];
        return NO;
    }
    else if (number.text.length < 8) {
        [UserDefaultManager showAlertMessage:@"Mobile number should be of eight digits."];
        return NO;
    }
    else if ([number.text isEqualToString:[[[UserDefaultManager getValue:@"mobileNumber"] componentsSeparatedByString:@" "] objectAtIndex:1]]) {
        [UserDefaultManager showAlertMessage:@"This number is already verified."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)submitNumber:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if([self performValidationForMobileNumber]) {
        
        [myDelegate showIndicator];
        [self performSelector:@selector(userMobileVerification) withObject:nil afterDelay:.1];
    }
}

- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

#pragma mark - Webservices
- (void)userMobileVerification {
    
    NSString *verificationPin = [@"" generateRandomNumber];
    [[UserService sharedManager] signupVerification:[NSString stringWithFormat:@"%@%@",numberCode.text, number.text] verificationPin:(NSString *)verificationPin success:^(id responseObject) {
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PinVerificationViewController *pinView =[storyboard instantiateViewControllerWithIdentifier:@"PinVerificationView"];
        pinView.mobileNo = number.text;
        pinView.mobileCode = numberCode.text;
        pinView.isCompleteProfileScreen = true;
        pinView.verificationPin = verificationPin;
        
        [self.navigationController pushViewController:pinView animated:YES];
        
    } failure:^(NSError *error) {
        
    }] ;
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
