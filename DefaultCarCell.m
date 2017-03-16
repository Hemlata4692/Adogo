//
//  DefaultCarCell.m
//  Adogo
//
//  Created by Sumit on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "DefaultCarCell.h"

@implementation DefaultCarCell
@synthesize carImage;
@synthesize carModelLbl;
@synthesize carRegistrationLbl;
@synthesize defaultCarBtn;
@synthesize distanceInfoLbl;
@synthesize warningLbl;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Display data on default cell objects
- (void)displayData:(NSDictionary *)dataDict
{
    defaultCarBtn.layer.cornerRadius = 3;
    defaultCarBtn.layer.borderWidth = 1.0;
    defaultCarBtn.layer.borderColor = [UIColor colorWithRed:56.0/255.0 green:192.0/255.0 blue:182.0/255.0 alpha:1.0].CGColor;
    myDelegate.methodName = @" CarCell displayData line: 77";
    if (dataDict.count>0)
    {
        defaultCarBtn.hidden = NO;
        carModelLbl.text =[NSString stringWithFormat:@"%@ %@",[dataDict objectForKey:@"brand"],[dataDict objectForKey:@"model"]];;
        carRegistrationLbl.text =[dataDict objectForKey:@"plate_number"];
        if (![[dataDict objectForKey:@"is_measurement_approved"] boolValue])
        {
            warningLbl.hidden = NO;
            warningLbl.font = [UIFont railwayRegularWithSize:12];
            warningLbl.text = [dataDict objectForKey:@"car_measurement_message"];
        
        }
        if (([[dataDict objectForKey:@"since_date"] isEqualToString:@""] || [[dataDict objectForKey:@"total_distance_travelled"] isEqualToString:@""]))
        {
            distanceInfoLbl.text = @"This car is not added in any campaign yet.";
        }
        else
        {
//            NSAttributedString * str = [[NSString stringWithFormat:@"Total distance travelled %@ since %@",[dataDict objectForKey:@"total_distance_travelled"],[self formateDate:[dataDict objectForKey:@"since_date"]]] setAttributrdString:[dataDict objectForKey:@"total_distance_travelled"] stringFont:[UIFont railwayBoldWithSize:16] selectedColor:[UIColor colorWithRed:74.0/255.0 green:236.0/255.0 blue:204.0/255.0 alpha:1.0]];
//            
//            str = [[NSString stringWithFormat:@"Total distance travelled %@ KM since %@",[dataDict objectForKey:@"total_distance_travelled"],[self formateDate:[dataDict objectForKey:@"since_date"]]] setAttributrdString:[self formateDate:[dataDict objectForKey:@"since_date"]] stringFont:[UIFont railwayBoldWithSize:14] selectedColor:[UIColor colorWithRed:74.0/255.0 green:236.0/255.0 blue:204.0/255.0 alpha:1.0]];
            
            
            distanceInfoLbl.attributedText=[[NSString stringWithFormat:@"Total distance travelled %@ since %@",[dataDict objectForKey:@"total_distance_travelled"],[self formateDate:[dataDict objectForKey:@"since_date"]]] setNestedAttributrdString:[dataDict objectForKey:@"total_distance_travelled"] secondSelectedString:[self formateDate:[dataDict objectForKey:@"since_date"]] stringFont:[UIFont railwayBoldWithSize:14] selectedColor:[UIColor colorWithRed:74.0/255.0 green:236.0/255.0 blue:204.0/255.0 alpha:1.0]];
            
//            distanceInfoLbl.attributedText = str;
        }
        
        __weak UIImageView *weakRef = carImage;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[dataDict objectForKey:@"image"]]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [carImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    else
    {
        _lblBgView.hidden = NO;
        warningLbl.hidden = NO;
        warningLbl.text = @"Please add any car.";
        defaultCarBtn.hidden = YES;
    }
    //end
}
#pragma mark - end

#pragma mark - Date formatting
-(NSString*)formateDate:(NSString *)dateStr
{
    myDelegate.methodName = @" CarCell formateDate line: 89";
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [formatter setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}
#pragma mark - end
@end
