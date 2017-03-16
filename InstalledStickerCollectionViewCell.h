//
//  InstalledStickerCollectionViewCell.h
//  Adogo
//
//  Created by Ranosys on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBorderView.h"

@interface InstalledStickerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet LBorderView *imagePickerBtn;
@property (strong, nonatomic) IBOutlet UILabel *pickedCarLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pickedCarImage;
@property (strong, nonatomic) IBOutlet UIButton *addMoreBtn;

- (void)displayData:(NSMutableDictionary *)data;
- (void)displayData;
@end
