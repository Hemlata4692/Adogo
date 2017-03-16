//
//  CarRouteTableViewCell.h
//  Adogo
//
//  Created by Monika on 03/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarRouteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cellContainerView;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationToLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToLabel;
@property (weak, nonatomic) IBOutlet UIView *locationFromView;
@property (weak, nonatomic) IBOutlet UIView *locationToView;
@property (weak, nonatomic) IBOutlet UIView *timeFromView;
@property (weak, nonatomic) IBOutlet UIView *timeToView;
@property (strong, nonatomic) IBOutlet UIButton *editDetailsButton;
@end
