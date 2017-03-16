//
//  BeaconCell.m
//  Adogo
//
//  Created by Sumit on 12/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BeaconCell.h"

@implementation BeaconCell
@synthesize uuidLabel;
@synthesize majorValueLabel;
@synthesize minorValueLabel;
@synthesize distanceLabel;
@synthesize selectBeaconRadioButton;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Display data on cell objects
- (void)displayData : (ABBeacon *)beacon selectedId:(NSString *)selectedId
{
    
   uuidLabel.text = [beacon.proximityUUID UUIDString];
    majorValueLabel.text = [NSString stringWithFormat:@"Major: %@",beacon.major];
    minorValueLabel.text = [NSString stringWithFormat:@"Minor: %@",beacon.minor];
    distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f",[beacon.distance floatValue]];
    
    if ([selectedId isEqualToString:[NSString stringWithFormat:@"%@.%@.%@",[beacon.proximityUUID UUIDString],[NSString stringWithFormat:@"%@",beacon.major],[NSString stringWithFormat:@"%@",beacon.minor]]])
    {
        [selectBeaconRadioButton setSelected:YES];
    }
    else
    {
        [selectBeaconRadioButton setSelected:NO];
    }
}
#pragma mark - end
@end
