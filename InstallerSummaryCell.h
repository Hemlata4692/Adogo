//
//  InstallerSummaryCell.h
//  Adogo
//
//  Created by Sumit on 16/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstallerSummaryCell : UITableViewCell
//Fisst row objects
@property (weak, nonatomic) IBOutlet UIView *InstallerSummaryBgView;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *installerSummaryLbl;
@property (weak, nonatomic) IBOutlet UILabel *installerSummarySeparator;
//end
//Second row objects
@property (weak, nonatomic) IBOutlet UIView *installerNameBgView;
@property (weak, nonatomic) IBOutlet UILabel *installerNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *installerNameIcon;
@property (weak, nonatomic) IBOutlet UILabel *installerNameSeparator;
//end
//Third row objects
@property (weak, nonatomic) IBOutlet UIView *ScheduledDateBgView;
@property (weak, nonatomic) IBOutlet UILabel *scheduledDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UIImageView *scheduledDateIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateSeparator;
//end
//forth row objects
@property (weak, nonatomic) IBOutlet UIView *contactBgView;
@property (weak, nonatomic) IBOutlet UIImageView *contactIcon;
@property (weak, nonatomic) IBOutlet UILabel *contactLbl;
@property (weak, nonatomic) IBOutlet UILabel *userContact;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UILabel *contactSeparator;
//end
//Fifth row object
@property (weak, nonatomic) IBOutlet UIView *ProposedTimeBgView;
@property (weak, nonatomic) IBOutlet UILabel *proposedTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *proposedTimeIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
//end
//Sixth row object
@property (weak, nonatomic) IBOutlet UIView *buttonBgView;
@property (weak, nonatomic) IBOutlet UILabel *sechduleInfoLbl;
@property (weak, nonatomic) IBOutlet UIButton *confirmTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *rejectTimeBtn;
//end
@property (weak, nonatomic) IBOutlet UILabel *installationStatusLbl;
@property (strong, nonatomic) IBOutlet UIButton *dashboardAshButton;
@property (weak, nonatomic) IBOutlet UILabel *noteLbl;
@property (weak, nonatomic) IBOutlet UIView *installationSuccessView;
@property (weak, nonatomic) IBOutlet UIView *installationFailedVIew;

@property (weak, nonatomic) IBOutlet UILabel *waitingStatusLbl;

@property (weak, nonatomic) IBOutlet UIButton *callAdogoBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatAdogoBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadStickerBtn;
- (void)displayData :(NSDictionary *)dataDict;
@end
