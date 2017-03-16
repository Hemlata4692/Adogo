//
//  AmbassadorHistoryTableViewCell.m
//  Adogo
//
//  Created by Monika on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AmbassadorHistoryTableViewCell.h"

@implementation AmbassadorHistoryTableViewCell
@synthesize repostButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Display data and frame customiztion of cell objects
- (void)displayData:(NSMutableDictionary *)data currentDateStr:(NSString *)currentDateStr isDashBoard:(BOOL)isDashBoard
{
    [repostButton setViewBorder:repostButton color:[UIColor whiteColor]];
    
    _notificationLabel.translatesAutoresizingMaskIntoConstraints=YES;
    
    NSString *noteStr =[data objectForKey:@"post_content"];
    
    _notificationLabel.text=noteStr;
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 75,500);
    CGRect textRect = [_notificationLabel.text
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont railwayRegularWithSize:12]}
                       context:nil];
    _notificationLabel.numberOfLines = 0;
    _notificationLabel.frame = textRect;
    _notificationLabel.frame =CGRectMake(67,10,self.contentView.frame.size.width - 75, textRect.size.height);
    
    if (isDashBoard) {
        _timeLabel.hidden = YES;
        _timeLabel.text = @"";
        [repostButton setTitle:@"Post" forState:UIControlStateNormal];
    }
    else {
        [repostButton setTitle:@"Repost" forState:UIControlStateNormal];
        _timeLabel.hidden = NO;
        long noOfDays = [self getDurationInDays:[data objectForKey:@"created_at"] end:currentDateStr];
        
        if (noOfDays == 1)
        {
            _timeLabel.text = [NSString stringWithFormat:@"%ld day ago",noOfDays];
        }
        else if (noOfDays > 1)
        {
            _timeLabel.text = [NSString stringWithFormat:@"%ld days ago",noOfDays];
        }
        else
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
            NSDate *fromDateTime = [dateFormatter dateFromString:[data objectForKey:@"created_at"]];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            _timeLabel.text = [dateFormatter stringFromDate:fromDateTime] ;
            
        }
    }
}
#pragma mark - end

#pragma mark - Get day duration b/w two date/time
-(int)getDurationInDays:(NSString *)start end :(NSString *)end
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
    NSDate *startDate = [dateFormatter dateFromString:start];
    NSDate *endDate = [dateFormatter dateFromString:end];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:NSCalendarWrapComponents];
//    NSLog(@"Number of days %ld",(long)components.day);
    return (int)components.day;
}
#pragma mark - end
@end
