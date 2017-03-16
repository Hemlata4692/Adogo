//
//  AddCarDimensionViewController.m
//  Adogo
//
//  Created by Ranosys on 10/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AddCarDimensionViewController.h"
#import "AddCarDimensionCell.h"
#import "CarService.h"
#import "SCLAlertView.h"
#import "ChatHistoryViewController.h"
#import "NotificationHistoryViewController.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AddCarDimensionViewController ()<BSKeyboardControlsDelegate,UITextFieldDelegate> {

    NSMutableArray *textFieldArray;
    UIView *tempView;
    UIImageView *popImage;
    NSMutableArray *heightArray;
    NSMutableArray *dimensionData;
    UIToolbar *toolbar;
    UITextField* lastTextField;
}

@property (strong, nonatomic) IBOutlet UITableView *carDimensionTableView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation AddCarDimensionViewController
@synthesize dimensionDetail, carId, isUpdatedText;
@synthesize flag;
@synthesize isOtherExist;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
   
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    UIBarButtonItem *flexableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44.0)];
    [toolbar setItems:[NSArray arrayWithObjects:flexableItem,doneItem, nil]];

    heightArray = [NSMutableArray new];
    textFieldArray = [NSMutableArray new];
    self.title = @"Car Dimensions";
    
    dimensionData = [NSMutableArray new];
    NSArray *keys = [dimensionDetail allKeys];
    
    if ([keys containsObject:@"right_image"]) {
        [dimensionData addObject:[dimensionDetail objectForKey:@"right_image"]];
    }
    if ([keys containsObject:@"left_image"]) {
        [dimensionData addObject:[dimensionDetail objectForKey:@"left_image"]];
    }
    if ([keys containsObject:@"front_image"]) {
        [dimensionData addObject:[dimensionDetail objectForKey:@"front_image"]];
    }
    if ([keys containsObject:@"rear_image"]) {
        [dimensionData addObject:[dimensionDetail objectForKey:@"rear_image"]];
    }
    
    if (isOtherExist) {
        for (int i = 0; i < [[dimensionDetail objectForKey:@"other_image"] count]; i++) {
            [dimensionData addObject:[[dimensionDetail objectForKey:@"other_image"] objectAtIndex:i]];
        }
    }
    
    [self viewCustomization];
    for (int i = 0; i < dimensionData.count; i++) {
        
        [heightArray addObject:[NSString stringWithFormat:@"%f",[self getDynamicLabelHeight:[[[dimensionData objectAtIndex:i] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] font:[UIFont railwayBoldWithSize:15] widthValue:[[UIScreen mainScreen] bounds].size.width - 16] + 4.0]];
    }
}

