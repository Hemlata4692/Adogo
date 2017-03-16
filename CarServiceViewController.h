//
//  CarServiceViewController.h
//  Adogo
//
//  Created by Hema on 26/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedemptionViewController.h"

@interface CarServiceViewController : UIViewController

@property (nonatomic,strong) NSString *productId;
@property (nonatomic,strong) NSString *productType;
@property (nonatomic,retain) NSString *availablePoints;
@property (nonatomic,retain) RedemptionViewController *redeemViewObject;
@end
