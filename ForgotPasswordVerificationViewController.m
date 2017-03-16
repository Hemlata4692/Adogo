//
//  ForgotPasswordVerificationViewController.m
//  Adogo
//
//  Created by Sumit on 27/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "ForgotPasswordVerificationViewController.h"
#import "UserService.h"
#import "ResetPasswordViewController.h"
#import "SCLAlertView.h"
@interface ForgotPasswordVerificationViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate> {
    
    NSArray *textFieldArray;
    int counter;
    NSTimer *timer;
    int second, minute, hour, continousSecond;
    UIBarButtonItem *barButton;
     bool isValidPin;
}
@property (strong, nonatomic) IBOutlet UILabel *smsLabel;

@property (strong, nonatomic) IBOutlet UIView *pinView;
@property (strong, nonatomic) IBOutlet UITextField *pin1Field;
@property (strong, nonatomic) IBOutlet UITextField *pin2Field;
@property (strong, nonatomic) IBOutlet UITextField *pin3Field;
@property (strong, nonatomic) IBOutlet UITextField *pin4Field;
@property (strong, nonatomic) IBOutlet UITextField *pin5Field;

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *requestAgainBtn;
@property (strong, nonatomic) IBOutlet UIButton *confirmationCallBtn;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) IBOutlet UILabel *supportLabel;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation ForgotPasswordVerificationViewController
@synthesize emailId;
@synthesize verificationPin, mobileNumber;
@synthesize smsLabel, timerLabel, requestAgainBtn, confirmationCallBtn, confirmBtn, supportLabel,keyboardControls;
@synthesize pinView, pin1Field, pin2Field, pin3Field, pin4Field, pin5Field;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Forgot Password";
    counter = 1;
    timerLabel.hidden = NO;
    timerLabel.text = @"Please wait for 3:00 to request a new code"; //set first time label in timerLabel
    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    textFieldArray = @[pin1Field, pin2Field, pin3Field, pin4Field, pin5Field];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    isValidPin = true;
    continousSecond = 3 * 60;   //time limit
    
    //start timer
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(startCounter)
                                             userInfo:nil
                                            repeats:YES];
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

