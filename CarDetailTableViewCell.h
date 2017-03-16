//
//  CarDetailTableViewCell.h
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarDetailTableViewCell : UITableViewCell

//Car image cell variables
@property (strong, nonatomic) IBOutlet UICollectionView *carImageCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *carModel;
//end
//Car detail cell variables
@property (strong, nonatomic) IBOutlet UILabel *carDetailTitle;
@property (strong, nonatomic) IBOutlet UILabel *carDetailresult;
//end
//Button cell variables
@property (strong, nonatomic) IBOutlet UIButton *addCarRouteBtn;
@property (strong, nonatomic) IBOutlet UIButton *carDimensionBtn;
//end
- (void)displayCarDetailData:(NSMutableDictionary *)data section:(int)section row:(int)row;
- (void)displayCarButtonData:(NSMutableDictionary *)data section:(int)section row:(int)row isAdminCar:(BOOL)isAdminCar;
@end
