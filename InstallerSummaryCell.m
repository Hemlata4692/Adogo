//
//  InstallerSummaryCell.m
//  Adogo
//
//  Created by Sumit on 16/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "InstallerSummaryCell.h"
@implementation InstallerSummaryCell

//Fisst row objects
@synthesize  InstallerSummaryBgView;
@synthesize  refreshBtn;
@synthesize  installerSummaryLbl;
@synthesize  installerSummarySeparator;
//end
//Second row objects
@synthesize  installerNameBgView;
@synthesize  installerNameLbl;
@synthesize  nameLbl;
@synthesize  installerNameSeparator;
@synthesize installerNameIcon;
//end
//Third row objects
@synthesize  ScheduledDateBgView;
@synthesize  scheduledDateLbl;
@synthesize  dateLbl;
@synthesize  dateSeparator;
@synthesize scheduledDateIcon;
//end
//forth row objects
@synthesize  contactBgView;
@synthesize  contactLbl;
@synthesize  userContact;
@synthesize  callBtn;
@synthesize  contactSeparator;
@synthesize contactIcon;
//end
//Fifth row object
@synthesize  ProposedTimeBgView;
@synthesize  proposedTimeLbl;
@synthesize  timeSeparator;
@synthesize  timeLbl;
@synthesize proposedTimeIcon;
//end
//Sixth row object
@synthesize  buttonBgView;
@synthesize  sechduleInfoLbl;
@synthesize  confirmTimeBtn;
@synthesize  rejectTimeBtn;
//end

@synthesize installationSuccessView;
@synthesize installationFailedVIew;

@synthesize callAdogoBtn;
@synthesize chatAdogoBtn;
@synthesize uploadStickerBtn;
@synthesize waitingStatusLbl;

