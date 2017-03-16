//
//  DriverMessageViewCell.m
//  Adogo
//
//  Created by Ranosys on 05/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "DriverMessageViewCell.h"

@implementation DriverMessageViewCell
@synthesize driverSentImage, driverSentImageView, messageLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Cell objects customization
- (void)changeDriverDisplayFraming:(NSMutableDictionary *)data {
    
    //Remove autolayout
    driverSentImageView.translatesAutoresizingMaskIntoConstraints = YES;
    driverSentImage.translatesAutoresizingMaskIntoConstraints = YES;
    messageLabel.translatesAutoresizingMaskIntoConstraints = YES;
    //Set hidden funtionality of view objects
    driverSentImage.hidden = YES;
    driverSentImageView.hidden = NO;
    messageLabel.hidden = YES;
    //Layer customization
    driverSentImageView.layer.masksToBounds = YES;
    driverSentImageView.layer.cornerRadius = 5.0;
    driverSentImageView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    messageLabel.layer.borderWidth = 1.0;
    messageLabel.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0].CGColor;
    messageLabel.backgroundColor = [UIColor clearColor];
    driverSentImage.backgroundColor = [UIColor clearColor];
    if ([[data allKeys] containsObject:@"attachment"]) {
        
        driverSentImage.hidden = NO;
        
        driverSentImageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 10 - 140, 10, 140, 140);
        driverSentImage.frame = CGRectMake(0, 0, 140, 140);
        driverSentImageView.backgroundColor = [UIColor clearColor];
        
        if ([[[data objectForKey:@"attachment"] allKeys] containsObject:@"url$string"]) {
            [self downloadImages:driverSentImage imageUrl:[[data objectForKey:@"attachment"] objectForKey:@"url$string"] placeholderImage:@"chatPlaceholderImage"];
        }
        else {
            [self downloadImages:driverSentImage imageUrl:[[data objectForKey:@"attachment"] objectForKey:@"url"] placeholderImage:@"chatPlaceholderImage"];
        }
    }
    else {
        CGSize sizeValue = [self getDynamicLabelHeight:[data objectForKey:@"msg"] font:[UIFont railwayRegularWithSize:14] widthValue:[[UIScreen mainScreen] bounds].size.width - 120.0];
        if (sizeValue.height < 25.0) {
            sizeValue.height = 25.0;
        }
        messageLabel.hidden = NO;
        driverSentImageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 10 - (sizeValue.width + 20), 10, sizeValue.width + 20, sizeValue.height + 20);
        
        messageLabel.frame = CGRectMake(10, 10, sizeValue.width, sizeValue.height+1);
        messageLabel.numberOfLines = 0;
        messageLabel.text = [data objectForKey:@"msg"];
    }
}

- (CGSize)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,1500);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size;
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(UIImageView *)adogoImage imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = adogoImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [adogoImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
