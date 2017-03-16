//
//  AddNewCarViewController.h
//  Adogo
//
//  Created by Ranosys on 29/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewCarViewController : GlobalBackViewController

@property (nonatomic, assign) BOOL isEditCar;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, assign) int carCount;
@property (nonatomic, strong) NSMutableDictionary *carDetail;
@property (nonatomic, strong) NSMutableDictionary *carImageFromDetail;
@property (nonatomic, assign) BOOL isCarListing;
@end
