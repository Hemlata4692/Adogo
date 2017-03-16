//
//  AppSettingPopUpViewController.m
//  Adogo
//
//  Created by Ranosys on 26/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AppSettingPopUpViewController.h"

@interface AppSettingPopUpViewController ()

@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@end

@implementation AppSettingPopUpViewController
@synthesize contentString, titleString;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleLable.text = titleString;
    _noteTextView.text = contentString;
    [_popupContainerView setCornerRadius:5];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)okAction:(UIButton *)sender {
    
     [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelAciton:(UIButton *)sender {
    
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
