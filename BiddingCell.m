//
//  BiddingCell.m
//  Adogo
//
//  Created by Sumit on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BiddingCell.h"

@implementation BiddingCell
@synthesize noAdLbl;
@synthesize noAdInfoLbl;
@synthesize collectionView;
@synthesize adImage;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Display data on cell objects
- (void)displayData : (NSString *)status
{
    myDelegate.methodName = @" BiddingCell displayData line: 30";
    if ([status intValue]==1 || [status intValue]==0)
    {
//        NSLog(@"image is %@",[UserDefaultManager getValue:@"bidBanner"]);
        if ([[UserDefaultManager getValue:@"bidBanner"] isEqualToString:@""]||[UserDefaultManager getValue:@"bidBanner"]==nil || [UserDefaultManager getValue:@"bidBanner"]==NULL) {
            
            NSAttributedString * str = [[NSString stringWithFormat:@"Click on the floating TRACK button to update your car route for new campaign OR more campaign."] setAttributrdString:@"TRACK" stringFont:[UIFont railwayRegularWithSize:15] selectedColor:[UIColor colorWithRed:74.0/255.0 green:236.0/255.0 blue:204.0/255.0 alpha:1.0]];
            noAdInfoLbl.attributedText = str;
            self.noAdInfoLbl.hidden = NO;
            adImage.hidden = YES;
            self.noAdLbl.hidden= NO;
            
        }
        else{
            adImage.hidden = NO;
            self.noAdLbl.hidden= YES;
            __weak UIImageView *weakRef = adImage;
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[UserDefaultManager getValue:@"bidBanner"]]
                                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            
            [adImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"carPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakRef.image = image;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
            
            self.noAdInfoLbl.hidden = YES;
        }
        
        self.collectionView.hidden = YES;
        
        
    }
    else if ([status intValue]==100)
    {
        self.noAdInfoLbl.textColor = [UIColor colorWithRed:((float) 173 / 255.0f) green:((float) 62 / 255.0f) blue:((float) 68 / 255.0f) alpha:1.0f];
        self.noAdInfoLbl.font = [UIFont railwayRegularWithSize:15];
        self.noAdInfoLbl.hidden = NO;
        self.noAdInfoLbl.textAlignment = NSTextAlignmentCenter;
        noAdInfoLbl.numberOfLines = 0;

        
        noAdInfoLbl.attributedText=[[NSString stringWithFormat:@"Car with plate number %@ waiting for installer to schedule job for campaign %@.",[UserDefaultManager getValue:@"defaultCarPlatNumber"],[UserDefaultManager getValue:@"campaignName"]] setNestedAttributrdString:[UserDefaultManager getValue:@"defaultCarPlatNumber"] secondSelectedString:[UserDefaultManager getValue:@"campaignName"] stringFont:[UIFont railwayBoldWithSize:13] selectedColor:[UIColor colorWithRed:((float) 173 / 255.0f) green:((float) 62 / 255.0f) blue:((float) 68 / 255.0f) alpha:1.0f]];
//        noAdInfoLbl.attributedText = attstr;
    }
    else if([status intValue]==2)
    {
        self.collectionView.hidden = NO;
        self.noAdLbl.hidden= YES;
        self.noAdInfoLbl.hidden = YES;
    }
    //Click on the floating TRACK button to update your car route for new campaign OR more campaign.
}
#pragma mark - end
@end
