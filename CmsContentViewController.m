//
//  CmsContentViewController.m
//  Adogo
//
//  Created by Sumit on 28/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CmsContentViewController.h"
#import "UserService.h"
@interface CmsContentViewController ()
{
   UIBarButtonItem *barButton;
}
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIButton *gotItBtn;
@end

@implementation CmsContentViewController
@synthesize webview;
@synthesize cmsId, gotItString, gotItBtn;

#pragma mark - UIView life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [gotItBtn setTitle:[NSString stringWithFormat:@"Got it, Back to %@",gotItString] forState:UIControlStateNormal];
    [[self navigationController] setNavigationBarHidden:NO];
    
    if ([cmsId isEqualToString:@"BidInfo"]) {
        
        [webview loadHTMLString:[NSString stringWithFormat:@"<div id ='foo' align='justify' style='font-size:17px; font-family:\"Raleway\"; color:#ffffff';>%@<div>", _cmsContent] baseURL: nil];
    }
    else {
        [myDelegate showIndicator];
        [self performSelector:@selector(getCmsContent) withObject:nil afterDelay:.1];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Cms service
- (void)getCmsContent
{
    [[UserService sharedManager] cmsContentService:cmsId  success:^(id responseObject)
     {
         NSDictionary *cmsDict = [responseObject objectForKey:@"cmsdata"];
//         NSLog(@"success message!!");
         [webview loadHTMLString:[NSString stringWithFormat:@"<div id ='foo' align='justify' style='font-size:17px; font-family:\"Raleway\"; color:#ffffff';>%@<div>", [cmsDict objectForKey:@"page_content"]] baseURL: nil];
     }
     failure:^(NSError *error)
     {
         
     }];
}

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage {
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

#pragma mark - UIView actions
- (void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)GotIt:(UIButton *)sender {
    
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
