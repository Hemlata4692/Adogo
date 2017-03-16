//
//  AmbassadorHistoryViewController.h
//  Adogo
//
//  Created by Monika on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface AmbassadorHistoryViewController : AdogoViewController
@property(nonatomic, assign)bool isDashBoard;
@property(nonatomic, assign)bool isPosted;
@property(nonatomic, retain) NSMutableArray *ambassadorHistoryArray;
@property(nonatomic, retain) NSString *currentDate;
@property(nonatomic, retain) NSTimer *hitoryTimer;
@end
