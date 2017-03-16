//
//  BidPreviewCell.h
//  Adogo
//
//  Created by Ranosys on 20/10/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BidPreviewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *previewTitle;
@property (strong, nonatomic) IBOutlet UILabel *previewDetail;
@property (strong, nonatomic) IBOutlet UILabel *previewSeparator;
@property (strong, nonatomic) IBOutlet UIImageView *previewSignatureImage;
@property (strong, nonatomic) IBOutlet UILabel *TermConditionLabel;

@end
