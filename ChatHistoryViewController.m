//
//  ChatHistoryViewController.m
//  Adogo
//
//  Created by Ranosys on 02/06/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "ChatHistoryViewController.h"
#import "SWRevealViewController.h"
#import "UserService.h"
#import "DriverMessageViewCell.h"
#import "AdogoMessageViewCell.h"
#define idCount ((int) 4)
#define adogoCellWidth ((float)[[UIScreen mainScreen] bounds].size.width - 120.0)
#define driverCellWidth ((float)[[UIScreen mainScreen] bounds].size.width - 50.0)

@interface ChatHistoryViewController (){
    
    NSMutableArray *chatHistoryid, *sectionTitle;
    NSMutableArray *chatList, *tempChatList;
    int totalListCount, currentCount;
    NSString *agentName;
    BOOL firstTimeCall, tempFirstTimeCall;
    UIRefreshControl *refreshControl;
}
@property (strong, nonatomic) IBOutlet UITableView *chatHistoryTableView;
@property (strong, nonatomic) IBOutlet UILabel *noRecordLabel;
@end

@implementation ChatHistoryViewController
@synthesize chatHistoryTableView, isOtherScreen;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    myDelegate.currentNavController = self.navigationController;
    self.navigationItem.title = @"Chat History";
    [[self navigationController] setNavigationBarHidden:NO];
    if (isOtherScreen) {
        [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white.png"]];
    }
    else {
        [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu.png"]];
    }
    
    // Pull To Refresh
    refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 10, 10)];
    [chatHistoryTableView addSubview:refreshControl];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@""];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    _noRecordLabel.hidden = YES;
    totalListCount = 0;
    currentCount = 0;
    chatHistoryid = [NSMutableArray new];
    chatList = [NSMutableArray new];
    sectionTitle = [NSMutableArray new];
    chatHistoryTableView.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(48.0/255.0) blue:(48.0/255.0) alpha:1.0f];
    firstTimeCall = YES;
    tempFirstTimeCall = YES;
    [myDelegate showIndicator];
    [self performSelector:@selector(getChatHistory) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Email encoding
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding stringText:(NSString *)stringText {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)stringText,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}
#pragma mark - end

