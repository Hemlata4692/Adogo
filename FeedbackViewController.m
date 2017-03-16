//
//  FeedbackViewController.m
//  Adogo
//
//  Created by Monika on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "FeedbackViewController.h"
#import "ASStarRatingView.h"
#import "EDStarRating.h"
#import "LBorderView.h"
#import "UserService.h"
#import "SCLAlertView.h"
#import "DashboardViewController.h"

@interface FeedbackViewController ()<BSKeyboardControlsDelegate,EDStarRatingProtocol>
{
    NSMutableArray *textFieldArray;
    NSString* starRating;
}
@property (strong, nonatomic) IBOutlet LBorderView *starBorderView;
@property (strong, nonatomic) IBOutlet EDStarRating *ratingView;
@property (strong, nonatomic) IBOutlet UITextView *remarkTextView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation FeedbackViewController
@synthesize ratingView,remarkTextView,keyboardControls,starBorderView;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Feedback";
    [[self navigationController] setNavigationBarHidden:NO];

    [self setBorderAndornerRadius];
    
    //BSKeyboard
    textFieldArray = [NSMutableArray new];
    [textFieldArray addObject:remarkTextView];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    //RatingView
    ratingView.starImage = [UIImage imageNamed:@"star_gray.png"];
    ratingView.starHighlightedImage = [UIImage imageNamed:@"star.png"];
    ratingView.maxRating = 5.0;
    ratingView.delegate = self;
    ratingView.horizontalMargin = 5;
    ratingView.editable=YES;
    ratingView.rating= 0;
    ratingView.displayMode=EDStarRatingDisplayFull;
    [self starsSelectionChanged:ratingView rating:0];
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
    [remarkTextView setCornerRadius:5];
    [remarkTextView setCornerRadius:5];
    [remarkTextView setViewBorder:remarkTextView color:[UIColor whiteColor]];
    //Star view border
    starBorderView.borderType = BorderTypeDashed;
    starBorderView.dashPattern = 2;
    starBorderView.spacePattern = 2;
    starBorderView.borderWidth = 0.5;
    starBorderView.cornerRadius = 3;
    starBorderView.borderColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5f];
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)submitButtonAction:(id)sender
{
    if([self performValidationForReasonText])
    {
        [myDelegate showIndicator];
        [self performSelector:@selector(feedbackService) withObject:nil afterDelay:.1];
    }
}

- (void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    NSString *ratingString = [NSString stringWithFormat:@"%.1f", rating];
    starRating = ratingString;
//    NSLog(@"starRating %@",starRating);
}
#pragma mark - end

#pragma mark - Textview delegates
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    
    if([[UIScreen mainScreen] bounds].size.height < 568)
    {
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-120, self.view.frame.size.width, self.view.frame.size.height);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 568)
    {
          self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-64, self.view.frame.size.width, self.view.frame.size.height);
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
    
    if([[UIScreen mainScreen] bounds].size.height < 568)
    {
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+120, self.view.frame.size.width, self.view.frame.size.height);
    }
    else
    if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+64, self.view.frame.size.width, self.view.frame.size.height);
    }
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForReasonText
{
    if ([starRating intValue] == 0) {
        [UserDefaultManager showAlertMessage:@"Please provide the star rating."];
        return NO;
    }
    else if ([remarkTextView isEmpty])
    {
        [UserDefaultManager showAlertMessage:@"Please enter the remarks."];
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - end

#pragma mark - Webservice
- (void)feedbackService {
    
    [[UserService sharedManager] submitFeedbackservice:starRating feedback:remarkTextView.text success:^(id responseObject) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DashboardViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
            [self.navigationController pushViewController:dashboard animated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];

        
    } failure:^(NSError *error) {
        
//        NSLog(@"log");
    }] ;
}
#pragma mark - end
@end
