//
//  HelpViewController.m
//  Adogo
//
//  Created by Sumit on 27/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "HelpViewController.h"
#import "UserService.h"
@interface HelpViewController ()
@property(nonatomic,retain)IBOutlet UIWebView *webview;
@end

@implementation HelpViewController
@synthesize webview, isRejectTiming;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Help";
    // Do any additional setup after loading the view.
    [myDelegate showIndicator];
    [self performSelector:@selector(getCmsContent) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (isRejectTiming) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.hidesBackButton = YES;
        [self addLeftBarButtonWithBackImage:[UIImage imageNamed:@"back_white.png"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add left bar button
- (void)addLeftBarButtonWithBackImage:(UIImage *)backImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setBackgroundImage:backImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - end

#pragma mark - Back action
- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

#pragma mark - Call webservice
- (void)getCmsContent
{
    [[UserService sharedManager] cmsContentService:@"help" success:^(id responseObject)
     {
         NSDictionary *cmsDict = [responseObject objectForKey:@"cmsdata"];
//         NSLog(@"success message!!");
         [webview loadHTMLString:[NSString stringWithFormat:@"<div id ='foo' align='justify' style='font-size:17px; font-family:\"Raleway\"; color:#ffffff';>%@<div>", [cmsDict objectForKey:@"page_content"]] baseURL: nil];
     }
                                           failure:^(NSError *error)
     {
         
     }];
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
