//
//  FacebookConnect.m
//  Adogo
//
//  Created by Ranosys on 12/07/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "FacebookConnect.h"

@implementation FacebookConnect

#pragma mark - Facebook login with read permission
- (void)facebookLoginWithReadPermission:(UIViewController *)selfVC {

    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:selfVC
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [_delegate facebookLoginWithReadPermissionResponse:result status:2];
             //NSLog(@"Process error");
         } else if (result.isCancelled) {
             [_delegate facebookLoginWithReadPermissionResponse:result status:3];
             //NSLog(@"Cancelled");
         } else {
             //NSLog(@"Logged in");
             
             NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
             //NSLog(@"fbAccessToken is %@", fbAccessToken);
             
             if ([FBSDKAccessToken currentAccessToken]) {
                 [myDelegate showIndicator];
                 [self fetchFBDataWithReadPermission];
             }
         }
     }];
}

- (void)fetchFBDataWithReadPermission
{
    NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    //NSLog(@"fbAccessToken is %@", fbAccessToken);
    
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                       parameters:@{@"fields": @"picture.type(large), email, name"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             //NSLog(@"result is %@", result);
             [_delegate facebookLoginWithReadPermissionResponse:result status:1];
         }
         else{
              [_delegate facebookLoginWithReadPermissionResponse:result status:2];
             //NSLog(@"%@", [error localizedDescription]);
         }
     }];
}
#pragma mark - end
@end
