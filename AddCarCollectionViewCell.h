//
//  AddCarCollectionViewCell.h
//  Adogo
//
//  Created by Ranosys on 02/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBorderView.h"

@protocol AFNetworkingDonwloadDelegate<NSObject>
@optional
- (void) downloadingCompleted:(UIImage *)mymage imageType:(NSString *)imageType;

@end

@interface AddCarCollectionViewCell : UICollectionViewCell {
    id <AFNetworkingDonwloadDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UILabel *imageType;
@property (strong, nonatomic) IBOutlet LBorderView *addOptionalCar;

- (void)displayData:(int)index data:(NSMutableDictionary*)data isEditMode:(BOOL)isEditCar;
@end
