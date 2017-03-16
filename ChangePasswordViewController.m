//
//  ChangePasswordViewController.m
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UserService.h"
#import "SCLAlertView.h"
@interface ChangePasswordViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *nwPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation ChangePasswordViewController
@synthesize oldPasswordField;
@synthesize nwPasswordField;
@synthesize confirmPasswordField;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"Change Password";
     NSArray * textFieldArray = @[oldPasswordField, nwPasswordField,confirmPasswordField];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    [self addTextFieldPadding];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTextFieldPadding
{
    [oldPasswordField addTextFieldLeftPadding:oldPasswordField];
    [nwPasswordField addTextFieldLeftPadding:nwPasswordField];
    [confirmPasswordField addTextFieldLeftPadding:confirmPasswordField];
}
#pragma mark -end

#pragma mark - Webservice method
- (void)changepassword
{
    [[UserService sharedManager] changePassword:oldPasswordField.text newPassword:nwPasswordField.text success:^(id responseObject)
    {
//        NSLog(@"responseObject is %@",responseObject);
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            [self goBack];
            
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
    }
failure:^(NSError *error)
    {
        
    }];
}
#pragma mark - end

#pragma mark - Perform change password submit validation
- (BOOL)performValidationForChangePassword
{
    if ([oldPasswordField isEmpty] || [nwPasswordField isEmpty]|| [confirmPasswordField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (oldPasswordField.text.length < 6)
    {
        [UserDefaultManager showAlertMessage:@"Old password length must be 6 to 15."];
        return NO;
    }
    else if (nwPasswordField.text.length < 6) {
        [UserDefaultManager showAlertMessage:@"New password length must be 6 to 15."];
        return NO;
    }
    else if (![nwPasswordField.text isEqualToString:confirmPasswordField.text])
    {
        [UserDefaultManager showAlertMessage:@"Passwords do not match."];
        return NO;
    }
    else if ([nwPasswordField.text isEqualToString:oldPasswordField.text])
    {
        [UserDefaultManager showAlertMessage:@"Old and new password cannot be same."];
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - end

#pragma mark - View acitons
- (void)goBack
{
    [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DashboardViewController"] animated:YES];
}

- (IBAction)submit:(id)sender
{
    if ([self performValidationForChangePassword])
    {
        [myDelegate showIndicator];
        [self performSelector:@selector(changepassword) withObject:nil afterDelay:.1];
    }
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
    
    if(textField == oldPasswordField)
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
    else if(textField == nwPasswordField)
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
    else if(textField == confirmPasswordField)
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
