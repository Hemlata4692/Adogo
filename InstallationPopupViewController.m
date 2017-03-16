//
//  InstallationPopupViewController.m
//  Adogo
//
//  Created by Monika on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "InstallationPopupViewController.h"
#import "CampaignService.h"
#import "OnsiteInstallationViewController.h"
@interface InstallationPopupViewController ()<BSKeyboardControlsDelegate>
{
    NSMutableArray *textFieldArray, *installationMethodArray;
    NSString *selectedInstallationMethodStr;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UITextField *installationMethodText;
@property (strong, nonatomic) IBOutlet UIButton *installationMethodButton;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *notesTextView;
@property (strong, nonatomic) IBOutlet UITextView *setInstallationTextview;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (strong, nonatomic) IBOutlet UIImageView *bookIcon;
@end

@implementation InstallationPopupViewController
@synthesize popupContainerView,installationMethodText,installationMethodButton,notesTextView,keyboardControls,pickerView,pickerToolbar, bidId,scrollView, bookIcon, campaignId;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    installationMethodArray = [NSMutableArray new];
    textFieldArray = [NSMutableArray new];
    [textFieldArray addObject:notesTextView];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    self.setInstallationTextview.text=@"";
    //Padding
    [installationMethodText addTextFieldLeftPadding:installationMethodText];
    [notesTextView setPlaceholder:@" Notes"];
    [notesTextView setFont:[UIFont railwayRegularWithSize:15]];
    notesTextView.text = @"";
    //Text placeholder color
    installationMethodText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Select Installation Methods" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(0/255.0) green:(213/255.0) blue:(195/255.0) alpha:1.0f]}];
    
    pickerView.translatesAutoresizingMaskIntoConstraints = YES;
    pickerToolbar.translatesAutoresizingMaskIntoConstraints = YES;
    [pickerView setNeedsLayout];
    
    [popupContainerView setCornerRadius:5];
    [self removeAutolayout];
    //Call webservice
    [myDelegate showIndicator];
    [self performSelector:@selector(getInstallationType) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - end

#pragma mark - View customization
- (void)viewCustomization {
    
    self.setInstallationTextview.translatesAutoresizingMaskIntoConstraints=YES;
    self.setInstallationTextview.frame=CGRectMake(10, 59, [[UIScreen mainScreen] bounds].size.width-40, 117);
    self.setInstallationTextview.textColor=[UIColor whiteColor];
    self.setInstallationTextview.font=[UIFont railwayRegularWithSize:15];
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)installationMethodButtonClick:(id)sender
{
    [self hidePickerWithAnimation];
    [keyboardControls.activeField resignFirstResponder];
    
    if (installationMethodArray!=nil && installationMethodArray.count!=0) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [pickerView reloadAllComponents];
        [pickerView setNeedsLayout];
        
        if([[UIScreen mainScreen] bounds].size.height<568)
        {
            [scrollView setContentOffset:CGPointMake(0, popupContainerView.frame.origin.y + 30) animated:YES];
        }
        pickerView.frame = CGRectMake(pickerView.frame.origin.x, self.view.bounds.size.height-pickerView.frame.size.height , self.view.bounds.size.width, pickerView.frame.size.height);
        pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, pickerView.frame.origin.y-44, self.view.bounds.size.width, 44);
        
        [UIView commitAnimations];
    }
}

