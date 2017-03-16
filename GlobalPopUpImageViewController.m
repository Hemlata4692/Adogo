//
//  GlobalPopUpImageViewController.m
//  Adogo
//
//  Created by Ranosys on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "GlobalPopUpImageViewController.h"

@interface GlobalPopUpImageViewController ()

@property (strong, nonatomic) IBOutlet UIView *popupContainerView;
@property (strong, nonatomic) IBOutlet UILabel *popupTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *carImageView;
@end

@implementation GlobalPopUpImageViewController
@synthesize placeHolderImage, popupTitle, imageUrl;
@synthesize popupContainerView, popupTitleLabel,carImage;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    popupTitleLabel.text = popupTitle;
    [self setBorderAndornerRadius];
    [self downloadImages];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View border and corner radius
- (void)setBorderAndornerRadius {
    
    [popupContainerView setCornerRadius:5];
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)okButtonAction:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)crossButtonAction:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end

#pragma mark - Image downloading using AFNetworking
- (void)downloadImages {
    
    if (![imageUrl isEqualToString:@""]) {
        
    
    __weak UIImageView *weakRef = _carImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [_carImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor whiteColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
        }
    else{
        _carImageView.image = carImage;
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
