//
//  BidInfoTableViewCell.m
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BidInfoTableViewCell.h"

@implementation BidInfoTableViewCell
@synthesize campaignLogo, campaignName,advertiserName, companyName, bidTimeLeftBtn, timeLeftLabel;
@synthesize duration, maxBid, minMileage, requiredRoute, currentAvgBid, currentAvgView;
@synthesize monthLabel, myBidView, myBidField, checkTermCondition, termsConditionBtn, signatureBtn, bidNowBtn, bidLaterBtn, chatBtn, notIntersetedBtn,signatureImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Set layout and display data on campaign cell
- (void)setLayoutCampaign:(NSMutableDictionary *)data {
    
//    companyName.translatesAutoresizingMaskIntoConstraints = YES;
    
    bidTimeLeftBtn.layer.cornerRadius = 3.0f;
    bidTimeLeftBtn.layer.masksToBounds = YES;
    
//    float height = [self getDynamicLabelHeight:[data objectForKey:@"companyName"] font:[UIFont railwayBoldWithSize:13] widthValue:[[UIScreen mainScreen] bounds].size.width - 101 - 8];
//    companyName.numberOfLines = 0;
//    companyName.frame = CGRectMake(101, 86, [[UIScreen mainScreen] bounds].size.width - 101 - 8, height);
}

- (void)displayCampaignData:(NSMutableDictionary *)data {
    
    campaignName.text=[data objectForKey:@"campaign_name"];
    advertiserName.text=[data objectForKey:@"advertiser_name"];
    companyName.text = [data objectForKey:@"companyName"];
    [self downloadImages:self imageUrl:[data objectForKey:@"logo"] placeholderImage:@"campaignLogoPlaceholder"];
}
#pragma mark - end

#pragma mark - Set layout and display data on campaign info cell
- (void)setLayoutCampaignInfo:(NSMutableDictionary *)data isBidExist:(BOOL)isBidExist{
    
    requiredRoute.translatesAutoresizingMaskIntoConstraints = YES;
    currentAvgView.translatesAutoresizingMaskIntoConstraints = YES;
    _myBidLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _myBidValue.translatesAutoresizingMaskIntoConstraints = YES;
    
    currentAvgView.layer.cornerRadius = (35.0f / 2.0f);
    currentAvgView.layer.masksToBounds = YES;
    currentAvgView.layer.borderColor = [UIColor whiteColor].CGColor;
    currentAvgView.layer.borderWidth = 1.0f;
    
    float height = [self getDynamicLabelHeight:[data objectForKey:@"location"] font:[UIFont railwayBoldWithSize:13] widthValue:[[UIScreen mainScreen] bounds].size.width - 134 - 8];
    requiredRoute.numberOfLines = 0;
    requiredRoute.frame = CGRectMake(134,82, [[UIScreen mainScreen] bounds].size.width - 134 - 8, height);
    
    if (isBidExist) {
        _myBidLabel.hidden = NO;
        _myBidValue.hidden = NO;
        currentAvgView.hidden = YES;
        _myBidLabel.frame = CGRectMake(15,requiredRoute.frame.origin.y + requiredRoute.frame.size.height + 8, 118, 21);
        _myBidValue.frame = CGRectMake(134,requiredRoute.frame.origin.y + requiredRoute.frame.size.height + 8, [[UIScreen mainScreen] bounds].size.width - 134 - 8, 21);
    }
    else {
        _myBidLabel.hidden = YES;
        _myBidValue.hidden = YES;
        currentAvgView.hidden = NO;
        currentAvgView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) - (304 / 2) , 82 + height + 10, 304, 35);
    }
}

- (void)displayCampaignInfoData:(NSMutableDictionary *)data isBidExist:(BOOL)isBidExist{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDateTime = [dateFormatter dateFromString:[data objectForKey:@"durationFromtime"]];
     NSDate *ToDateTime = [dateFormatter dateFromString:[data objectForKey:@"durationTotime"]];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    duration.attributedText = [[NSString stringWithFormat:@"%@ to %@",[dateFormatter stringFromDate:fromDateTime],[dateFormatter stringFromDate:ToDateTime]] setAttributrdString:@"to" stringFont:[UIFont railwayRegularWithSize:13.0] selectedColor:[UIColor whiteColor]];
    
    maxBid.text = [NSString stringWithFormat:@"S$%@",[data objectForKey:@"maxBid"]];
    if ([data objectForKey:@"location"] == nil || [[data objectForKey:@"location"] isEqualToString:@""]) {
        requiredRoute.text = @"NA";
    }
    else {
        requiredRoute.text = [data objectForKey:@"location"];
    }
    
    if (!isBidExist) {
        if ([data objectForKey:@"avg_bid_amount"] == nil || [[data objectForKey:@"avg_bid_amount"] isEqualToString:@""]) {
            currentAvgBid.text = [NSString stringWithFormat:@"S$0"];
        }
        else {
            currentAvgBid.text = [NSString stringWithFormat:@"S$%.02f",[[data objectForKey:@"avg_bid_amount"] floatValue]];
        }
    }
    else {
        _myBidValue.text = [NSString stringWithFormat:@"S$%@",[data objectForKey:@"my_bid"]];
    }
    
//    float distanceFromCurrentLocation=[[data objectForKey:@"minMileage"] floatValue];
//    if(distanceFromCurrentLocation/1000.0<1) {
//        minMileage.text = [NSString stringWithFormat:@"%@ m",[data objectForKey:@"minMileage"]];
//    }
//    else {
        minMileage.text = [NSString stringWithFormat:@"%0.2f Km",[[data objectForKey:@"minMileage"] floatValue]];
//    }
}
#pragma mark - end

#pragma mark - Set layout and display data on campaign buttons cell
- (void)setLayoutCampaignButton {
    
    myBidView.layer.cornerRadius = 3.0f;
    myBidView.layer.masksToBounds = YES;
    myBidView.layer.borderColor = [UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f].CGColor;
    myBidView.layer.borderWidth = 1.0f;
    
    signatureBtn.layer.cornerRadius = 3.0f;
    signatureBtn.layer.masksToBounds = YES;
    
    [notIntersetedBtn add3DEffect:[UIColor colorWithRed:(135.0f/255.0f) green:(32.0f/255.0f) blue:(38.0f/255.0f) alpha:1.0]];
}

- (void)displayCampaignButtonData:(NSMutableDictionary *)data {

}
#pragma mark - end

#pragma mark - Get dyanmic label height
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,200);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(BidInfoTableViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = cell.campaignLogo;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.campaignLogo setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