- (IBAction)submitButtonAction:(id)sender
{
    [self.view endEditing:YES];
    if([self performValidationForReasonText])
    {
        self.view.hidden=YES;
        
        myDelegate.popupText = notesTextView.text;
        [_delegate popupViewDelegateMethod:1 installationText:selectedInstallationMethodStr installationType:installationMethodText.text];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)toolbarCancelAction:(id)sender
{
    [self hidePickerWithAnimation];
}

- (IBAction)toolbarDoneAction:(id)sender
{
    [self.view endEditing:YES];
    [self hidePickerWithAnimation];
    
    if (installationMethodArray != nil)
    {
        NSInteger index = [pickerView selectedRowInComponent:0];
        installationMethodText.text = [[[installationMethodArray objectAtIndex:index] objectForKey:@"type"] capitalizedString];
        selectedInstallationMethodStr = [[installationMethodArray objectAtIndex:index] objectForKey:@"content"];
    }
}

- (IBAction)crossButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [_delegate popupViewDelegateMethod:0 installationText:@"" installationType:@""];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end

#pragma mark - View customization
- (void)removeAutolayout {
    notesTextView.translatesAutoresizingMaskIntoConstraints = YES;
    bookIcon.translatesAutoresizingMaskIntoConstraints = YES;
    [self viewCustomisation];
}

- (void)viewCustomisation {
    
    bookIcon.frame = CGRectMake(10, 265, 27, 31);
    float specialNoteHeight = [notesTextView sizeThatFits:notesTextView.frame.size].height;
    if (specialNoteHeight > 55.0) {
        specialNoteHeight = 55.0;
    }
    notesTextView.frame = CGRectMake(50, (265 + (31.0 / 2.0)) - (specialNoteHeight/2.0), self.view.bounds.size.width - 50 - 30, specialNoteHeight);
}
#pragma mark - end

#pragma mark - Textview delegates
- (void)textViewDidChange:(UITextView *)textView {
    
    [self viewCustomisation];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidePickerWithAnimation];
    [self.keyboardControls setActiveField:textView];

    if([[UIScreen mainScreen] bounds].size.height<568)
    {
        [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y-105) animated:YES];

    }
   else if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 180) animated:YES];
    }
}
#pragma mark - end

#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls
{
    
    [bskeyboardControls.activeField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark - end

#pragma mark - Picker view delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return installationMethodArray.count;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *pickerStr;
    pickerStr = [[installationMethodArray objectAtIndex:row] objectForKey:@"type"];
    return pickerStr;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width,20)];
        pickerLabel.font = [UIFont railwayRegularWithSize:14];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    NSString *pickerStr;
    pickerStr = [[[installationMethodArray objectAtIndex:row] objectForKey:@"type"] capitalizedString];
    pickerLabel.text = pickerStr;
    return pickerLabel;
}

- (void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    pickerView.frame = CGRectMake(pickerView.frame.origin.x, 1000, self.view.bounds.size.width, pickerView.frame.size.height);
    pickerToolbar.frame = CGRectMake(pickerToolbar.frame.origin.x, 1000, self.view.bounds.size.width, pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - Call webservices
- (void)getInstallationType
{
    [[CampaignService sharedManager] getInstallationType:bidId campaignId:(NSString *)campaignId success:^(id responseObject)
     {
//         NSLog(@"responseObject is %@",responseObject);
         
         if ([[[responseObject objectForKey:@"current_installation_type"] lowercaseString] containsString:[@"Pending" lowercaseString]]) {
             installationMethodArray = [[responseObject objectForKey:@"installationType"]mutableCopy];
             
             self.setInstallationTextview.text=[responseObject objectForKey:@"set_installation_note"];
             [self viewCustomization];
             
             [pickerView reloadAllComponents];
             
         }
         else {
             installationMethodArray = [[responseObject objectForKey:@"installationType"]mutableCopy];
             
             self.setInstallationTextview.text=[responseObject objectForKey:@"set_installation_note"];
             [self viewCustomization];
             
             int flag=0;
             for (int i=0; i<installationMethodArray.count; i++) {
                 
                 if ([[[[installationMethodArray objectAtIndex:i] objectForKey:@"type"] lowercaseString] containsString:[[responseObject objectForKey:@"current_installation_type"] lowercaseString]]) {
                     flag=i+1;
                 }
             }
             
             if (flag!=0) {
                 installationMethodText.text = [[[installationMethodArray objectAtIndex:flag-1] objectForKey:@"type"] capitalizedString];
                 selectedInstallationMethodStr = [[installationMethodArray objectAtIndex:flag-1] objectForKey:@"content"];
             }
             [pickerView reloadAllComponents];
         }
     }
                                                 failure:^(NSError *error) {
                                                 }];
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForReasonText
{
    if ([installationMethodText isEmpty])
    {
        [UserDefaultManager showAlertMessage:@"Please select installation method."];
        return NO;
    }
    else
    {
        return YES;
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
