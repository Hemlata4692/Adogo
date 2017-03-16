//
//  GlobalBackViewController.m
//  Adogo
//
//  Created by Sumit on 26/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "GlobalBackViewController.h"
#import "UIImage+deviceSpecificMedia.h"
#import "SWRevealViewController.h"

@interface GlobalBackViewController ()
{
  UIBarButtonItem *barButton,*barButton1;
}
@end

@implementation GlobalBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[image imageForDeviceWithName:@"bg"]]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImage.frame = self.view.frame;
    [self.view insertSubview:backgroundImage atIndex:0];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"] secondImage:[UIImage imageNamed:@"menu.png"]];
     myDelegate.currentNavController = self.navigationController;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add back button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage
{
    //Navigation bar buttons
    CGRect framing = CGRectMake(0, 0, 30, 30);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setImage:menuImage forState:UIControlStateNormal];
    [menu setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
    CGRect framing1 = CGRectMake(0, 0, 25, 25);
    UIButton *button = [[UIButton alloc] initWithFrame:framing1];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton,barButton1, nil];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}
//back button action
- (void)backButtonAction :(id)sender
{
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
