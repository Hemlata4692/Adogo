//
//  CarDetailTableViewCell.m
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarDetailTableViewCell.h"
@implementation CarDetailTableViewCell
@synthesize carImageCollectionView, carModel, carDetailTitle, carDetailresult, addCarRouteBtn, carDimensionBtn;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Display car detail data on cell
- (void)displayCarDetailData:(NSMutableDictionary *)data section:(int)section row:(int)row {
    
    if (section == 0) {
        if (row == 1) {
            carDetailTitle.text = @"Brand";
            carDetailresult.text = [data objectForKey:@"brand"];
        }
        else if (row == 2) {
            carDetailTitle.text = @"Model";
            carDetailresult.text = [data objectForKey:@"model"];
        }
        else if (row == 3) {
            carDetailTitle.text = @"Car Color";
            carDetailresult.text = [data objectForKey:@"color"];
        }
        else if (row == 4) {
            carDetailTitle.text = @"Plate No.";
            carDetailresult.text = [data objectForKey:@"plate_number"];
        }
        else if (row == 5) {
            carDetailTitle.text = @"Vehicle Type";
            carDetailresult.text = [data objectForKey:@"car_type"];
        }
    }
    else {
        if (row == 0) {
            carDetailTitle.text = @"Car Owner Name";
            carDetailresult.text = [data objectForKey:@"owner_name"];
        }
        else if (row == 1) {
            carDetailTitle.text = @"Car Owner NRIC No.";
            carDetailresult.text = [data objectForKey:@"owner_nric"];
        }
    }
}
#pragma mark - end

#pragma mark - Display car button
- (void)displayCarButtonData:(NSMutableDictionary *)data section:(int)section row:(int)row isAdminCar:(BOOL)isAdminCar {
    
    if (isAdminCar){
        carDimensionBtn.hidden = NO;
        addCarRouteBtn.hidden = NO;
        addCarRouteBtn.translatesAutoresizingMaskIntoConstraints = YES;
        carDimensionBtn.translatesAutoresizingMaskIntoConstraints = YES;
        
        addCarRouteBtn.frame = CGRectMake(8, 8, ([[UIScreen mainScreen] bounds].size.width / 2) - 8 - 1, 46);
        carDimensionBtn.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) + 1, 8, ([[UIScreen mainScreen] bounds].size.width / 2) - 8 - 1, 46);
        if ([[UIScreen mainScreen] bounds].size.height > 580) {
            [addCarRouteBtn.titleLabel setFont:[UIFont railwayRegularWithSize:17] ];
            [carDimensionBtn.titleLabel setFont:[UIFont railwayRegularWithSize:17] ];
        }
        else {
            [addCarRouteBtn.titleLabel setFont:[UIFont railwayRegularWithSize:15] ];
            [carDimensionBtn.titleLabel setFont:[UIFont railwayRegularWithSize:15] ];
        }
    }
    else {
        carDimensionBtn.hidden = YES;
        addCarRouteBtn.hidden = NO;
        addCarRouteBtn.frame = CGRectMake(20, 8, ([[UIScreen mainScreen] bounds].size.width / 2) - 40, 46);
        [addCarRouteBtn.titleLabel setFont:[UIFont railwayRegularWithSize:17] ];
    }
}
#pragma mark - end
@end