#pragma mark - Get all chat session ids
- (void)getChatHistory {
    
    firstTimeCall = YES;
    tempFirstTimeCall = YES;
     NSString *Url_str=[NSString stringWithFormat:@"https://www.zopim.com/api/v2/chats/search?q=visitor_email:%@",[self urlEncodeUsingEncoding:NSUTF8StringEncoding stringText:[UserDefaultManager getValue:@"emailId"]]];
    NSURL * url = [[NSURL alloc] initWithString:[Url_str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSData *ResponseData = [UserService chatService:url];
    
    NSError * error = nil;
    id json;
    if (ResponseData != nil) {
        
        json = [NSJSONSerialization JSONObjectWithData:ResponseData options:0 error:&error];
        //NSLog(@"%@",json);
        totalListCount = [[json objectForKey:@"count"] intValue];
        
        if (totalListCount > 0) {
            _noRecordLabel.hidden = YES;
            for (int i = 0; i < totalListCount; i++) {
                
                [chatHistoryid addObject:[[[json objectForKey:@"results"] objectAtIndex:i] objectForKey:@"id"]];
            }
            
            [self callMoreChat];
        }
        else {
        
            _noRecordLabel.hidden = NO;
        }
    }
    [myDelegate stopIndicator];
}
#pragma mark - end

#pragma mark - Functioning for more chat
- (void)callMoreChat {
    
    NSString *chatId = @"";
    for (int i = 0; i < idCount; i++) {
         if (totalListCount > currentCount) {
         if (i == 0) {
         chatId = [NSString stringWithFormat:@"%@",[chatHistoryid objectAtIndex:currentCount]];
         }
         else {
         chatId = [NSString stringWithFormat:@"%@,%@",chatId, [chatHistoryid objectAtIndex:currentCount]];
         }
         currentCount++;
         }
    }
    if (![chatId isEqualToString:@""]) {
        [self getChatHistoryList:chatId];
    }
}

- (void)getChatHistoryList:(NSString *)chatId {
    
    NSString *Url_str;
    int chatCount= 0;
    tempChatList = [NSMutableArray new];
    if([chatId containsString:@","]){
        chatCount = 2;
        Url_str=[NSString stringWithFormat:@"https://www.zopim.com/api/v2/chats?ids=%@", chatId];
    }
    else {
        chatCount = 1;
         Url_str=[NSString stringWithFormat:@"https://www.zopim.com/api/v2/chats/%@", chatId];
    }
    
    NSURL * url = [[NSURL alloc] initWithString:[Url_str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSData *ResponseData = [UserService chatService:url];
    NSError * error = nil;
    id json;
    if (ResponseData != nil) {
        json = [NSJSONSerialization JSONObjectWithData:ResponseData options:0 error:&error];
        //NSLog(@"%@",json);
        if (chatCount == 1) {
            [self parsedSingleData:json];
        }
        else if (chatCount == 2){
            [self parsedMultipleData:json chatId:chatId];
        }
    }
    [myDelegate stopIndicator];
    [chatHistoryTableView reloadData];
}
#pragma mark - end

#pragma mark - Chat data parsing
- (void)parsedMultipleData:(id)json chatId:(NSString *)chatId {
    
    NSArray *keys;
//    keys = [chatId componentsSeparatedByString:@","];
    if (chatList.count==0) {
        keys = [[[[chatId componentsSeparatedByString:@","] reverseObjectEnumerator] allObjects] copy];
    }
    else {
        keys = [chatId componentsSeparatedByString:@","];
    }
    
    for (int i = 0; i < keys.count; i++) {
        //NSLog(@"agentName %@",agentName);
        NSMutableArray *tempArray = [NSMutableArray new];
        //NSLog(@"%@",[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]]);
        if ([[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] allKeys] containsObject:@"history"]) {
            for (int j = 0; j < [[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] count]; j++) {
                
                if ([[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] objectAtIndex:j] allKeys] containsObject:@"msg"] && ![[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"Customer Service"]) {
                    
                    if (![sectionTitle containsObject:[[[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] objectAtIndex:j] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
                        
                        [sectionTitle addObject:[[[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] objectAtIndex:j] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]];
                    }
                    [tempArray addObject:[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"history"] objectAtIndex:j]];
                }
            }
        }
        else {
            if (![sectionTitle containsObject:[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
                
                [sectionTitle addObject:[[[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]];
            }
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            //NSLog(@"%@,--%@",[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"message"],[keys objectAtIndex:i]);
            [tempDict setObject:[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"message"] forKey:@"msg"];
            [tempDict setObject:[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] valueForKeyPath:@"visitor.name"] forKey:@"name"];
            [tempDict setObject:[[[json objectForKey:@"docs"] objectForKey:[keys objectAtIndex:i]] objectForKey:@"timestamp"] forKey:@"timestamp"];
            [tempArray addObject:tempDict];
        }
        if (tempArray.count != 0) {
            [self setChatListData:tempArray];
        }
    }
}

- (void)parsedSingleData:(id)json {
    
    //NSLog(@"agentName %@",agentName);
    NSMutableArray *tempArray = [NSMutableArray new];
    if ([[json allKeys] containsObject:@"history"]) {
        for (int j = 0; j < [[json objectForKey:@"history"] count]; j++) {
            if ([[[[json objectForKey:@"history"] objectAtIndex:j] allKeys] containsObject:@"msg"] && ![[[[json objectForKey:@"history"] objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"Customer Service"]) {
                if (![sectionTitle containsObject:[[[[[json objectForKey:@"history"] objectAtIndex:j] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
                    
                    [sectionTitle addObject:[[[[[json objectForKey:@"history"] objectAtIndex:j] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]];
                }
                [tempArray addObject:[[json objectForKey:@"history"] objectAtIndex:j]];
            }
        }
    }
    else {
        if (![sectionTitle containsObject:[[[json objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
            [sectionTitle addObject:[[[json objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]];
        }
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setObject:[json objectForKey:@"message"] forKey:@"msg"];
        [tempDict setObject:[json valueForKeyPath:@"visitor.name"] forKey:@"name"];
        [tempDict setObject:[json objectForKey:@"timestamp"] forKey:@"timestamp"];
        [tempArray addObject:tempDict];
    }
    if (tempArray.count != 0) {
        [self setChatListData:tempArray];
    }
}

- (void)setChatListData:(NSMutableArray *)tempArray {
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if ((chatList.count != 0) && [[[[[tempArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0] isEqualToString:[[[[[chatList objectAtIndex:0] objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
        NSMutableArray *myTempArray;
        myTempArray = [[chatList objectAtIndex:0] mutableCopy];
        if (!firstTimeCall || tempFirstTimeCall) {
            tempFirstTimeCall = false;
            myTempArray = [[tempArray arrayByAddingObjectsFromArray:myTempArray] mutableCopy];
        }
        else {
            myTempArray = [[myTempArray arrayByAddingObjectsFromArray:tempArray] mutableCopy];
        }
        [chatList removeObjectAtIndex:0];
        [chatList insertObject:myTempArray atIndex:0];
    }
    else if ((chatList.count != 0) && [[[[[tempArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0] isEqualToString:[[[[[chatList objectAtIndex:chatList.count-1] objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]) {
        NSMutableArray *myTempArray;
        myTempArray = [[chatList objectAtIndex:chatList.count-1] mutableCopy];
        myTempArray = [[myTempArray arrayByAddingObjectsFromArray:tempArray] mutableCopy];
        
        [chatList removeObjectAtIndex:chatList.count-1];
        [chatList addObject:myTempArray];
    }
    else {
        NSMutableArray *tempChatListArray=(chatList.count!=0?[[chatList objectAtIndex:chatList.count-1] mutableCopy]:[NSMutableArray new]);
        if ((chatList.count != 0)&&([[dateFormat dateFromString:[[[[tempArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]] compare:[dateFormat dateFromString:[[[[tempChatListArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]] == NSOrderedAscending)) {
            
            [chatList insertObject:tempArray atIndex:0];
        }
        else if ((chatList.count != 0)&&([[dateFormat dateFromString:[[[[tempArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]] compare:[dateFormat dateFromString:[[[[tempChatListArray objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0]]] == NSOrderedDescending)) {
            
            [chatList addObject:tempArray];
        }
        else {
            tempFirstTimeCall=false;//Now added
            [chatList addObject:tempArray];
        }
    }
}
#pragma mark - end

#pragma mark - Add left bar button
- (void)addLeftBarButtonWithImage:(UIImage *)menuImage {
    
     if (isOtherScreen) {
         UIBarButtonItem *barButton1;
         CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
         UIButton *backButton = [[UIButton alloc] initWithFrame:framing];
         [backButton setBackgroundImage:menuImage forState:UIControlStateNormal];
         barButton1 =[[UIBarButtonItem alloc] initWithCustomView:backButton];
         [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
         self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
     }
     else {
         UIBarButtonItem *barButton1;
         CGRect framing = CGRectMake(0, 0, menuImage.size.width + 5, menuImage.size.height + 5);
         UIButton *menu = [[UIButton alloc] initWithFrame:framing];
         [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
         barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
         self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
         SWRevealViewController *revealViewController = self.revealViewController;
         if (revealViewController)
         {
             [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
             [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
         }
     }
}
#pragma mark - end

- (void) dismiss {
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (currentCount != totalListCount) {
        return chatList.count + 1;
    }
    else {
        return chatList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
    if ((currentCount != totalListCount) && (section == 0)) {
        return 25.0;
    }
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * headerView;
    UILabel *label;
    if (currentCount != totalListCount) {
        if (section == 0) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 25.0)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 25)];
            label.text = @"Pull to see past chats";
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.layer.cornerRadius = 0;
            label.layer.masksToBounds = YES;
        }
        else {
            UILabel *backLinelabel, *frontLinelabel;
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50.0)];
            label = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) - 50, (50.0 / 2.0) - (25.0/2.0), 100, 25)];
            backLinelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, label.frame.origin.y + (label.frame.size.height/2) - 0.5, ([[UIScreen mainScreen] bounds].size.width / 2) - 20 - (label.frame.size.width/2), 1)];
            frontLinelabel = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) + 5 + (label.frame.size.width/2), label.frame.origin.y + (label.frame.size.height/2) - 0.5, backLinelabel.frame.size.width, 1)];
            
            backLinelabel.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
            frontLinelabel.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
            
            NSArray *dateArray = [[[[[[chatList objectAtIndex:(int)section - 1] objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0] componentsSeparatedByString:@"-"];
            label.text = [NSString stringWithFormat:@"%@/%@/%@",[dateArray objectAtIndex:2],[dateArray objectAtIndex:1],[dateArray objectAtIndex:0]];
            label.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
            label.layer.cornerRadius = 5;
            label.layer.masksToBounds = YES;
            label.textColor = [UIColor whiteColor];
            [headerView addSubview:backLinelabel];
            [headerView addSubview:frontLinelabel];
        }
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont railwayRegularWithSize:14];
        label.numberOfLines = 1;
        [headerView addSubview:label];
    }
    else {
        
        UILabel *backLinelabel, *frontLinelabel;
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50.0)];
        label = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) - 50, (50.0 / 2.0) - (25.0/2.0), 100, 25)];
        backLinelabel = [[UILabel alloc] initWithFrame:CGRectMake(15, label.frame.origin.y + (label.frame.size.height/2) - 0.5, ([[UIScreen mainScreen] bounds].size.width / 2) - 20 - (label.frame.size.width/2), 1)];
        frontLinelabel = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) + 5 + (label.frame.size.width/2), label.frame.origin.y + (label.frame.size.height/2) - 0.5, backLinelabel.frame.size.width, 1)];
        
        backLinelabel.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
        frontLinelabel.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
        
        NSArray *dateArray = [[[[[[chatList objectAtIndex:(int)section] objectAtIndex:0] objectForKey:@"timestamp"] componentsSeparatedByString:@"T"] objectAtIndex:0] componentsSeparatedByString:@"-"];
        label.text = [NSString stringWithFormat:@"%@/%@/%@",[dateArray objectAtIndex:2],[dateArray objectAtIndex:1],[dateArray objectAtIndex:0]];
        label.backgroundColor = [UIColor colorWithRed:(73.0/255.0) green:(73.0/255.0) blue:(73.0/255.0) alpha:1.0f];
        label.layer.cornerRadius = 5;
        label.layer.masksToBounds = YES;
        label.textColor = [UIColor whiteColor];
        
        [headerView addSubview:backLinelabel];
        [headerView addSubview:frontLinelabel];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont railwayRegularWithSize:14];
        label.numberOfLines = 1;
        [headerView addSubview:label];
    }
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (currentCount != totalListCount) {
        if (section == 0) {
            return 0;
        }
        return [[chatList objectAtIndex:(int)section - 1] count];
    }
    else {
        return [[chatList objectAtIndex:section] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    int sectionIndex;
    if (currentCount != totalListCount) {
        sectionIndex = (int)indexPath.section - 1;
    }
    else {
        sectionIndex = (int)indexPath.section;
    }

    if ([[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] allKeys] containsObject:@"attachment"]) {
        if ([[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"name"] isEqualToString:[UserDefaultManager getValue:@"userName"]]) {
           return 150.0 + 10.0;
        }
        else {
            return 150.0 + 40.0;
        }
    }
    else {
        
        if ([[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"name"] isEqualToString:[UserDefaultManager getValue:@"userName"]]) {
            float height = [self getDynamicLabelHeight:[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"msg"] font:[UIFont railwayRegularWithSize:14] widthValue:driverCellWidth];
            
            if (height < 25.0) {
                height = 25.0;
            }
            return [self getDynamicLabelHeight:[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"msg"] font:[UIFont railwayRegularWithSize:14] widthValue:driverCellWidth] + 40;
        }
        else {
            
            float height = [self getDynamicLabelHeight:[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"msg"] font:[UIFont railwayRegularWithSize:14] widthValue:adogoCellWidth];
            
            if (height < 25.0) {
                height = 25.0;
            }
            return height + 20 + 10 + 40;
        }
    }
}

- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,1500);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier;
    
    int sectionIndex;
    if (currentCount != totalListCount) {
        sectionIndex = (int)indexPath.section - 1;
    }
    else {
        sectionIndex = (int)indexPath.section;
    }
    
    if ([[[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row] objectForKey:@"name"] isEqualToString:[UserDefaultManager getValue:@"emailId"]]) {
        DriverMessageViewCell *cell;
        simpleTableIdentifier = @"driverMessageCell";
        cell = [chatHistoryTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell changeDriverDisplayFraming:[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row]];
        return cell;
    }
    else {
        
        AdogoMessageViewCell *cell;
        simpleTableIdentifier = @"adogoMessageCell";
        cell = [chatHistoryTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell changeDisplayFraming:[[chatList objectAtIndex:sectionIndex] objectAtIndex:(int)indexPath.row]];
        return cell;
    }
}
#pragma mark - end

#pragma mark - Refresh table
//Pull to refresh implementation on my submission data
- (void)refreshTable
{
    firstTimeCall = false;
    [self callMoreChat];
    [refreshControl endRefreshing];
}
#pragma mark - end

#pragma mark - UIView actions
- (void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chatAction:(UIButton *)sender {
    
    [[ZDCChat instance].api trackEvent:@"Chat button pressed: (pre-set data)"];
    
    // before starting the chat set the visitor data
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {
        
        visitor.phone = [UserDefaultManager getValue:@"mobileNumber"];
        visitor.name = [UserDefaultManager getValue:@"emailId"];
        visitor.email = [UserDefaultManager getValue:@"emailId"];
    }];
    
    [ZDCChat startChatIn:[UIApplication sharedApplication].keyWindow.rootViewController.navigationController withConfig:^(ZDCConfig *config) {
        
        config.preChatDataRequirements.name = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.email = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.phone = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.department = ZDCPreChatDataNotRequired;
        config.preChatDataRequirements.message = ZDCPreChatDataRequired;
        config.tags = @[@"iPhoneChat"];
    }];
}
#pragma mark - end
@end
