//
//  ForgotPasswordVerificationViewController.h
//  Adogo
//
//  Created by Sumit on 27/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordVerificationViewController : GlobalBackViewController
@property(retain,nonatomic)NSString *emailId;
@property(retain,nonatomic)NSString *verificationPin;
@property(retain,nonatomic)NSString *mobileNumber;
@end
