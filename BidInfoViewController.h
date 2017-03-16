//
//  BidInfoViewController.h
//  Adogo
//
//  Created by Ranosys on 12/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BidInfoViewController : GlobalBackViewController

@property(nonatomic, assign)BOOL isBidExist;
@property(nonatomic, retain)NSString *bidId;
@property(nonatomic, retain)NSString *carId;
@property(nonatomic, retain)NSString *signatureImageName;
@property (nonatomic, retain)UIImage *signatureImage;
@property (nonatomic,assign)long long hours;
@property (nonatomic,assign)long long minutes;
@property (nonatomic,assign)long long seconds;
@property(nonatomic,retain)NSTimer* bidTimer;
@property(nonatomic,assign)BOOL isTimeEnd;
@end
