//
//  BiddingCell.h
//  Adogo
//
//  Created by Sumit on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BiddingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *noAdLbl;
@property (weak, nonatomic) IBOutlet UILabel *noAdInfoLbl;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
- (void)displayData : (NSString *)status;
@end
