//
//  Internet.m
//  RKPharma
//
//  Created by shiv vaishnav on 16/05/13.
//  Copyright (c) 2013 shivendra@ranosys.com. All rights reserved.
//

#import "Reachability.h"
#import "Internet.h"
#import "SCLAlertView.h"

@implementation Internet
{
    Reachability *reachability;
}

-(BOOL) start 
{
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:nil title:@"Connection Error" subTitle:@"Please check your internet connection." closeButtonTitle:@"OK" duration:0.0f];
        return YES;
    }
    else
    {
        return NO;
    }
}
@end
