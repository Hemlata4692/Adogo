//
//  InstalledStickerCollectionViewCell.m
//  Adogo
//
//  Created by Ranosys on 19/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "InstalledStickerCollectionViewCell.h"

@implementation InstalledStickerCollectionViewCell
@synthesize imagePickerBtn, pickedCarImage, pickedCarLabel, addMoreBtn;

#pragma mark - Display data on cell objects
- (void)displayData:(NSMutableDictionary *)data {
    
    imagePickerBtn.enabled = NO;
    addMoreBtn.enabled = NO;
    if ([[data objectForKey:@"isSet"] isEqualToString:@"false"]) {
        
        [self showButtonPlaceHolderImages:imagePickerBtn label:pickedCarLabel];
        pickedCarImage.hidden = YES;
    }
    else {
        
        [self hideButtonPlaceHolderImages:imagePickerBtn label:pickedCarLabel];
        pickedCarImage.hidden = NO;
        pickedCarImage.image = [data objectForKey:@"image"];
    }
}

- (void)displayData {
    
    imagePickerBtn.enabled = NO;
    addMoreBtn.enabled = NO;
}
#pragma mark - end

#pragma mark - Hide show placeholder NRIC button
- (void)hideButtonPlaceHolderImages:(LBorderView*)btn label:(UILabel*)label {
    
    btn.dashPattern = 0;
    btn.spacePattern = 0;
    btn.borderWidth = 0;
    btn.cornerRadius = 3;
    btn.borderColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateDisabled];
    label.hidden = YES;
}

- (void)showButtonPlaceHolderImages:(LBorderView*)btn label:(UILabel*)label {
    
    btn.borderType = BorderTypeDashed;
    btn.dashPattern = 2;
    btn.spacePattern = 2;
    btn.borderWidth = 0.5;
    btn.cornerRadius = 3;
    btn.borderColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5f];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateDisabled];
    label.hidden = NO;
}
#pragma mark - end
@end
