//
//  CarImageCollectionViewCell.h
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBorderView.h"

@interface CarImageCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UILabel *imageType;
@property (strong, nonatomic) IBOutlet LBorderView *addOptionalCar;

- (void)displayData:(int)index data:(NSMutableDictionary*)data;
@end
