//
//  CamapignEndedViewCell.h
//  Adogo
//
//  Created by Hema on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBorderView.h"

@interface CamapignEndedViewCell : UICollectionViewCell

//firstCell
@property (weak, nonatomic) IBOutlet UIImageView *odometerPhotoView;
@property (weak, nonatomic) IBOutlet LBorderView *odometerPhototBtn;
@property (weak, nonatomic) IBOutlet UILabel *odometerPhotoLabel;
@property (strong, nonatomic) IBOutlet UIButton *warningButton;
@end
