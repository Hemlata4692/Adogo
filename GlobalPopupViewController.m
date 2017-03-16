//
//  GlobalPopupViewController.m
//  Adogo
//
//  Created by Monika on 11/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "GlobalPopupViewController.h"
#import "CarService.h"
#import "CarListiewController.h"
@interface GlobalPopupViewController ()<BSKeyboardControlsDelegate>
{
    NSMutableArray *textFieldArray;
}
@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UILabel *popupTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *popupSubTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *reasonTextView;
@property (strong, nonatomic) IBOutlet UILabel *reasonLabel;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation GlobalPopupViewController
@synthesize popupContainerView,popupTitleLabel,popupSubTitleLabel,reasonTextView,popupTitle,keyboardControls, reasonLabel, isAppSetting, trackingMethod,reasonPrifillText;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    reasonLabel.text = @"Reason (max. 100 chars)";
    if (isAppSetting) {
        reasonLabel.text = trackingMethod;
        reasonTextView.text = reasonPrifillText;
    }
    popupTitleLabel.text=popupTitle;
    [self setBorderAndornerRadius];
    textFieldArray = [NSMutableArray new];
    [textFieldArray addObject:reasonTextView];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View border and corner radius
- (void)setBorderAndornerRadius
{
    [popupContainerView setCornerRadius:5];
    [reasonTextView setCornerRadius:5];
    [reasonTextView setViewBorder:reasonTextView color:[UIColor colorWithRed:(153/255.0) green:(155/255.0) blue:(164/255.0) alpha:0.5f]];
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)okButtonAction:(id)sender
{
    if([self performValidationForReasonText])
    {
        if (isAppSetting) {
            if ([reasonLabel.text isEqualToString:@"Serial Number"]) {
                [_delegate popupViewDelegateMethod:2 reasonText:reasonTextView.text];
            }
            else {
                [_delegate popupViewDelegateMethod:3 reasonText:reasonTextView.text];
            }
        }
        else {
        
            [_delegate popupViewDelegateMethod:1 reasonText:reasonTextView.text];
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)crossButtonAction:(id)sender
{
    [_delegate popupViewDelegateMethod:0 reasonText:@""];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - end

#pragma mark - Textview delegates
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
}
#pragma mark - end

#pragma mark - Keyboard controls delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if(textView == reasonTextView)
    {
        if (range.length > 0 && [text length] == 0)
        {
            return YES;
        }
        if (isAppSetting) {
            if (textView.text.length > 19 && range.length == 0)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else {
            if (textView.text.length > 100 && range.length == 0)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    return YES;
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls
{
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForReasonText
{
    
    if ([reasonTextView isEmpty])
    {
        if (isAppSetting) {
            
            if ([reasonLabel.text isEqualToString:@"Serial Number"]) {
                [UserDefaultManager showAlertMessage:@"Please enter iBeacon serial number."];
            }
            else {
                [UserDefaultManager showAlertMessage:@"Please enter GPS IMEI number."];
            }
        }
        else {
        
            [UserDefaultManager showAlertMessage:@"Please enter the reason."];
        }
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - end
@end
