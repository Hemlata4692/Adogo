//
//  ExploreViewController.m
//  Adogo
//
//  Created by Sumit on 02/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "ExploreViewController.h"
#import "RegistrationViewControllerStepOne.h"

@interface ExploreViewController ()<UIGestureRecognizerDelegate>
{
    NSArray *tourData;
    int pageCounter;
    UIBarButtonItem *barButton;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (strong, nonatomic) IBOutlet UIButton *finishBtn;
@property (strong, nonatomic) IBOutlet UIButton *skipBtn;
@end

@implementation ExploreViewController
@synthesize imageView;
@synthesize pageController;
@synthesize titleLabel, descriptionLabel, finishBtn, skipBtn;
@synthesize isAsGuest;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Tour App";
    tourData = @[@{@"title":@"Dashboard", @"description": @"Easy to see essential data here", @"imageName": @"tourDashboard"},
                 @{@"title":@"User Profile", @"description": @"Create your own profile", @"imageName": @"user_profile"},
                 @{@"title":@"Car Profile", @"description": @"Create multiple car profiles under one user", @"imageName": @"car_profile"},
                 @{@"title":@"Bid", @"description": @"Select an ad and bid", @"imageName": @"bid"},
                  @{@"title":@"Route Tracking", @"description": @"Track your route to get more ads", @"imageName": @"car_rules"},
                 @{@"title":@"Campaign Summary", @"description": @"Be a part of serveral campaigns", @"imageName": @"summery"}];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    pageController.numberOfPages = [tourData count];
    pageCounter = 0;
    pageController.currentPage = pageCounter;
    pageController.pageIndicatorTintColor = [UIColor colorWithRed:0.0/255.0 green:153.0/255.0 blue:135.0/255.0 alpha:1.0];
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    imageView.userInteractionEnabled = YES;
    titleLabel.text = [[tourData objectAtIndex:pageCounter] objectForKey:@"title"];
    descriptionLabel.text = [self setDynamicLabelText:[[tourData objectAtIndex:pageCounter] objectForKey:@"description"]];
    imageView.image = [UIImage imageNamed:[[tourData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
    //Swipe gesture to swipe images to left
    UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeIntroImageLeft)];
    swipeImageLeft.delegate=self;
    UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeIntroImageRight)];
    swipeImageRight.delegate=self;
    
    // Setting the swipe direction.
    [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
    // Adding the swipe gesture on image view
    [[self view] addGestureRecognizer:swipeImageLeft];
    [[self view] addGestureRecognizer:swipeImageRight];
    //Set image at first time on finish button
    [finishBtn setTitle:@"" forState:UIControlStateNormal];
    [finishBtn setTitle:@"" forState:UIControlStateSelected];
    [finishBtn setTitle:@"" forState:UIControlStateHighlighted];
    [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateNormal];
    [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateSelected];
    [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateHighlighted];
    //end
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Swipe Images
//Adding left animation to banner images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
}

//Adding right animation to banner images
- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
}

//Swipe images in left direction
- (void)swipeIntroImageLeft {
    
    pageCounter++;
    if (pageCounter < tourData.count) {
        
        pageController.currentPage = pageCounter;
        imageView.image = [UIImage imageNamed:[[tourData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
        titleLabel.text = [[tourData objectAtIndex:pageCounter] objectForKey:@"title"];
        descriptionLabel.text = [self setDynamicLabelText:[[tourData objectAtIndex:pageCounter] objectForKey:@"description"]];
        UIImageView *moveIMageView = imageView;
        [self addLeftAnimationPresentToView:moveIMageView];
        
        if (pageCounter == tourData.count - 1) {
            skipBtn.hidden = YES;
            [finishBtn setTitle:@"FINISH" forState:UIControlStateNormal];
            [finishBtn setTitle:@"FINISH" forState:UIControlStateSelected];
            [finishBtn setTitle:@"FINISH" forState:UIControlStateHighlighted];
            [finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
            [finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        }
    }
    else {
        
        pageCounter = (int)tourData.count - 1;
    }
}

//Swipe images in right direction
- (void)swipeIntroImageRight {
    
    pageCounter--;
    if (pageCounter>=0) {
        pageController.currentPage = pageCounter;
        imageView.image = [UIImage imageNamed:[[tourData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
        titleLabel.text = [[tourData objectAtIndex:pageCounter] objectForKey:@"title"];
        descriptionLabel.text = [self setDynamicLabelText:[[tourData objectAtIndex:pageCounter] objectForKey:@"description"]];
        
        UIImageView *moveIMageView = imageView;
        [self addRightAnimationPresentToView:moveIMageView];
        
        if (pageCounter < tourData.count - 1) {
            skipBtn.hidden = NO;
            [finishBtn setTitle:@"" forState:UIControlStateNormal];
            [finishBtn setTitle:@"" forState:UIControlStateSelected];
            [finishBtn setTitle:@"" forState:UIControlStateHighlighted];
            [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateNormal];
            [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateSelected];
            [finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateHighlighted];
        }
    }
    else {
        
        pageCounter = 0;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)skip:(UIButton *)sender {
    
    if (isAsGuest) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [UserDefaultManager setValue:@"Yes" key:@"rootView"];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RegistrationViewControllerStepOne *loginView=[sb instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: loginView]
                                             animated: YES];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    
}

- (IBAction)finishAction:(UIButton *)sender {
    
    if (pageCounter != tourData.count - 1) {
        [self swipeIntroImageLeft];
    }
    else {
        if (isAsGuest) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [UserDefaultManager setValue:@"Yes" key:@"rootView"];
            UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RegistrationViewControllerStepOne *loginView=[sb instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
            [self.navigationController setViewControllers: [NSArray arrayWithObject: loginView]
                                                 animated: YES];
            [self.navigationController pushViewController:loginView animated:YES];
        }
    }
}
#pragma mark - end

#pragma mark - Set dynamic text
- (NSString *)setDynamicLabelText:(NSString *)text {
    
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 54,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:[UIFont railwayRegularWithSize:17]}
                     context:nil];
    
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = YES;
    descriptionLabel.frame = CGRectMake(27, 59, [[UIScreen mainScreen] bounds].size.width - 54, textRect.size.height);
    return text;
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
