//
//  BeaconCell.h
//  Adogo
//
//  Created by Sumit on 12/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AprilBeaconSDK.h>
@interface BeaconCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBeaconRadioButton;

- (void)displayData : (ABBeacon *)beacon selectedId:(NSString *)selectedId;
@end
