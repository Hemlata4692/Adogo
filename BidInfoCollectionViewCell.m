//
//  BidInfoCollectionViewCell.m
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BidInfoCollectionViewCell.h"

@implementation BidInfoCollectionViewCell
@synthesize carType, carImage;

#pragma mark - Display images on cells
- (void)displayData:(int)index data:(NSString*)data {
    
    //Image Downloading according to image type
//    if ([[data objectForKey:@"type"] isEqualToString:@"right_image"]) {
        [self downloadImages:self imageUrl:data placeholderImage:@"carPlaceholder"];
        carType.text = @"";
//    }
//    else  if ([[data objectForKey:@"type"] isEqualToString:@"box_on_top"]) {
//        [self downloadImages:self imageUrl:[data objectForKey:@"image_url"] placeholderImage:@"boxOnTop.png"];
//        carType.text = @"Box On Top";
//    }
//    else  if ([[data objectForKey:@"type"] isEqualToString:@"left_image"]) {
//        [self downloadImages:self imageUrl:[data objectForKey:@"image_url"] placeholderImage:@"leftSide.png"];
//        carType.text = @"Left Side";
//    }
//    else  if ([[data objectForKey:@"type"] isEqualToString:@"front_image"]) {
//        [self downloadImages:self imageUrl:[data objectForKey:@"image_url"] placeholderImage:@"front.png"];
//        carType.text = @"Front";
//    }
//    else  if ([[data objectForKey:@"type"] isEqualToString:@"rear_image"]) {
//        [self downloadImages:self imageUrl:[data objectForKey:@"image_url"] placeholderImage:@"rear.png"];
//        carType.text = @"Rear";
//    }
//    else {
//        [self downloadImages:self imageUrl:[data objectForKey:@"image_url"] placeholderImage:@"OtherSide.png"];
//        carType.text = @"Optional";
//    }
    //end
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(BidInfoCollectionViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
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
