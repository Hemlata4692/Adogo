//
//  CampaignSummaryCell.m
//  Adogo
//
//  Created by Sumit on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CampaignSummaryCell.h"

@implementation CampaignSummaryCell
@synthesize campaignName;
@synthesize advertiserName;
@synthesize campaignImage;
@synthesize companyName;
@synthesize durationLbl;
@synthesize totalMileageLbl;
@synthesize pointsEarnedLbl;
@synthesize remainingDaysLbl;
@synthesize infoLbl;

@synthesize mileageIcon;
@synthesize staticMileageLbl;
@synthesize pointsIcon;
@synthesize staticPointsLbl;
@synthesize scheduleIcon;
@synthesize staticRemainingTimeLbl;
@synthesize campaignSummaryLbl;
@synthesize campaignSummaryBtn;

@synthesize campaignSummaryBgView;
@synthesize campaignInfoBgView;
@synthesize durationBgVIew;
@synthesize totalMileageBgView;
@synthesize pointsBgView;
@synthesize remainingDaysBgView;
@synthesize campaignSummaryBtnBgView;

@synthesize campaignInfoBtn;
@synthesize waitingLbl;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Display data on cell objects
- (void)displayData : (NSDictionary*)dataDict currentDate:(NSString *)currentDate
{
    if (dataDict.count>1) {
        campaignName.text=[dataDict objectForKey:@"campaign_name"];
        advertiserName.text=[dataDict objectForKey:@"advertiser_name"];
        companyName.text = [dataDict objectForKey:@"company_name"];
        durationLbl.text = [NSString stringWithFormat:@"%d Days [%@ to %@]",[self getDurationInDays:[dataDict objectForKey:@"start_date"] end:[dataDict objectForKey:@"end_date"]],[self formateDate:[dataDict objectForKey:@"start_date"]],[self formateDate:[dataDict objectForKey:@"end_date"]]];
        int campaignStatus = [UserDefaultManager dateComparision:currentDate endDate:[dataDict objectForKey:@"end_date"] startTime:[dataDict objectForKey:@"start_date"]];
        if ([[dataDict objectForKey:@"status"] isEqualToString:@"Completed"]) {
            staticMileageLbl.text = @"Distance Covered";
            staticPointsLbl.text = @"Days Travelled";
            staticRemainingTimeLbl.text = @"Total Earning";
            pointsIcon.image = [UIImage imageNamed:@"schedule"];
            scheduleIcon.image = [UIImage imageNamed:@"earning"];
            campaignSummaryLbl.text = @"Campaign Summary (Ended)";
            infoLbl.hidden = YES;
            campaignSummaryBtn.hidden = NO;
            campaignInfoBtn.hidden = YES;
            waitingLbl.hidden = YES;
            
            if ([[dataDict objectForKey:@"total_earnings"] isEqualToString:@""]) {
                remainingDaysLbl.text = @"0";
            }
            else {
                remainingDaysLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"total_earnings"]];
            }
            pointsEarnedLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"days_travelled"]];
        }
        else
        {
        if (campaignStatus==1)
        {
            campaignSummaryBgView.hidden = YES;
            campaignInfoBgView.hidden = YES;
            durationBgVIew.hidden = YES;
            totalMileageBgView.hidden = YES;
            pointsBgView.hidden = YES;
            remainingDaysBgView.hidden= YES;
            campaignSummaryBtnBgView.hidden = YES;
            
            campaignInfoBtn.hidden = NO;
            waitingLbl.hidden = NO;
            
        }
        else if (campaignStatus == 3)
        {
            staticMileageLbl.text = @"Distance Covered";
            staticPointsLbl.text = @"Days Travelled";
            staticRemainingTimeLbl.text = @"Total Earning";
            pointsIcon.image = [UIImage imageNamed:@"schedule"];
            scheduleIcon.image = [UIImage imageNamed:@"earning"];
            campaignSummaryLbl.text = @"Campaign Summary (Ended)";
            infoLbl.hidden = YES;
            campaignSummaryBtn.hidden = NO;
            campaignInfoBtn.hidden = YES;
            waitingLbl.hidden = YES;
            
            if ([[dataDict objectForKey:@"total_earnings"] isEqualToString:@""]) {
                remainingDaysLbl.text = @"0";
            }
            else {
                remainingDaysLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"total_earnings"]];
            }
            pointsEarnedLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"days_travelled"]];
        }
        else if (campaignStatus==2)
        {
            campaignInfoBtn.hidden = YES;
            waitingLbl.hidden = YES;
            infoLbl.hidden = NO;
            campaignSummaryBtn.hidden = YES;
            long noOfDays = [self getDurationInDays:[[currentDate componentsSeparatedByString:@" "] objectAtIndex:0] end:[dataDict objectForKey:@"end_date"]];
            
            if (noOfDays >= 1)
            {
                remainingDaysLbl.text = [NSString stringWithFormat:@"%ld",noOfDays];
            }
            else
            {
                remainingDaysLbl.text = [NSString stringWithFormat:@"0"] ;
                
            }
//            remainingDaysLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"daysLeft"]];
            pointsEarnedLbl.text = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"total_points"]];
            NSAttributedString * str = [[NSString stringWithFormat:@"Tap on floating TRACK button to start tracking"] setAttributrdString:@"TRACK" stringFont:[UIFont railwayBoldWithSize:14] selectedColor:[UIColor colorWithRed:74.0/255.0 green:236.0/255.0 blue:204.0/255.0 alpha:1.0]];
            infoLbl.attributedText = str;
        }
        }
        
        totalMileageLbl.text = [NSString stringWithFormat:@"%@ KM",[dataDict objectForKey:@"track_distance"]];
        __weak UIImageView *weakRef = campaignImage;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dataDict objectForKey:@"logo"]]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [campaignImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"campaignLogoPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
}
#pragma mark - end

#pragma mark - Date formatting
-(NSString*)formateDate:(NSString *)dateStr
{
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

#pragma mark - Get day duration b/w start and end date/time
-(int)getDurationInDays:(NSString *)start end :(NSString *)end
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy/MM/dd"];
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:NSCalendarWrapComponents];
//    NSLog(@"%ld",(long)components.day);
    return (int)components.day;
    
}
#pragma mark - end
@end