- (void)keyboardWillShow:(NSNotification *)note {
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneButtonNormal.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"doneButtonPressed.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
            [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
            [keyboardView addSubview:doneButton];
            [keyboardView bringSubviewToFront:doneButton];
            
            [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02
                                  delay:.0
                                options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                             animations:^{
                                 self.view.frame = CGRectOffset(self.view.frame, 0, 0);
                             } completion:nil];
        });
    }else {
        // locate keyboard view
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            UIView* keyboard;
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard view found; add the custom button to it
                if([[keyboard description] hasPrefix:@"UIKeyboard"] == YES)
                    [keyboard addSubview:doneButton];
            }
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UIView customization
- (void)viewCustomization {
    
    for (int i = 0; i < dimensionData.count; i++) {
        
        if ([[[dimensionData objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"0"] && [[[dimensionData objectAtIndex:i] objectForKey:@"measurLength"] isEqualToString:@""] && [[[dimensionData objectAtIndex:i] objectForKey:@"measurHeigth"] isEqualToString:@""]) {
            
            //When adogo added images for dimensions (Enter dimensions).
            [self setLocalMeasurement:i];
        }
        else if ([[[dimensionData objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"0"] && ([[[dimensionData objectAtIndex:i] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)) {
            
            //when dimensions are not approved by adogo (Waiting state).
            [self setLocalMeasurement:i];
        }
        else if ([[[dimensionData objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"0"] && ([[[dimensionData objectAtIndex:i] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
            
            //when dimensions are not approved by adogo (Redimension state).
            NSMutableDictionary *tempDict = [dimensionData objectAtIndex:i];
            [tempDict setObject:@"0" forKey:@"isMeasurHeigthSubmit"];
            [tempDict setObject:@"0" forKey:@"isMeasurLengthSubmit"];
            [tempDict setObject:@"" forKey:@"measurHeigth"];
            [tempDict setObject:@"" forKey:@"measurLength"];
            [dimensionData replaceObjectAtIndex:i withObject:tempDict];
        }
        else if ([[[dimensionData objectAtIndex:i] objectForKey:@"is_approved"] isEqualToString:@"1"]) {
            
            //when all dimensions are approved by adogo.
            [self setLocalMeasurement:i];
        }
    }
}

- (void)setLocalMeasurement:(int)index
{
    
    if ([[[dimensionData objectAtIndex:index] objectForKey:@"measurHeigth"] isEqualToString:@""] || [[[dimensionData objectAtIndex:index] objectForKey:@"measurHeigth"] length] == 0) {
        NSMutableDictionary *tempDict = [dimensionData objectAtIndex:index];
        [tempDict setObject:@"0" forKey:@"isMeasurHeigthSubmit"];
        [dimensionData replaceObjectAtIndex:index withObject:tempDict];
    }
    else {
        NSMutableDictionary *tempDict = [dimensionData objectAtIndex:index];
        [tempDict setObject:@"1" forKey:@"isMeasurHeigthSubmit"];
        [dimensionData replaceObjectAtIndex:index withObject:tempDict];
    }
    if ([[[dimensionData objectAtIndex:index] objectForKey:@"measurLength"] isEqualToString:@""] || [[[dimensionData objectAtIndex:index] objectForKey:@"measurLength"] length] == 0) {
        NSMutableDictionary *tempDict = [dimensionData objectAtIndex:index];
        [tempDict setObject:@"0" forKey:@"isMeasurLengthSubmit"];
        [dimensionData replaceObjectAtIndex:index withObject:tempDict];
    }
    else {
        NSMutableDictionary *tempDict = [dimensionData objectAtIndex:index];
        [tempDict setObject:@"1" forKey:@"isMeasurLengthSubmit"];
        [dimensionData replaceObjectAtIndex:index withObject:tempDict];
    }
}
#pragma mark - end

#pragma mark - Textfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    lastTextField = textField;
    AddCarDimensionCell *cell;
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        
        cell = (AddCarDimensionCell*)textField.superview.superview.superview;
    }
    else if ([textField.superview.superview isKindOfClass:[UITableViewCell class]]) {
        
        cell = (AddCarDimensionCell*)textField.superview.superview;
    }
    NSIndexPath *indexPath = [self.carDimensionTableView indexPathForCell:cell];
    float height = 0.0;
    for(int i = 0; i <= indexPath.row; i++) {
        
        height = height + [[heightArray objectAtIndex:i] floatValue];
    }
    if (dimensionData.count > indexPath.row) {
        if([[UIScreen mainScreen] bounds].size.height<=568)
        {
            [self.carDimensionTableView setContentOffset:CGPointMake(0, 140 + (15 *indexPath.row) + (230 * indexPath.row) + height - 1) animated:YES];
        }
        else
        {
            [self.carDimensionTableView setContentOffset:CGPointMake(0, (15 *indexPath.row) + (230 * indexPath.row) + height - 51) animated:YES];
        }
    }
    self.carDimensionTableView.scrollEnabled = NO;
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    AddCarDimensionCell *cell;
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]]) {
        cell = (AddCarDimensionCell*)textField.superview.superview.superview;
    }
    else if ([textField.superview.superview isKindOfClass:[UITableViewCell class]]) {
        cell = (AddCarDimensionCell*)textField.superview.superview;
    }
    
    NSIndexPath *indexPath = [self.carDimensionTableView indexPathForCell:cell];
    if (textField == cell.heightField) {
        [self setMeasureHeightLength:(int)indexPath.row text:textField.text isHeight:YES];
        cell.heightField.text = textField.text;
    }
    else {
        [self setMeasureHeightLength:(int)indexPath.row text:textField.text isHeight:NO];
        cell.lengthField.text = textField.text;
    }
    return YES;
}

- (void)setMeasureHeightLength:(int)index text:(NSString *)text isHeight:(bool)isHeight {
    
    NSMutableDictionary *tempDict = [dimensionData objectAtIndex:index];
    if (isHeight) {
        [tempDict setObject:text forKey:@"measurHeigth"];
    }
    else {
        [tempDict setObject:text forKey:@"measurLength"];
    }
    [dimensionData replaceObjectAtIndex:index withObject:tempDict];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        if (textField.text.length > 9 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    
    return YES;
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (flag) {
        return 66;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * headerView;
    if (flag) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 66.0)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, 66)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont railwayRegularWithSize:14];
        label.numberOfLines = 2;
        label.text = @"Please add dimensions as per crop marks.\nClick on each individual photo to enlarge.";
        [headerView addSubview:label];
    }
    else {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44.0)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont railwayRegularWithSize:14];
        label.numberOfLines = 1;
        label.text = @"Click on each individual photo to enlarge.";
        [headerView addSubview:label];
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (dimensionData.count != 0) {
        return dimensionData.count + 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (dimensionData.count != 0) {
        if (indexPath.row < dimensionData.count) {
            
            float height = 0.0;
            
                height = [self getDynamicLabelHeight:[[[dimensionData objectAtIndex:indexPath.row] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] font:[UIFont railwayBoldWithSize:15] widthValue:[[UIScreen mainScreen] bounds].size.width - 16];
            return 245 + height;
        }
        else {
            return 130.0f;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier;
    AddCarDimensionCell *cell;
    
    if (indexPath.row < dimensionData.count) {
        simpleTableIdentifier = @"imageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        [cell displayCellData:dimensionData index:(int)indexPath.row];
        cell.carImage.userInteractionEnabled = YES;
        cell.carImage.tag = indexPath.row;
        
        cell.lengthField.inputAccessoryView = toolbar;
        cell.heightField.inputAccessoryView = toolbar;
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageZoomDoneButtonTapped:)];
        tapped.numberOfTapsRequired = 1;
        [cell.carImage addGestureRecognizer:tapped];
    }
    else {
        simpleTableIdentifier = @"buttonCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (flag) {
            [cell.submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
        }
        else {
            [cell.submitBtn setTitle:@"OK" forState:UIControlStateNormal];
        }
        [cell.submitBtn addTarget:self action:@selector(submitMeasurement) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
#pragma mark - end

#pragma mark - Set label dynamic height
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,1000);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    if (![text isEqualToString:@""] && [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        textRect.size.height = textRect.size.height + 8;
    }
    else {
        textRect.size.height = 0.0;
    }
    return textRect.size.height;
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)doneClicked:(id)sender
{
   // NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
    
    self.carDimensionTableView.scrollEnabled = YES;
    if ([lastTextField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        AddCarDimensionCell *cell = (AddCarDimensionCell*)lastTextField.superview.superview.superview;
        NSIndexPath *indexPath = [self.carDimensionTableView indexPathForCell:cell];
        [self.carDimensionTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    else if ([lastTextField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        AddCarDimensionCell *cell = (AddCarDimensionCell*)lastTextField.superview.superview;
        NSIndexPath *indexPath = [self.carDimensionTableView indexPathForCell:cell];
        [self.carDimensionTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
}

- (void)imageZoomDoneButtonTapped :(id) sender
{
    [self.view endEditing:YES];
    self.carDimensionTableView.scrollEnabled = YES;
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    tempView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height)];
    popImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    tempView.backgroundColor = [UIColor blackColor];
    popImage.contentMode = UIViewContentModeScaleAspectFit;
    popImage.backgroundColor = [UIColor clearColor];
    [self downloadImages:popImage imageUrl:[[dimensionData objectAtIndex:(int)gesture.view.tag] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
    UIButton *close_button=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60,10,48,48)];
    [close_button setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [close_button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [tempView addSubview:popImage];
    [tempView addSubview:close_button];
    [self.view addSubview:tempView];
    
    [UIView animateWithDuration:0.3f animations:^{
        tempView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }];
}

- (IBAction)closeAction:(id)sender {
    
    [UIView animateWithDuration:0.3f animations:^{
        tempView.frame = CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height);
    } completion:^(BOOL finished) {
       [tempView removeFromSuperview];
    }];
}

- (void)downloadImages:(UIImageView *)imageView imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = imageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

- (void)chatAction {
    
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

- (void)submitMeasurement {
    
    [self.view endEditing:YES];
    self.carDimensionTableView.scrollEnabled = YES;
    if (!flag) {
         [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if ([self performSubmitValidation]) {
            [myDelegate showIndicator];
            [self performSelector:@selector(measurementService) withObject:nil afterDelay:.1];
        }
    }
}
#pragma mark - end

#pragma mark - Car measurement validation 
- (BOOL)performSubmitValidation {
    
    int tempFlag = 0;
    for (int i = 0; i < dimensionData.count; i++) {
        if ([[[dimensionData objectAtIndex:i] objectForKey:@"measurHeigth"] isEqualToString:@""] || [[[dimensionData objectAtIndex:i] objectForKey:@"measurHeigth"] length] == 0 || [[[dimensionData objectAtIndex:i] objectForKey:@"measurLength"] isEqualToString:@""] || [[[dimensionData objectAtIndex:i] objectForKey:@"measurLength"] length] == 0) {
            tempFlag = 1;
            break;
        }
    }
    
    if (tempFlag) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else {
         return YES;
    }
}
#pragma mark - end

#pragma mark - Call webservices
- (void)measurementService {

    [[CarService sharedManager] addCarMeasurementService:carId measurementData:dimensionData isUpdated:isUpdatedText success:^(id responseObject) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"OK" actionBlock:^(void) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
    }
    failure:^(NSError *error) {
                                             
    }];
}
#pragma mark - end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
