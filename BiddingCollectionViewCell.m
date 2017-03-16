//
//  BiddingCollectionViewCell.m
//  Adogo
//
//  Created by Sumit on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BiddingCollectionViewCell.h"
#import <UIImageView+AFNetworking.h>
@implementation BiddingCollectionViewCell
@synthesize previousBtn;
@synthesize nextBtn;
@synthesize bidName;
@synthesize biddingImage;
@synthesize moreBidBtn;
@synthesize durationLabel;
@synthesize bidRejectedLbl;
@synthesize rejectionReasonLbl;

#pragma mark - Display data on cell objects
- (void)dispalyData : (NSDictionary *)dataDict count:(int)count
{
    myDelegate.methodName = @" CollectionCell displayData line: 24";
    if ([[dataDict objectForKey:@"isRejected"] boolValue])
    {
        bidRejectedLbl.hidden = NO;
        rejectionReasonLbl.hidden = NO;
        rejectionReasonLbl.text = [dataDict objectForKey:@"rejectReason"];
        moreBidBtn.hidden = YES;
    }
    else
    {
        bidRejectedLbl.hidden = YES;
        rejectionReasonLbl.hidden = YES;
        moreBidBtn.hidden = NO;
    }
    
    if ([[dataDict objectForKey:@"bidding_status"] isEqualToString:@"Applied"]) {
        
        [moreBidBtn setTitle:@"Update Bidding & More Info" forState:UIControlStateNormal];
    }
    else if ([[dataDict objectForKey:@"bidding_status"] isEqualToString:@"Standby"]) {
        
        bidRejectedLbl.hidden = NO;
        rejectionReasonLbl.hidden = NO;
        bidRejectedLbl.text = @"Stand By";
        rejectionReasonLbl.numberOfLines = 0;
        rejectionReasonLbl.text = [UserDefaultManager getValue:@"stand_by_message"];
        moreBidBtn.hidden = YES;
    }
    else {
        [moreBidBtn setTitle:@"More Info & Bid Now" forState:UIControlStateNormal];
    }
    
    bidName.text = [NSString stringWithFormat:@"%@\n%@",[dataDict objectForKey:@"campaigns_name"],[dataDict objectForKey:@"company_name"]];
    durationLabel.text = [NSString stringWithFormat:@"%@ to %@",[self formateDate:[dataDict objectForKey:@"durationFromtime"]],[self formateDate:[dataDict objectForKey:@"durationTotime"]]];
    __weak UIImageView *weakRef = biddingImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dataDict objectForKey:@"bidimage"]]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [biddingImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end

#pragma mark - Date formatting
-(NSString*)formateDate:(NSString *)dateStr
{
     myDelegate.methodName = @" CollectionCell formateDate line: 56";
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [formatter setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}
#pragma mark - end
@end
