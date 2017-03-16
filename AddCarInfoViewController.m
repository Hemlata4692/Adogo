//
//  AddCarInfoViewController.m
//  Adogo
//
//  Created by Ranosys on 01/08/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AddCarInfoViewController.h"
#import "UIImage+deviceSpecificMedia.h"
#import "SWRevealViewController.h"

@interface AddCarInfoViewController ()<UIGestureRecognizerDelegate> {

    NSArray *informationImageArray;
    int sliderIndex;
}

@property (strong, nonatomic) IBOutlet UIImageView *informationSlider;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@end

@implementation AddCarInfoViewController
@synthesize pageController;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    //Set background image on uiview
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[image imageForDeviceWithName:@"bg"]]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    //end
    informationImageArray = [NSArray arrayWithObjects:@"badfront.jpg",@"goodfront.jpg",@"badleft.jpg",@"goodleft.jpg",@"badrear.jpg",@"goodrear.jpg",@"badright.jpg",@"goodright.jpg", nil];
    sliderIndex = 0;
    pageController.numberOfPages = [informationImageArray count];
    sliderIndex = 0;
    pageController.currentPage = sliderIndex;
    pageController.pageIndicatorTintColor = [UIColor colorWithRed:0.0/255.0 green:153.0/255.0 blue:135.0/255.0 alpha:1.0];
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.informationSlider.userInteractionEnabled = YES;
    self.informationSlider.image = [UIImage imageNamed:[informationImageArray objectAtIndex:sliderIndex]];
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
    
    sliderIndex++;
    if (sliderIndex < informationImageArray.count) {
        
        pageController.currentPage = sliderIndex;
        self.informationSlider.image = [UIImage imageNamed:[informationImageArray objectAtIndex:sliderIndex]];
        UIImageView *moveIMageView = self.informationSlider;
        [self addLeftAnimationPresentToView:moveIMageView];
    }
    else {
        
        sliderIndex = (int)informationImageArray.count - 1;
    }
}

//Swipe images in right direction
- (void)swipeIntroImageRight {
    
    sliderIndex--;
    if (sliderIndex>=0) {
        
        pageController.currentPage = sliderIndex;
        self.informationSlider.image = [UIImage imageNamed:[informationImageArray objectAtIndex:sliderIndex]];
        UIImageView *moveIMageView = self.informationSlider;
        [self addRightAnimationPresentToView:moveIMageView];
    }
    else {
        
        sliderIndex = 0;
    }
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
