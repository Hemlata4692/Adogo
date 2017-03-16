//
//  CarDetailViewController.h
//  Adogo
//
//  Created by Ranosys on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarDetailViewController : GlobalBackViewController

@property (strong, nonatomic) IBOutlet UITableView *carDetailTableView;
@property (nonatomic, assign) NSString *carId;
@property (nonatomic, strong) NSString *carModel;
@property (nonatomic, assign) BOOL isApprovedCarDetail;
@end
