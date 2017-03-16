//
//  IntroductionViewController.m
//  Adogo
//
//  Created by Ranosys on 25/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "IntroductionViewController.h"
#import "RegistrationViewControllerStepOne.h"

@interface IntroductionViewController ()<UIGestureRecognizerDelegate> {

    NSArray *introData;
    int pageCounter;
}

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *introductionImage;
@property (strong, nonatomic) IBOutlet UIButton *skipBtn;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *finishBtn;
@end

@implementation IntroductionViewController
@synthesize isAsGuest;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    introData = @[@{@"title":@"Do You Travel Regularly?", @"imageName": @"screen1"},
                  @{@"title":@"Place Advertise on your Car!!", @"imageName": @"screen2"},
                  @{@"title":@"Earn Money!", @"imageName": @"screen3"}];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
   
    _pageControl.numberOfPages = [introData count];
    pageCounter = 0;
    _pageControl.currentPage = pageCounter;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.0/255.0 green:153.0/255.0 blue:135.0/255.0 alpha:1.0];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _introductionImage.userInteractionEnabled = YES;
    _textLabel.text = [[introData objectAtIndex:pageCounter] objectForKey:@"title"];
    _introductionImage.image = [UIImage imageNamed:[[introData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
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
    [_finishBtn setTitle:@"" forState:UIControlStateNormal];
    [_finishBtn setTitle:@"" forState:UIControlStateSelected];
    [_finishBtn setTitle:@"" forState:UIControlStateHighlighted];
    [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateNormal];
    [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateSelected];
    [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateHighlighted];
    //end
    // Do any additional setup after loading the view.
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
    if (pageCounter < introData.count) {
        
        _pageControl.currentPage = pageCounter;
        _introductionImage.image = [UIImage imageNamed:[[introData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
        _textLabel.text = [[introData objectAtIndex:pageCounter] objectForKey:@"title"];
        UIImageView *moveIMageView = _introductionImage;
        [self addLeftAnimationPresentToView:moveIMageView];
        
        if (pageCounter == introData.count - 1) {
            _skipBtn.hidden = YES;
        [_finishBtn setTitle:@"FINISH" forState:UIControlStateNormal];
        [_finishBtn setTitle:@"FINISH" forState:UIControlStateSelected];
        [_finishBtn setTitle:@"FINISH" forState:UIControlStateHighlighted];
        [_finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [_finishBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        }
    }
    else {
        pageCounter = (int)introData.count - 1;
    }
}

//Swipe images in right direction
- (void)swipeIntroImageRight {
    pageCounter--;
    if (pageCounter>=0) {
        _pageControl.currentPage = pageCounter;
        _introductionImage.image = [UIImage imageNamed:[[introData objectAtIndex:pageCounter] objectForKey:@"imageName"]];
        _textLabel.text = [[introData objectAtIndex:pageCounter] objectForKey:@"title"];
        
        UIImageView *moveIMageView = _introductionImage;
        [self addRightAnimationPresentToView:moveIMageView];
        
        if (pageCounter < introData.count - 1) {
            _skipBtn.hidden = NO;
            [_finishBtn setTitle:@"" forState:UIControlStateNormal];
            [_finishBtn setTitle:@"" forState:UIControlStateSelected];
            [_finishBtn setTitle:@"" forState:UIControlStateHighlighted];
            [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateNormal];
            [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateSelected];
            [_finishBtn setImage:[UIImage imageNamed:@"arrowWhite"] forState:UIControlStateHighlighted];
        }
    }
    else {
        pageCounter = 0;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)skip:(UIButton *)sender {
    
    [self viewNavigation];
}

- (IBAction)finishAction:(UIButton *)sender {
    
    if (pageCounter != introData.count - 1) {
         [self swipeIntroImageLeft];
    }
    else {
         [self viewNavigation];
    }
}
#pragma mark - end

#pragma mark - View navigation
- (void)viewNavigation {

        [UserDefaultManager setValue:@"Yes" key:@"rootView"];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RegistrationViewControllerStepOne *loginView=[sb instantiateViewControllerWithIdentifier:@"RegistrationViewStepOne"];
        [self.navigationController setViewControllers: [NSArray arrayWithObject: loginView]
                                             animated: YES];
        [self.navigationController pushViewController:loginView animated:YES];
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
