//
//  CarImageCollectionViewCell.m
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarImageCollectionViewCell.h"

@implementation CarImageCollectionViewCell
@synthesize carImage, addOptionalCar, imageType;

#pragma mark - Display data on cell
- (void)displayData:(int)index data:(NSMutableDictionary*)data {
    
    addOptionalCar.hidden = YES;
    carImage.hidden = NO;
    if (index == 0) {
        imageType.text = @"Front";
        [self downloadImages:self imageUrl:[[data objectForKey:@"front_image"] objectForKey:@"image"] placeholderImage:@"front.png"];
    }
    else if (index == 1) {
        imageType.text = @"Right Side";
        [self downloadImages:self imageUrl:[[data objectForKey:@"right_image"] objectForKey:@"image"] placeholderImage:@"rightSide.png"];
    }
    else if (index == 2) {
        imageType.text = @"Rear";
        [self downloadImages:self imageUrl:[[data objectForKey:@"rear_image"] objectForKey:@"image"] placeholderImage:@"rear.png"];
        
    }
    else if (index == 3) {
        imageType.text = @"Left Side";
        
        [self downloadImages:self imageUrl:[[data objectForKey:@"left_image"] objectForKey:@"image"] placeholderImage:@"leftSide.png"];
    }
    else{
        
        imageType.text = @"Optional";
        int indexValue = index - 4;
        
        [self downloadImages:self imageUrl:[[[data objectForKey:@"other_image"] objectAtIndex:indexValue] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
        
    }
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(CarImageCollectionViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = cell.carImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.carImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
