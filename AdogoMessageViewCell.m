//
//  AdogoMessageViewCell.m
//  Adogo
//
//  Created by Ranosys on 05/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AdogoMessageViewCell.h"

@implementation AdogoMessageViewCell
@synthesize adogoIcon, adogoSentImage, adogoSentImageView, messageLabel, agentName;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Cell objects customization
- (void)changeDisplayFraming:(NSMutableDictionary *)data {

    adogoIcon.translatesAutoresizingMaskIntoConstraints = YES;
    adogoSentImage.translatesAutoresizingMaskIntoConstraints = YES;
    adogoSentImageView.translatesAutoresizingMaskIntoConstraints = YES;
    messageLabel.translatesAutoresizingMaskIntoConstraints = YES;
    agentName.translatesAutoresizingMaskIntoConstraints = YES;
    
    adogoIcon.hidden = NO;
    adogoSentImage.hidden = YES;
    adogoSentImageView.hidden = NO;
    messageLabel.hidden = YES;
    agentName.hidden = NO;
    
    adogoIcon.backgroundColor = [UIColor clearColor];
    adogoSentImageView.layer.masksToBounds = YES;
    adogoSentImageView.layer.cornerRadius = 5.0;
    adogoSentImageView.backgroundColor = [UIColor whiteColor];
    
    messageLabel.layer.borderWidth = 1.0;
    messageLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    
    adogoSentImage.backgroundColor = [UIColor clearColor];
    if ([[data allKeys] containsObject:@"attachment"]) {
    
        adogoSentImage.hidden = NO;
        
        adogoSentImageView.backgroundColor = [UIColor clearColor];
        adogoSentImageView.frame = CGRectMake(10 + 45 + 10, 10, 140, 140);
        adogoSentImage.frame = CGRectMake(0, 0, 140, 140);
        agentName.frame = CGRectMake(adogoSentImageView.frame.origin.x, adogoSentImageView.frame.origin.y + adogoSentImageView.frame.size.height + 10, 140, 20);
        adogoIcon.frame = CGRectMake(10, 10, 45, 45);
        if ([[[data objectForKey:@"attachment"] allKeys] containsObject:@"url$string"]) {
            [self downloadImages:adogoSentImage imageUrl:[[data objectForKey:@"attachment"] objectForKey:@"url$string"] placeholderImage:@"chatPlaceholderImage"];
        }
        else {
            [self downloadImages:adogoSentImage imageUrl:[[data objectForKey:@"attachment"] objectForKey:@"url"] placeholderImage:@"chatPlaceholderImage"];
        }
    }
    else {
    
        CGSize sizeValue = [self getDynamicLabelHeight:[data objectForKey:@"msg"] font:[UIFont railwayRegularWithSize:14] widthValue:[[UIScreen mainScreen] bounds].size.width - 120.0];
        if (sizeValue.height < 25.0) {
            sizeValue.height = 25.0;
        }
        messageLabel.hidden = NO;
        adogoSentImageView.frame = CGRectMake(10 + 45 + 10, 10, sizeValue.width + 20, sizeValue.height + 20);

        messageLabel.frame = CGRectMake(10, 10, sizeValue.width, sizeValue.height+1);
        messageLabel.numberOfLines = 0;
        messageLabel.text = [data objectForKey:@"msg"];
        agentName.frame = CGRectMake(adogoSentImageView.frame.origin.x, adogoSentImageView.frame.origin.y + adogoSentImageView.frame.size.height + 10, 140, 20);
        adogoIcon.frame = CGRectMake(10, 10, 45, 45);
    }
    
    agentName.text = [data objectForKey:@"name"];
}
#pragma mark - end

#pragma mark - Get dynamic label height according to given string
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