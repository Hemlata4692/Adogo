//
//  BidInfoCollectionViewCell.h
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BidInfoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UILabel *carType;
- (void)displayData:(int)index data:(NSMutableDictionary*)data;
@end