@synthesize dashboardAshButton;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Set laybout before confirmation
- (void)layoutBeforeConfirmation
{
     myDelegate.methodName = @" installerSummaryCell layoutBeforeConfirmation line: 75";
    dashboardAshButton.hidden=YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    //row one layout
    installerSummaryLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    InstallerSummaryBgView.backgroundColor =[UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    refreshBtn.hidden = NO;
    //end
    //row two layout
    installerNameIcon.image = [UIImage imageNamed:@"installer_name"];
    installerNameLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    installerNameBgView.backgroundColor =[UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    //end
    //row third layout
    scheduledDateIcon.image = [UIImage imageNamed:@"schedule"];
    scheduledDateLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    ScheduledDateBgView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    //end
    //row four layout
    contactIcon.image = [UIImage imageNamed:@"contact"];
    contactLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    contactBgView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    callBtn.hidden = YES;
    //end
    //row five layout
    proposedTimeIcon.image = [UIImage imageNamed:@"proposed_time"];
    proposedTimeLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    ProposedTimeBgView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    //end
    //row six layout
    buttonBgView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:245.0/255.0 alpha:1.0];
    sechduleInfoLbl.hidden = YES;
    [confirmTimeBtn setTitle:@"Confirm Timing" forState:UIControlStateNormal];
    [confirmTimeBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [rejectTimeBtn setTitle:@"Reject Timing" forState:UIControlStateNormal];
    [rejectTimeBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    //end
}
#pragma mark - end

#pragma mark - Set layout after confirmation
- (void)layoutAfterConfirmation :(NSDictionary *)dataDict
{
     dashboardAshButton.hidden=NO;
    myDelegate.methodName = @" installerSummaryCell layoutAfterConfirmation line: 117";
    self.contentView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    //row one layout
    installerSummaryLbl.textColor = [UIColor whiteColor];
    InstallerSummaryBgView.backgroundColor =[UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    refreshBtn.hidden = YES;
    installerSummarySeparator.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:160.0/255.0 alpha:1.0];
    //end
    //row two layout
    installerNameIcon.image = [UIImage imageNamed:@"installer_nameWhite"];
    installerNameLbl.textColor = [UIColor whiteColor];
    installerNameBgView.backgroundColor =[UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    installerNameSeparator.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:160.0/255.0 alpha:1.0];
    nameLbl.textColor = [UIColor colorWithRed:35.0/255.0 green:58.0/255.0 blue:62.0/255.0 alpha:1.0];
    //end
    //row third layout
    scheduledDateIcon.image = [UIImage imageNamed:@"scheduleWhite"];
    scheduledDateLbl.textColor = [UIColor whiteColor];
    ScheduledDateBgView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    dateSeparator.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:160.0/255.0 alpha:1.0];
    dateLbl.textColor = [UIColor colorWithRed:35.0/255.0 green:58.0/255.0 blue:62.0/255.0 alpha:1.0];
    //end
    //row four layout
    contactIcon.image = [UIImage imageNamed:@"contactWhite"];
    contactLbl.textColor = [UIColor whiteColor];
    contactBgView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    callBtn.hidden = NO;
    contactSeparator.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:160.0/255.0 alpha:1.0];
    userContact.textColor = [UIColor colorWithRed:35.0/255.0 green:58.0/255.0 blue:62.0/255.0 alpha:1.0];
    //end
    //row five layout
    proposedTimeIcon.image = [UIImage imageNamed:@"proposed_timeWhite"];
    proposedTimeLbl.textColor = [UIColor whiteColor];
    ProposedTimeBgView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    timeSeparator.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:160.0/255.0 alpha:1.0];
    timeLbl.textColor = [UIColor colorWithRed:35.0/255.0 green:58.0/255.0 blue:62.0/255.0 alpha:1.0];;
    //end
    //row six layout
    buttonBgView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0];
    sechduleInfoLbl.hidden = NO;
    sechduleInfoLbl.textColor = [UIColor whiteColor];
    [confirmTimeBtn setTitle:@"I Have Parked" forState:UIControlStateNormal];
    rejectTimeBtn.userInteractionEnabled = YES;
    confirmTimeBtn.userInteractionEnabled = YES;
    rejectTimeBtn.alpha = 1.0f;
    confirmTimeBtn.alpha = 1.0f;
    
    if ([[dataDict objectForKey:@"installation_type"] isEqualToString:@"Workshop"])
    {
        rejectTimeBtn.userInteractionEnabled = NO;
        confirmTimeBtn.userInteractionEnabled = NO;
        rejectTimeBtn.alpha = 0.5f;
        confirmTimeBtn.alpha = 0.5f;
    }
    else
    {
        if ([[dataDict objectForKey:@"car_owner_status"] isEqualToString:@"Parked"])
        {
//            rejectTimeBtn.alpha = 0.5f;
//            rejectTimeBtn.userInteractionEnabled = NO;
            [confirmTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [confirmTimeBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
            confirmTimeBtn.enabled = NO;
            confirmTimeBtn.alpha = .6;
        }
        else
        {
            [confirmTimeBtn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [confirmTimeBtn setBackgroundImage:[UIImage imageNamed:@"WhiteParked"] forState:UIControlStateNormal];
        }
    }
    
    [rejectTimeBtn setTitle:@"Emergency Cancel" forState:UIControlStateNormal];
    [rejectTimeBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    //end
}
#pragma mark - end

#pragma mark - Display data on cell objects
- (void)displayData :(NSDictionary *)dataDict
{
    dashboardAshButton.hidden=YES;
    [self showBachgroundViews];
    myDelegate.methodName = @" installerSummaryCell displayData line: 199";
    waitingStatusLbl.hidden = YES;
    NSString *status =[dataDict objectForKey:@"job_status"];
    //    status = @"waiting";
    if ([status isEqualToString:@"Scheduled"])
    {
        rejectTimeBtn.enabled = YES;
        confirmTimeBtn.enabled = YES;
        rejectTimeBtn.alpha = 1;
        confirmTimeBtn.alpha = 1;
        if ([[dataDict objectForKey:@"schedule_status"] isEqualToString:@"Pending"])
        {
            [self layoutBeforeConfirmation];
            
        }
        else if ([[dataDict objectForKey:@"schedule_status"] isEqualToString:@"Rejected"])
        {
            rejectTimeBtn.enabled = NO;
            confirmTimeBtn.enabled = NO;
            rejectTimeBtn.alpha = .6;
            confirmTimeBtn.alpha = .6;
            [self layoutBeforeConfirmation];
        }
        else
        {
            [self layoutAfterConfirmation:dataDict];
            
            if ([[dataDict objectForKey:@"is_today"]intValue]==1)
            {
                confirmTimeBtn.hidden = NO;
                rejectTimeBtn.hidden = NO;
                dashboardAshButton.hidden=NO;
                sechduleInfoLbl.hidden = NO;
//                NSLog(@"installation status is --------------------------------------------------------- %@",[dataDict objectForKey:@"status"]);
                sechduleInfoLbl.text = [dataDict objectForKey:@"status"];
            }
            else
            {
                dashboardAshButton.hidden=YES;
                sechduleInfoLbl.hidden = YES;
                confirmTimeBtn.hidden = YES;
                rejectTimeBtn.hidden = YES;
            }
        }
        myDelegate.methodName = @" installerSummaryCell displayData line: 241";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:[dataDict objectForKey:@"scheduled_time"]];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
        NSString *dateStr  = [formatter stringFromDate:date];
        NSArray *timeArray = [dateStr componentsSeparatedByString:@" "];
        
        nameLbl.text = [dataDict objectForKey:@"name"];
        timeLbl.text=@"";
        @try {
            dateLbl.text = [timeArray objectAtIndex:0];
            userContact.text = [dataDict objectForKey:@"phone_number"];
            myDelegate.methodName = @" installerSummaryCell displayData line: 254";
            timeLbl.text = [NSString stringWithFormat:@"%@ %@",[timeArray objectAtIndex:1],[timeArray objectAtIndex:2]];
            
        } @catch (NSException *exception) {
//            NSLog(@"exception is %@",exception);
        }
    }
    else if ([status isEqualToString:@"Completed"])
    {
        [self layoutBeforeConfirmation];
        [self hideBachgroundViews];
        _installationStatusLbl.hidden = NO;
        _noteLbl.hidden = NO;
        _installationStatusLbl.textColor = [UIColor colorWithRed:27.0/255.0 green:214.0/255.0 blue:190.0/255.0 alpha:1.0];
        _noteLbl.textColor = [UIColor colorWithRed:27.0/255.0 green:214.0/255.0 blue:190.0/255.0 alpha:1.0];
        _installationStatusLbl.text = @"Installation is completed.";
        _noteLbl.text = @"Please upload the photos of installed stickers";
        installationSuccessView.hidden = NO;
        installationFailedVIew.hidden = YES;
        
    }
    else if ([status isEqualToString:@"Cancelled"])
    {
        [self layoutBeforeConfirmation];
        [self hideBachgroundViews];
        _installationStatusLbl.hidden = NO;
        _noteLbl.hidden = NO;
        _installationStatusLbl.textColor = [UIColor colorWithRed:223.0/255.0 green:64.0/255.0 blue:63.0/255.0 alpha:1.0];
        _noteLbl.textColor = [UIColor colorWithRed:223.0/255.0 green:64.0/255.0 blue:63.0/255.0 alpha:1.0];
        _installationStatusLbl.text = @"Installation Error";
        _noteLbl.text = @"Please call/chat with Adogo for more information";
        installationSuccessView.hidden = YES;
        installationFailedVIew.hidden = NO;
    }
    else if([status isEqualToString:@""]||[status isEqualToString:@"waiting"])
    {
        [self hideBachgroundViews];
        _installationStatusLbl.hidden = YES;
        _noteLbl.hidden = YES;
        installationSuccessView.hidden = YES;
        installationFailedVIew.hidden = YES;
        rejectTimeBtn.enabled = NO;
        confirmTimeBtn.enabled = NO;
        waitingStatusLbl.hidden = NO;
    }
}

- (void)hideBachgroundViews
{
    InstallerSummaryBgView.hidden = YES;
    installerNameBgView.hidden = YES;
    ScheduledDateBgView.hidden = YES;
    contactBgView.hidden = YES;
    ProposedTimeBgView.hidden = YES;
    buttonBgView.hidden = YES;
    
}

- (void)showBachgroundViews
{
    _installationStatusLbl.hidden = YES;
    _noteLbl.hidden = YES;
    installationFailedVIew.hidden = YES;
    installationSuccessView.hidden=YES;
    InstallerSummaryBgView.hidden = NO;
    installerNameBgView.hidden = NO;
    ScheduledDateBgView.hidden = NO;
    contactBgView.hidden = NO;
    ProposedTimeBgView.hidden = NO;
    buttonBgView.hidden = NO;
    
}
#pragma mark - end
@end
