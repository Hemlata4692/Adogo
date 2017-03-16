/*
 *
 *  ChatStyling.m
 *  ZDCChat
 *
 *  Created by Zendesk on 03/12/2014.
 *
 *  Copyright (c) 2015 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zopim Chat SDK, You agree to the Zendesk Terms
 *  of Service https://www.zendesk.com/company/terms and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/application-developer-and-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Chat SDK.
 *
 */

#import "ChatStyling.h"

@implementation ChatStyling

+ (void) applyStyling
{
    UIEdgeInsets insets;

    // Configuring the chat widget/overlay
    [[ZDCChat instance].overlay setEnabled:NO];
    [[ZDCChatOverlay appearance] setAlignment:@(ZDCOverlayAlignmentBottomLeft)];
    [[ZDCChatOverlay appearance] setInsets:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(75.0f, 15.0f, 15.0f, 15.0f)]];
    
    // Style the chat loading screen
    [[ZDCLoadingView appearance] setLoadingLabelFont:[UIFont boldSystemFontOfSize:12.0f]];
    [[ZDCLoadingView appearance] setLoadingLabelTextColor:[UIColor whiteColor]];
    [[ZDCLoadingView appearance] setLoadingBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    
    // Style loading errors/notifications
    [[ZDCLoadingErrorView appearance] setIconImage:nil]; // provide an image name to override default image
    [[ZDCLoadingErrorView appearance] setErrorBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    
    [[ZDCLoadingErrorView appearance] setTitleFont:[UIFont boldSystemFontOfSize:15.0f]];
    [[ZDCLoadingErrorView appearance] setTitleColor:[UIColor whiteColor]];
    [[ZDCLoadingErrorView appearance] setMessageFont:[UIFont systemFontOfSize:15.0f]];
    [[ZDCLoadingErrorView appearance] setMessageColor:[UIColor whiteColor]];
    [[ZDCLoadingErrorView appearance] setButtonFont:[UIFont boldSystemFontOfSize:15.0f]];
    [[ZDCLoadingErrorView appearance] setButtonTitleColor:[UIColor whiteColor]];
    [[ZDCLoadingErrorView appearance] setButtonBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0]]; //leave message
    [[ZDCLoadingErrorView appearance] setButtonImage:nil]; // provide an image name to override default image

    // Style the pre-chat form
    insets = UIEdgeInsetsMake(10.0f, 15.0f, 0.0f, 15.0f);
    [[ZDCFormCellSingleLine appearance] setTextFrameInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(5.0f, 15.0f, 5.0f, 15.0f);
    [[ZDCFormCellSingleLine appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCFormCellSingleLine appearance] setTextFrameBorderColor:[UIColor clearColor]];
    [[ZDCFormCellSingleLine appearance] setTextFrameBackgroundColor:[UIColor clearColor]];
    [[ZDCFormCellSingleLine appearance] setTextFrameCornerRadius:@(3.0f)];
    [[ZDCFormCellSingleLine appearance] setTextFont:[UIFont systemFontOfSize:13.0f]];
    [[ZDCFormCellSingleLine appearance] setTextColor:[UIColor clearColor]];
//    [[ZDCFormCellSingleLine appearance] setHidden:YES];

    insets = UIEdgeInsetsMake(10.0f, 15.0f, 0.0f, 15.0f);
    [[ZDCFormCellDepartment appearance] setTextFrameInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(5.0f, 15.0f, 5.0f, 15.0f);
    [[ZDCFormCellDepartment appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCFormCellDepartment appearance] setTextFrameBorderColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [[ZDCFormCellDepartment appearance] setTextFrameBackgroundColor:[UIColor whiteColor]];
    [[ZDCFormCellDepartment appearance] setTextFrameCornerRadius:@(3.0f)];
    [[ZDCFormCellDepartment appearance] setTextFont:[UIFont systemFontOfSize:13.0f]];
    [[ZDCFormCellDepartment appearance] setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];

    insets = UIEdgeInsetsMake(10.0f, 15.0f, 10.0f, 15.0f);
    [[ZDCFormCellMessage appearance] setTextFrameInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f);
    [[ZDCFormCellMessage appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCFormCellMessage appearance] setTextFrameBorderColor:[UIColor lightGrayColor]];
    [[ZDCFormCellMessage appearance] setTextFrameBackgroundColor:[UIColor clearColor]];
    [[ZDCFormCellMessage appearance] setTextFrameCornerRadius:@(3.0f)];
    [[ZDCFormCellMessage appearance] setTextFont:[UIFont systemFontOfSize:13.0f]];
    [[ZDCFormCellMessage appearance] setTextColor:[UIColor whiteColor]];

    // Style the chat cells
    insets = UIEdgeInsetsMake(10.0f, 70.0f , 10.0f, 20.0f);
    [[ZDCJoinLeaveCell appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCJoinLeaveCell appearance] setTextColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [[ZDCJoinLeaveCell appearance] setTextFont:[UIFont boldSystemFontOfSize:14]];

    insets = UIEdgeInsetsMake(8.0f, 75.0f , 7.0f, 15.0f);
    [[ZDCVisitorChatCell appearance] setBubbleInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(12.0f, 15.0f, 12.0f, 15.0f);
    [[ZDCVisitorChatCell appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCVisitorChatCell appearance] setBubbleBorderColor:[ChatStyling darkerColorForColor:[ChatStyling navBarTintColor] by:0.2f]];
    [[ZDCVisitorChatCell appearance] setBubbleColor:[ChatStyling navBarTintColor]];
    [[ZDCVisitorChatCell appearance] setBubbleCornerRadius:@(3.0f)];
    [[ZDCVisitorChatCell appearance] setTextAlignment:@(NSTextAlignmentLeft)];
    [[ZDCVisitorChatCell appearance] setTextColor:[ChatStyling navTintColor]];
    [[ZDCVisitorChatCell appearance] setTextFont:[UIFont systemFontOfSize:14.0f]];
    [[ZDCVisitorChatCell appearance] setUnsentTextColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [[ZDCVisitorChatCell appearance] setUnsentTextFont:[UIFont systemFontOfSize:12.0f]];
    [[ZDCVisitorChatCell appearance] setUnsentMessageTopMargin:@(5.0f)];
    [[ZDCVisitorChatCell appearance] setUnsentIconLeftMargin:@(10.0f)];

    insets = UIEdgeInsetsMake(8.0f, 55.0f, 7.0f, 30.0f);
    [[ZDCAgentChatCell appearance] setBubbleInsets:[NSValue valueWithUIEdgeInsets:insets]];
    insets = UIEdgeInsetsMake(12.0f, 15.0f, 12.0f, 15.0f);
    [[ZDCAgentChatCell appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCAgentChatCell appearance] setBubbleBorderColor:[UIColor colorWithWhite:0.90f alpha:1.0f]];
    [[ZDCAgentChatCell appearance] setBubbleColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    [[ZDCAgentChatCell appearance] setBubbleCornerRadius:@(3.0f)];
    [[ZDCAgentChatCell appearance] setTextAlignment:@(NSTextAlignmentLeft)];
    [[ZDCAgentChatCell appearance] setTextColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [[ZDCAgentChatCell appearance] setTextFont:[UIFont systemFontOfSize:14.0f]];
    [[ZDCAgentChatCell appearance] setAvatarHeight:@(30.0f)];
    [[ZDCAgentChatCell appearance] setAvatarLeftInset:@(14.0f)];
    [[ZDCAgentChatCell appearance] setAuthorColor:[UIColor colorWithWhite:0.60f alpha:1.0f]];
    [[ZDCAgentChatCell appearance] setAuthorFont:[UIFont systemFontOfSize:12]];
    [[ZDCAgentChatCell appearance] setAuthorHeight:@(25.0f)];

    insets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    [[ZDCSystemTriggerCell appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCSystemTriggerCell appearance] setTextColor:[UIColor whiteColor]]; //change apologize text color
    [[ZDCSystemTriggerCell appearance] setTextFont:[UIFont boldSystemFontOfSize:14.0f]];

    insets = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    [[ZDCChatTimedOutCell appearance] setTextInsets:[NSValue valueWithUIEdgeInsets:insets]];
    [[ZDCChatTimedOutCell appearance] setTextColor:[UIColor whiteColor]];
    [[ZDCChatTimedOutCell appearance] setTextFont:[UIFont boldSystemFontOfSize:14.0f]];

    [[ZDCRatingCell appearance] setTitleColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [[ZDCRatingCell appearance] setTitleFont:[UIFont boldSystemFontOfSize:14]];
    [[ZDCRatingCell appearance] setCellToTitleMargin:@(20.0f)];
    [[ZDCRatingCell appearance] setTitleToButtonsMargin:@(10.0f)];
    [[ZDCRatingCell appearance] setRatingButtonToCommentMargin:@(20.0f)];
    [[ZDCRatingCell appearance] setEditCommentButtonHeight:@(44.0f)];
    [[ZDCRatingCell appearance] setRatingButtonSize:@(40.0f)];

    [[ZDCAgentAttachmentCell appearance] setActivityIndicatorViewStyle:@(UIActivityIndicatorViewStyleWhite)];

    [[ZDCVisitorAttachmentCell appearance] setActivityIndicatorViewStyle:@(UIActivityIndicatorViewStyleWhite)];

    // Style the chat text entry area
    [[ZDCTextEntryView appearance] setSendButtonImage:nil];
    [[ZDCTextEntryView appearance] setTopBorderColor:[UIColor colorWithWhite:0.831f alpha:1.0f]];
    [[ZDCTextEntryView appearance] setTextEntryFont:[UIFont systemFontOfSize:14.0f]];
    [[ZDCTextEntryView appearance] setTextEntryColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
    [[ZDCTextEntryView appearance] setTextEntryBackgroundColor:[UIColor colorWithWhite:0.945f alpha:1.0f]];
    [[ZDCTextEntryView appearance] setTextEntryBorderColor:[UIColor colorWithWhite:0.831f alpha:1.0f]];
    [[ZDCTextEntryView appearance] setAreaBackgroundColor:[UIColor whiteColor]];

    [[ZDCChatOverlay appearance] setAlignment:@(ZDCOverlayAlignmentTopLeft)];
    
    // set all view backgrounds transparent
    [[ZDCPreChatFormView appearance] setFormBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    [[ZDCOfflineMessageView appearance] setFormBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    [[ZDCChatView appearance] setChatBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];//chang background color
    [[ZDCLoadingView appearance] setLoadingBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    [[ZDCLoadingErrorView appearance] setErrorBackgroundColor:[UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f]];
    
    // UI notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatLoaded:) name:ZDC_CHAT_UI_DID_LOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatLayout:) name:ZDC_CHAT_UI_DID_LAYOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatUnloaded:) name:ZDC_CHAT_UI_WILL_UNLOAD object:nil];
}

+ (void) chatLoaded:(NSNotification*)notification
{
   
    ZDCChatViewController *controller = [ZDCChat instance].chatViewController;
    controller.navigationItem.title = @"Chat";
}

+ (void) chatLayout:(NSNotification*)notification
{
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Customise the layout of any part of the chat UI here, this notification is received after
    // the standard/appearance configured layout has been applied
    ////////////////////////////////////////////////////////////////////////////////////////////////

//    ZDCChatUI *chatUI = notification.object;
    //chatUI.loadingView...
    //chatUI.formView...
    //chatUI.chatView...
}

+ (void) chatUnloaded:(NSNotification*)notification
{
    // The Chat UI has been dismissed
}

+ (UIColor *)darkerColorForColor:(UIColor *)color by:(float)diff
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - diff, 0.0)
                               green:MAX(g - diff, 0.0)
                                blue:MAX(b - diff, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor*) navBarTintColor
{
    return [UINavigationBar appearance].barTintColor;
}

+ (UIColor*) navTintColor
{
    return [UINavigationBar appearance].tintColor;
}

+ (BOOL) isVersionOrNewer:(NSString*)majorVersionNumber
{
    return [[[UIDevice currentDevice] systemVersion] compare:majorVersionNumber options:NSNumericSearch] != NSOrderedAscending;
}
@end

