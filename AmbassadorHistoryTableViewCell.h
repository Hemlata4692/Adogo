//
//  AmbassadorHistoryTableViewCell.h
//  Adogo
//
//  Created by Monika on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmbassadorHistoryTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *repostButton;
@property (strong, nonatomic) IBOutlet UIImageView *shareIcon;

- (void)displayData:(NSMutableDictionary *)data currentDateStr:(NSString *)currentDateStr isDashBoard:(BOOL)isDashBoard;
@end
