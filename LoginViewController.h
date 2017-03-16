//
//  ViewController.h
//  Adogo
//
//  Created by Sumit on 14/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : GlobalBackViewController

@property(nonatomic, retain) NSString *loginEmailId;
@property(nonatomic, retain) NSString *loginName;
@property(nonatomic, retain) NSString *faceBookId;
@property(nonatomic, retain) NSString *facebookImageUrl;
@property(nonatomic, retain) NSString *mobileNo;
@property(nonatomic, retain) NSString *mobileCode;
@property(nonatomic, retain) NSString *passwordString;
@property(nonatomic, assign) BOOL termsConditionSelected;
@end

