//
//  AddCarDimensionViewController.h
//  Adogo
//
//  Created by Ranosys on 10/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCarDimensionViewController : GlobalBackViewController

@property(nonatomic,strong) NSMutableDictionary *dimensionDetail;
@property(nonatomic,strong) NSString *carId;
@property(nonatomic,strong) NSString *isUpdatedText;
@property(nonatomic,assign) int flag;
@property(nonatomic,assign) BOOL isOtherExist;
@end