#pragma mark - UIView customization
- (void)viewCustomization {
    
    //Add border and set background color in view
    pinView.layer.cornerRadius = 3.0f;
    pinView.layer.masksToBounds = YES;
    pinView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pinView.layer.borderWidth = 1.5f;
    
    confirmationCallBtn.layer.cornerRadius = 3.0f;
    confirmationCallBtn.layer.masksToBounds = YES;
    
    requestAgainBtn.layer.cornerRadius = 3.0f;
    requestAgainBtn.layer.masksToBounds = YES;
    requestAgainBtn.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    requestAgainBtn.layer.borderWidth = 1.5f;
    requestAgainBtn.enabled = NO;
    [requestAgainBtn setTitleColor:[UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
    
    confirmBtn.enabled = NO;
    
    pin1Field.layer.borderColor = pin2Field.layer.borderColor = pin3Field.layer.borderColor = pin4Field.layer.borderColor = pin5Field.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    pin1Field.layer.borderWidth = pin2Field.layer.borderWidth = pin3Field.layer.borderWidth = pin4Field.layer.borderWidth = pin5Field.layer.borderWidth = 1.5f;
    //end
    
    confirmationCallBtn.hidden = YES;
    supportLabel.hidden = YES;
    
    //Set attributed string
    supportLabel.attributedText = [supportLabel.text setAttributrdString:@"@68718710" stringFont:[UIFont systemFontOfSize:12.0 weight:12.0] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
    smsLabel.attributedText = [smsLabel.text setAttributrdString:@"SMS" stringFont:[UIFont systemFontOfSize:22.0 weight:12.0] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
    timerLabel.attributedText = [timerLabel.text setAttributrdString:@"3:00" stringFont:[UIFont systemFontOfSize:14.0 weight:12.0] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
    //end
    
        //Add action on textfields
    [pin1Field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [pin2Field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [pin3Field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [pin4Field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [pin5Field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //end
}
#pragma mark - end

#pragma mark - UIView actions
- (void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmationCall:(UIButton *)sender
{
        [myDelegate showIndicator];
        [self performSelector:@selector(getVoiceCall) withObject:nil afterDelay:.1];
}

- (NSString *)verificationPinSeparation:(NSString*)originalString {
    
    NSMutableString *resultString = [NSMutableString string];
    for(int i = 0; i<[originalString length]/1; i++)
    {
        NSUInteger fromIndex = i * 1;
        NSUInteger len = [originalString length] - fromIndex;
        if (len > 1) {
            len = 1;
        }
        [resultString appendFormat:@"%@. ",[originalString substringWithRange:NSMakeRange(fromIndex, len)]];
    }
    return resultString;
}

- (void)getVoiceCall {
    
    NSString * pin = [NSString new];
    
    for (int i=0; i<10; i++)
    {
        pin = [pin stringByAppendingString:[NSString stringWithFormat:@"Your Ah Doh Go Code is %@ Thank you.",[self verificationPinSeparation:verificationPin]]];
        
    }
    
    NSString *Url_str=[NSString stringWithFormat:@"https://secure.hoiio.com/open/ivr/start/dial?dest=%@&caller_id=private&access_token=3UhvNXxMkY6xgKrA&app_id=rg3zoG4ScVaGbKEw&msg=%@",mobileNumber,pin];
    NSURL * url = [[NSURL alloc] initWithString:[Url_str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
     [UserService getVoiceCallService:url];
    confirmationCallBtn.enabled = NO;
    [confirmationCallBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)invalidatePin
{
    [timer invalidate];
    isValidPin = false;
}

- (IBAction)requestAgain:(UIButton *)sender {
    
    verificationPin = [@"" generateRandomNumber];;
    counter++;
    timerLabel.hidden = NO;
    timerLabel.attributedText = [@"Please wait for 3:00 to request a new code" setAttributrdString:@"3:00" stringFont:[UIFont systemFontOfSize:14.0 weight:12.0] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
    
        requestAgainBtn.layer.cornerRadius = 3.0f;
    requestAgainBtn.layer.masksToBounds = YES;
    requestAgainBtn.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    requestAgainBtn.layer.borderWidth = 1.5f;
    requestAgainBtn.enabled = NO;
    [requestAgainBtn setTitleColor:[UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
    [myDelegate showIndicator];
    [self performSelector:@selector(forgotPasswordSendPin) withObject:nil afterDelay:.1];
}

- (void)forgotPasswordSendPin {
    
    [[UserService sharedManager] forgotPasswordVerification:emailId pin:verificationPin success:^(id responseObject) {
//         NSLog(@"success message!!");
        
        isValidPin = true;
        continousSecond = 3 * 60;   //time limit
        //start timer
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(startCounter)
                                                 userInfo:nil
                                                  repeats:YES];
     }
    failure:^(NSError *error) {
         
   }];
}

- (IBAction)confirm:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if ([verificationPin isEqualToString:[NSString stringWithFormat:@"%@%@%@%@%@", pin1Field.text,pin2Field.text,pin3Field.text,pin4Field.text,pin5Field.text]]) {
        
        if (isValidPin) {
            ResetPasswordViewController * objRestPwd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetPasswordViewController"];
            objRestPwd.mailId = emailId;
            [self.navigationController pushViewController:objRestPwd animated:YES];
        }
        else {
            
            [UserDefaultManager showAlertMessage:@"Verification Code has been expired."];
        }
    }
    else {
        [UserDefaultManager showAlertMessage:@"Verification Code is incorrect."];
    }
}
#pragma mark - end

#pragma mark - Textfield delegates
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length > 0 && [string length] == 0)
    {
        return YES;
    }
    if (textField.text.length > 0 && range.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)textFieldDidChange :(UITextField *)theTextField {
    
    if ([pin1Field isEmpty] || [pin2Field isEmpty] || [pin3Field isEmpty] || [pin4Field isEmpty] || [pin5Field isEmpty]) {
        confirmBtn.enabled = NO;
    }
    else {
        confirmBtn.enabled = YES;
    }
    
    if (theTextField == pin1Field) {
        if ([pin1Field isEmpty]) {
            [pin1Field resignFirstResponder];
        }
        else if (![pin1Field isEmpty]) {
            [pin1Field resignFirstResponder];
            [pin2Field becomeFirstResponder];
        }
    }
    else if (theTextField == pin2Field) {
        if ([pin2Field isEmpty]) {
            [pin2Field resignFirstResponder];
            [pin1Field becomeFirstResponder];
        }
        else if (![pin2Field isEmpty]) {
            [pin2Field resignFirstResponder];
            [pin3Field becomeFirstResponder];
        }
    }
    else if (theTextField == pin3Field) {
        if ([pin3Field isEmpty]) {
            [pin3Field resignFirstResponder];
            [pin2Field becomeFirstResponder];
        }
        else if (![pin3Field isEmpty]) {
            [pin3Field resignFirstResponder];
            [pin4Field becomeFirstResponder];
        }
    }
    else if (theTextField == pin4Field) {
        if ([pin4Field isEmpty]) {
            [pin4Field resignFirstResponder];
            [pin3Field becomeFirstResponder];
        }
        else if (![pin4Field isEmpty]) {
            [pin4Field resignFirstResponder];
            [pin5Field becomeFirstResponder];
        }
    }
    else if (theTextField == pin5Field) {
        if ([pin5Field isEmpty]) {
            [pin5Field resignFirstResponder];
            [pin4Field becomeFirstResponder];
        }
        else if (![pin5Field isEmpty]) {
            [pin5Field resignFirstResponder];
        }
    }
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

#pragma mark - Set timer
- (void)startCounter {
    
    continousSecond--;
    minute = (continousSecond / 60) % 60;
    second = (continousSecond  % 60);
    timerLabel.attributedText = [[NSString stringWithFormat:@"Please wait for %d:%02d to request a new code", minute, second] setAttributrdString:[NSString stringWithFormat:@"%d:%02d", minute, second] stringFont:[UIFont systemFontOfSize:14.0 weight:12.0] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
    if ([[NSString stringWithFormat:@"%d:%02d", minute, second] isEqualToString:@"0:00"]) {
        
        [timer invalidate];
        timer = nil;
        isValidPin = false;
        timerLabel.hidden = YES;
        if (counter < 3) {
            
            requestAgainBtn.layer.cornerRadius = 3.0f;
            requestAgainBtn.layer.masksToBounds = YES;
            requestAgainBtn.layer.borderColor = [UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f].CGColor;
            [requestAgainBtn setTitleColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
            requestAgainBtn.layer.borderWidth = 1.5f;
            requestAgainBtn.enabled = YES;
        }
        else {
            
            confirmationCallBtn.hidden = NO;
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
