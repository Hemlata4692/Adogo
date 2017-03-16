//
//  FacebookConenctPopViewController.h
//  Adogo
//
//  Created by Ranosys on 13/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FacebookConenctPopupViewDelegate <NSObject>
@optional
- (void)facebookConenctPopupViewDelegateMethod:(int)option;
@end

@interface FacebookConenctPopViewController : UIViewController
{
    id <FacebookConenctPopupViewDelegate> _delegate;
}
@property (nonatomic,strong) id <FacebookConenctPopupViewDelegate>delegate;

@property (nonatomic, assign) NSString *popupTitle;
@end
