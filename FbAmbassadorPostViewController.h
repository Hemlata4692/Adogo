//
//  FbAmbassadorPostViewController.h
//  Adogo
//
//  Created by Ranosys on 30/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmbassadorHistoryViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FbAmbassadorPostViewController : UIViewController
//previousScreen = 0 //From remote notification
//previousScreen = 1 //From dashboard
//previousScreen = 2 //From list
@property(nonatomic, assign) int previousScreen;
@property(nonatomic, assign) int numberOfPost;
@property(nonatomic, retain)NSString *ambassadorId;
@property(nonatomic, retain)NSString *startDateTime;
@property(nonatomic, retain)NSString *endDateTime;
@property(nonatomic, retain)NSString *imageUrl;
@property(nonatomic, retain)NSString *content;
@property(nonatomic, retain)NSString *shareTitleText;
@property(nonatomic, retain)NSString *sharedUrl;
@property(nonatomic, retain)AmbassadorHistoryViewController *ambassadorHistoryObj;
@property(nonatomic, assign) long long seconds;

- (void)setTimerValue:(NSNumber*)timeInSecond;
@end
