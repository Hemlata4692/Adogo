//
//  CampaignSuccessfullCell.m
//  Adogo
//
//  Created by Sumit on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CampaignSuccessfullCell.h"

@implementation CampaignSuccessfullCell
@synthesize campaignImage;
@synthesize campaignNameLabel;
@synthesize advertiserNameLabel;
@synthesize moreInfoBtn;
@synthesize timerLbl;
@synthesize setInstallationBtn;
@synthesize companyLbl;
@synthesize campaignTimer;
@synthesize hours;
@synthesize minutes;
@synthesize seconds;
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Display data on cell
- (void)displayData:(NSDictionary *)dataDict  currentTime:(NSString *)currentTime isPending:(BOOL)isPending
{
    //customize button
    moreInfoBtn.layer.borderWidth = 1.0;
    moreInfoBtn.layer.borderColor =[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0].CGColor;
    moreInfoBtn.layer.cornerRadius = 2.0;
    //end
    if (dataDict.count<1)
    {
        return;
        
    }
    //set data to labels
    campaignNameLabel.text= [dataDict objectForKey:@"campaigns_name"];
    advertiserNameLabel.text= [dataDict objectForKey:@"advertiser_name"];
    companyLbl.text= [dataDict objectForKey:@"company_name"];
    __weak UIImageView *weakRef = campaignImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dataDict objectForKey:@"bidimage"]]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [campaignImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    
    if (!isPending) {
        timerLbl.text = @"You have already selected installation type. Still you can change installation type until an installer assigend to you.";
        [setInstallationBtn setTitle:@"Update Installation" forState:UIControlStateNormal];
    }
    else {
        [setInstallationBtn setTitle:@"Set Installation" forState:UIControlStateNormal];
    }
    
    
    if (![campaignTimer isValid])
    {
        seconds = [[UserDefaultManager formateDate:currentTime] timeIntervalSinceDate:[UserDefaultManager formateDate:[dataDict objectForKey:@"bidConfirmationTime"]]];
        seconds = 43200-seconds;
        hours = seconds / (60 * 60);
        minutes = (seconds / 60)%60;
        setInstallationBtn.hidden=false;
        timerLbl.textColor=[UIColor blackColor];
        if (seconds<=0&&isPending) {
            setInstallationBtn.enabled=false;
            setInstallationBtn.hidden=true;
            timerLbl.textColor=[UIColor colorWithRed:223.0/255.0 green:64.0/255.0 blue:63.0/255.0 alpha:1.0];
            timerLbl.text = [NSString stringWithFormat:@"You have been kicked out from bid as installation time as expired."];
        }
        else if(seconds<=0&&!isPending) {
            //Responsed to approved bid
            setInstallationBtn.enabled=false;
            timerLbl.textColor=[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f];
            timerLbl.text = @"Installation type has been set.";
        }
        else {
            setInstallationBtn.enabled=true;
            if (isPending) {
                timerLbl.attributedText = [[NSString stringWithFormat:@"Are you in? You have %lld:%02lld hrs to confirm installation", hours, minutes] setAttributrdString:[NSString stringWithFormat:@"%lld:%02lld hrs", hours, minutes] stringFont:[UIFont railwayBoldWithSize:14] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
                campaignTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                 target:self
                                                               selector:@selector(startTimer:)
                                                               userInfo:@"Yes"
                                                                repeats:YES];
            }
            else {
                timerLbl.text = @"You have already selected installation type. Still you can change installation type until an installer assigend to you.";
                campaignTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                 target:self
                                                               selector:@selector(startTimer:)
                                                               userInfo:@"No"
                                                                repeats:YES];
            }
        }
    }
//    NSLog(@"Seconds --------> %lld", seconds);
}
#pragma mark - end

#pragma mark - Set timer
- (void)startTimer:(NSTimer*)isPending
{
    NSString *pendingString=isPending.userInfo;
    seconds = seconds-60;
    if (seconds<=0) {
        setInstallationBtn.enabled=false;
        seconds=0;
    }
    hours = seconds / (60 * 60);
    minutes = (seconds / 60)%60;
    if (seconds<=0&&[pendingString isEqualToString:@"Yes"]) {
        setInstallationBtn.enabled=false;
        setInstallationBtn.hidden=true;
        timerLbl.textColor=[UIColor colorWithRed:223.0/255.0 green:64.0/255.0 blue:63.0/255.0 alpha:1.0];
        timerLbl.text = [NSString stringWithFormat:@"You have been kicked out from bid as installation time as expired."];
    }
    else if(seconds<=0&&[pendingString isEqualToString:@"No"]) {
        //Responsed to approved bid
        setInstallationBtn.enabled=false;
        timerLbl.textColor=[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f];
        timerLbl.text = @"Installation type has been set.";
    }
    else {
        if ([pendingString isEqualToString:@"Yes"]) {
            timerLbl.attributedText = [[NSString stringWithFormat:@"Are you in? You have %lld:%02lld hrs to confirm installation", hours, minutes] setAttributrdString:[NSString stringWithFormat:@"%lld:%02lld hrs", hours, minutes] stringFont:[UIFont railwayBoldWithSize:14] selectedColor:[UIColor colorWithRed:(56.0/255.0) green:(192.0/255.0) blue:(182.0/255.0) alpha:1.0f]];
        }
        else {
            timerLbl.text = @"You have already selected installation type. Still you can change installation type until an installer assigend to you.";
        }
    }
    if (seconds<=0) {
        [campaignTimer invalidate];
    }

}
#pragma mark - end
@end
