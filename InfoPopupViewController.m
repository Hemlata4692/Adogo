//
//  InfoPopupViewController.m
//  Adogo
//
//  Created by Monika on 01/06/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "InfoPopupViewController.h"

@interface InfoPopupViewController ()
@property (strong, nonatomic) IBOutlet UITextView *infoTextView;
@end

@implementation InfoPopupViewController
@synthesize infoText,infoTextView;

#pragma mark - UIView life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    infoTextView.text = infoText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)crossButtonAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
