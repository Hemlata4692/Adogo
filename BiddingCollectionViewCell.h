//
//  BiddingCollectionViewCell.h
//  Adogo
//
//  Created by Sumit on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BiddingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIImageView *biddingImage;
@property (weak, nonatomic) IBOutlet UILabel *bidName;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBidBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *rejectionReasonLbl;
@property (weak, nonatomic) IBOutlet UILabel *bidRejectedLbl;
- (void)dispalyData : (NSDictionary *)dataDict count:(int)count;
@end
