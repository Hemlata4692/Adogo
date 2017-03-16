//
//  DriverMessageViewCell.h
//  Adogo
//
//  Created by Ranosys on 05/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverMessageViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *driverSentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *driverSentImage;

- (void)changeDriverDisplayFraming:(NSMutableDictionary *)data;
@end
