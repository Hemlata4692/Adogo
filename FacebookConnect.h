//
//  FacebookConnect.h
//  Adogo
//
//  Created by Ranosys on 12/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@protocol FacebookDelegate <NSObject>
@optional
- (void) facebookLoginWithReadPermissionResponse:(id)fbResult status:(int)status;
@end

@interface FacebookConnect : NSObject{
    id <FacebookDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

- (void)facebookLoginWithReadPermission:(UIViewController *)selfVC;
@end
