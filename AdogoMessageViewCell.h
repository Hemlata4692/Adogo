//
//  AdogoMessageViewCell.h
//  Adogo
//
//  Created by Ranosys on 05/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdogoMessageViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *adogoIcon;
@property (strong, nonatomic) IBOutlet UILabel *agentName;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *adogoSentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *adogoSentImage;

- (void)changeDisplayFraming:(NSMutableDictionary *)data;
@end
