//
//  GlobalPopupViewController.h
//  Adogo
//
//  Created by Monika on 11/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupViewDelegate <NSObject>
@optional
- (void)popupViewDelegateMethod:(int)option reasonText:(NSString *)reasonText;
@end

@interface GlobalPopupViewController : UIViewController
{
    id <PopupViewDelegate> _delegate;
}
@property (nonatomic,strong) id <PopupViewDelegate>delegate;

//PopupTitle
@property (nonatomic, assign) NSString *popupTitle;
@property (nonatomic, assign) BOOL isAppSetting;
@property (nonatomic, retain) NSString *trackingMethod;
@property (nonatomic, retain) NSString *reasonPrifillText;
@end

