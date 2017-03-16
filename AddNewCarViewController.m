//
//  AddNewCarViewController.m
//  Adogo
//
//  Created by Ranosys on 29/04/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AddNewCarViewController.h"
#import "LBorderView.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "UIPlaceHolderTextView.h"
#import "CarService.h"
#import "AddCarCollectionViewCell.h"
#import "SWRevealViewController.h"
#import "CmsContentViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCLAlertView.h"
#import "AddCarInfoViewController.h"
#define Viewheight 44
#define Numeric_Only_Characters @"0123456789"
#define AlphaNumeric_Only_Characters @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define AlphaNumeric_Only_CharactersPlatNo @" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

@interface AddNewCarViewController ()<UITextFieldDelegate, BSKeyboardControlsDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, AFNetworkingDonwloadDelegate> {
    
    NSString *pickerType;
    NSMutableArray *textFieldArray;
    NSMutableArray *brandArray, *modelArray, *coeTypeArray;
    NSString *selectImagePickerView;
    int selectedBrandId;
    NSMutableDictionary *selectedOccupationPickerIndex;
    NSMutableDictionary *carImages, *editableData;
    NSString *awsFolderName;
    BOOL isOtherModel, isOtherBrand;
    int addMoreCarIndex;
    int isAWSAlertShow;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIView *internalView;

@property (strong, nonatomic) IBOutlet UITextField *brand;
@property (strong, nonatomic) IBOutlet UIButton *brandDropdown;
@property (strong, nonatomic) IBOutlet UIButton *brandBtn;

@property (strong, nonatomic) IBOutlet UITextField *model;
@property (strong, nonatomic) IBOutlet UIButton *modelDropdown;
@property (strong, nonatomic) IBOutlet UIButton *modelBtn;

@property (strong, nonatomic) IBOutlet UITextField *carColor;
@property (strong, nonatomic) IBOutlet UITextField *platNo;

@property (strong, nonatomic) IBOutlet UITextField *coeType;
@property (strong, nonatomic) IBOutlet UIButton *coeTypeDropdown;
@property (strong, nonatomic) IBOutlet UIButton *coeTypeBtn;

@property (strong, nonatomic) IBOutlet UIView *carOwnerView;
@property (strong, nonatomic) IBOutlet UILabel *carOwnerLabel;
@property (strong, nonatomic) IBOutlet UIButton *yesBtn;
@property (strong, nonatomic) IBOutlet UIButton *noBtn;

@property (strong, nonatomic) IBOutlet UILabel *eligibleLabel;
@property (strong, nonatomic) IBOutlet UIButton *eligibleBtn;

@property (strong, nonatomic) IBOutlet UITextField *carOwnerName;
@property (strong, nonatomic) IBOutlet UITextField *carOwnerNRICNo;

@property (strong, nonatomic) IBOutlet UIView *driverAgreementView;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;
@property (strong, nonatomic) IBOutlet UILabel *pleaseReadLabel;
@property (strong, nonatomic) IBOutlet UIButton *agreementBtn;

@property (strong, nonatomic) IBOutlet UIImageView *bookImage;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *specialNote;

@property (strong, nonatomic) IBOutlet UIButton *addCarBtn;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolBar;

@property (strong, nonatomic) IBOutlet UITextField *otherBrand;
@property (strong, nonatomic) IBOutlet UITextField *otherModel;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (strong, nonatomic) IBOutlet UIView *carOwnerDisableView;
@property (strong, nonatomic) IBOutlet UIView *DriverAgreementDisableView;
@property (strong, nonatomic) IBOutlet UIView *eigibleDisable;
@end

@implementation AddNewCarViewController
@synthesize isEditCar, carId, carCount, carDetail, isCarListing, carImageFromDetail;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _platNo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Yes"]) {
        
        carId = [[[myDelegate.notificationDict objectForKey:@"NotificationAPSData"] objectForKey:@"extra_params"] objectForKey:@"car_id"];
    }
    addMoreCarIndex = 0;
    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (isEditCar) {
        self.title = @"Edit Car";
    }
    else {
        self.title = @"Add New Car";
    }
    if (isEditCar) {
        awsFolderName = [NSString stringWithFormat:@"car_%d",[carId intValue]];
    }
    else {
        awsFolderName = [NSString stringWithFormat:@"car_%d",carCount];
    }
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    [[self navigationController] setNavigationBarHidden:NO];
    
    if (!isCarListing)
    {
        [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu.png"]];
    }
    else
    {
        [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white.png"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addLeftBarButtonWithImage:(UIImage *)menuImage {
    
    UIBarButtonItem *barButton1;
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton1, nil];
    if (!isCarListing)
    {
        SWRevealViewController *revealViewController = self.revealViewController;
        if (revealViewController)
        {
            [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
    else
    {
        [menu addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    }
}
#pragma mark - end

#pragma mark - UIView customization
- (void)viewCustomization {
    
    _eligibleBtn.selected = NO;
    _checkBtn.selected = NO;
    
    _otherModel.hidden = YES;
    _otherBrand.hidden = YES;
    isOtherModel = NO;
    isOtherBrand = NO;
    [self enabledDisabledTextfield];
    
    brandArray = [NSMutableArray new];
    modelArray = [NSMutableArray new];
    NSMutableDictionary *otherField = [NSMutableDictionary new];
    [otherField setObject:@"Other" forKey:@"model"];
    [otherField setObject:@"0" forKey:@"id"];
    [modelArray addObject:otherField];
    
    coeTypeArray =  [NSMutableArray new];
    selectedBrandId = 0;
    selectedOccupationPickerIndex = [NSMutableDictionary dictionaryWithDictionary:@{ @"Brand" : @"0", @"Model" : @"0", @"COE" : @"0" }];    //Set index for picker views.
    _noBtn.selected = NO;
    _yesBtn.selected = YES;
    
    //Set initial images
    [self setDefaultImage];
    //end
    _internalView.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    _internalView.layer.borderWidth = 1;
    _internalView.layer.cornerRadius = 5.0f;
    _internalView.layer.masksToBounds = YES;
    
    _specialNote.placeholder = @"Special Notes to Adogo";
    _specialNote.placeholderTextColor = [UIColor colorWithRed:(237.0/255.0) green:(238.0/255.0) blue:(240.0/255.0) alpha:1.0f];
    [self removeAutoLayout];
    [self viewFrameCustomization];
    
    //addBorder
    [self addBorderInView:_model];
    [self addBorderInView:_carColor];
    [self addBorderInView:_platNo];
    [self addBorderInView:_coeType];
    [self addBorderInView:_otherBrand];
    [self addBorderInView:_otherModel];
    [self addBorderInView:_carOwnerView];
    [self addBorderInView:_eligibleLabel];
    [self addBorderInView:_carOwnerName];
    [self addBorderInView:_carOwnerNRICNo];
    [self addBorderInView:_driverAgreementView];
    //end
    //add padding
    [self addPadding];
    //end
    //add textfields in BSKeyboard
    textFieldArray = [NSMutableArray new];
    [textFieldArray addObject:_carColor];
    [textFieldArray addObject:_platNo];
    
    _eigibleDisable.hidden = YES;
    _carOwnerDisableView.hidden = YES;
    _DriverAgreementDisableView.hidden = YES;
    
    if (isEditCar)
    {
        [_addCarBtn setTitle:@"Update Car" forState:UIControlStateNormal];
        
        if ([[myDelegate.notificationDict objectForKey:@"isNotification"] isEqualToString:@"Yes"]) {
            
            [myDelegate.notificationDict setObject:@"No" forKey:@"isNotification"];
            
            [myDelegate showIndicator];
            [self performSelector:@selector(getCarDetailService) withObject:nil afterDelay:.1];
        }
        else {
            
            [self getCarDetail:carDetail];
        }
    }
    else
    {
        [_addCarBtn setTitle:@"Add Car" forState:UIControlStateNormal];
        [myDelegate showIndicator];
        [self performSelector:@selector(carBrandList) withObject:nil afterDelay:.1];
        [textFieldArray addObject:_specialNote];
        //end
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
        [self.keyboardControls setDelegate:self];
    }
}

- (void)setDefaultImage {

    carImages = [NSMutableDictionary new];
    UIImage *tempFrontImage = [UIImage imageNamed:@"front.png"];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    [tempDict setObject:@"front.png" forKey:@"imageName"];
    [tempDict setObject:@"front.png" forKey:@"placeholderImage"];
    [tempDict setObject:@"0" forKey:@"isLocal"];
    [tempDict setObject:@"0" forKey:@"isSuccess"];
    [tempDict setObject:tempFrontImage forKey:@"myImage"];
    [tempDict setObject:@"0" forKey:@"setImage"];
    [tempDict setObject:@"0" forKey:@"carImageId"];
    [carImages setObject:tempDict forKey:@"Front"];
    
    tempDict = [NSMutableDictionary new];
    UIImage *tempRightSideImage = [UIImage imageNamed:@"rightSide.png"];
    [tempDict setObject:@"rightSide.png" forKey:@"imageName"];
    [tempDict setObject:@"rightSide.png" forKey:@"placeholderImage"];
    [tempDict setObject:@"0" forKey:@"isLocal"];
    [tempDict setObject:@"0" forKey:@"isSuccess"];
    [tempDict setObject:tempRightSideImage forKey:@"myImage"];
    [tempDict setObject:@"0" forKey:@"setImage"];
    [tempDict setObject:@"0" forKey:@"carImageId"];
    [carImages setObject:tempDict forKey:@"RightSide"];
    
    tempDict = [NSMutableDictionary new];
    UIImage *tempRearImage = [UIImage imageNamed:@"rear.png"];
    [tempDict setObject:@"rear.png" forKey:@"imageName"];
    [tempDict setObject:@"rear.png" forKey:@"placeholderImage"];
    [tempDict setObject:@"0" forKey:@"isLocal"];
    [tempDict setObject:@"0" forKey:@"isSuccess"];
    [tempDict setObject:tempRearImage forKey:@"myImage"];
    [tempDict setObject:@"0" forKey:@"setImage"];
    [tempDict setObject:@"0" forKey:@"carImageId"];
    [carImages setObject:tempDict forKey:@"Rear"];
    
    tempDict = [NSMutableDictionary new];
    UIImage *tempLeftSideImage = [UIImage imageNamed:@"leftSide.png"];
    [tempDict setObject:@"leftSide.png" forKey:@"imageName"];
    [tempDict setObject:@"leftSide.png" forKey:@"placeholderImage"];
    [tempDict setObject:@"0" forKey:@"isLocal"];
    [tempDict setObject:@"0" forKey:@"isSuccess"];
    [tempDict setObject:tempLeftSideImage forKey:@"myImage"];
    [tempDict setObject:@"0" forKey:@"setImage"];
    [tempDict setObject:@"0" forKey:@"carImageId"];
    [carImages setObject:tempDict forKey:@"LeftSide"];
}

- (void)addImagesInCarDetail:(NSMutableDictionary *)data {
    
    if (([[data objectForKey:@"other_image"] count]>0)) {
        
        [carDetail setObject:@"Yes" forKey:@"isOtherImage"];
    }
    else {
        
        [carDetail setObject:@"No" forKey:@"isOtherImage"];
    }
}

- (void)getCarDetailService {
    
    [[CarService sharedManager] carDetailService:carId success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        
        carDetail = [[responseObject objectForKey:@"cardetail"] mutableCopy];
        carImageFromDetail = [[[responseObject objectForKey:@"cardetail"] objectForKey:@"carimg_addedbyowner"] mutableCopy];
        
        if ([[[responseObject objectForKey:@"cardetail"] objectForKey:@"carimg_addedbyadmin"] count] == 0) {
            [self addImagesInCarDetail:[[responseObject objectForKey:@"cardetail"] objectForKey:@"carimg_addedbyowner"]];
        }
        else {
            [self addImagesInCarDetail:[[responseObject objectForKey:@"cardetail"] objectForKey:@"carimg_addedbyadmin"]];
        }
        [self getCarDetail:carDetail];
        
    }
                                         failure:^(NSError *error) {
                                             
                                         }];
}

- (void)addPadding {
    
    [_brand addTextFieldLeftPadding:_brand];
    [_model addTextFieldLeftPadding:_model];
    [_otherModel addTextFieldLeftPadding:_otherModel];
    [_otherBrand addTextFieldLeftPadding:_otherBrand];
    [_carColor addTextFieldLeftPadding:_carColor];
    [_platNo addTextFieldLeftPadding:_platNo];
    [_coeType addTextFieldLeftPadding:_coeType];
    [_carOwnerName addTextFieldLeftPadding:_carOwnerName];
    [_carOwnerNRICNo addTextFieldLeftPadding:_carOwnerNRICNo];
    
    [_brand addTextFieldPaddingRight:_brand];
    [_model addTextFieldPaddingRight:_model];
    [_coeType addTextFieldPaddingRight:_coeType];
}

- (void)removeAutoLayout {
    
    _mainView.translatesAutoresizingMaskIntoConstraints = YES;
    _internalView.translatesAutoresizingMaskIntoConstraints = YES;
    
    _brand.translatesAutoresizingMaskIntoConstraints = YES;
    _brandDropdown.translatesAutoresizingMaskIntoConstraints = YES;
    _brandBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    _model.translatesAutoresizingMaskIntoConstraints = YES;
    _modelDropdown.translatesAutoresizingMaskIntoConstraints = YES;
    _modelBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    _carColor.translatesAutoresizingMaskIntoConstraints = YES;
    _platNo.translatesAutoresizingMaskIntoConstraints = YES;
    
    _otherBrand.translatesAutoresizingMaskIntoConstraints = YES;
    _otherModel.translatesAutoresizingMaskIntoConstraints = YES;
    
    _coeType.translatesAutoresizingMaskIntoConstraints = YES;
    _coeTypeDropdown.translatesAutoresizingMaskIntoConstraints = YES;
    _coeTypeBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    _carOwnerView.translatesAutoresizingMaskIntoConstraints = YES;
    _carOwnerLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _yesBtn.translatesAutoresizingMaskIntoConstraints = YES;
    _noBtn.translatesAutoresizingMaskIntoConstraints = YES;
    _carOwnerDisableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    _eligibleBtn.translatesAutoresizingMaskIntoConstraints = YES;
    _eligibleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _eigibleDisable.translatesAutoresizingMaskIntoConstraints = YES;
    _carOwnerName.translatesAutoresizingMaskIntoConstraints = YES;
    _carOwnerNRICNo.translatesAutoresizingMaskIntoConstraints = YES;
    
    _driverAgreementView.translatesAutoresizingMaskIntoConstraints = YES;
    _DriverAgreementDisableView.translatesAutoresizingMaskIntoConstraints = YES;
    _pleaseReadLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _agreementBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    _bookImage.translatesAutoresizingMaskIntoConstraints = YES;
    _specialNote.translatesAutoresizingMaskIntoConstraints = YES;
    
    _addCarBtn.translatesAutoresizingMaskIntoConstraints = YES;
    
    _pickerView.translatesAutoresizingMaskIntoConstraints = YES;
    _pickerToolBar.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)addBorderInView:(UIView*)myView {
    
    myView.layer.borderWidth = 1;
    myView.layer.cornerRadius = 0;
    myView.layer.borderColor = [UIColor colorWithRed:(138.0/255.0) green:(139.0/255.0) blue:(148.0/255.0) alpha:1.0f].CGColor;
    myView.layer.masksToBounds = YES;
}

- (void)enabledDisabledTextfield {
    
    if (_eligibleBtn.selected) {
        _carOwnerName.enabled = YES;
        _carOwnerNRICNo.enabled = YES;
    }
    else {
        _carOwnerName.enabled = NO;
        _carOwnerNRICNo.enabled = NO;
    }
}

- (void)viewFrameCustomization {
    
    [self.view endEditing:YES];
    _internalView.frame = CGRectMake(13, 240, [[UIScreen mainScreen] bounds].size.width - 26, 546);
    
    _brand.frame = CGRectMake(0, 0, _internalView.frame.size.width, Viewheight);
    _brandBtn.frame = _brand.frame;
    _brandDropdown.frame = CGRectMake(_brand.frame.origin.x + _brand.frame.size.width - 43, 1, 42,42);
    
    if (isOtherBrand) {
        _otherBrand.hidden = NO;
        _otherBrand.frame = CGRectMake(0, _brand.frame.origin.y + Viewheight - 1, _internalView.frame.size.width, Viewheight);
        _model.frame = CGRectMake(0, _otherBrand.frame.origin.y + Viewheight - 1, _internalView.frame.size.width, Viewheight);
        _modelDropdown.frame = CGRectMake(_model.frame.origin.x + _model.frame.size.width - 43, _otherBrand.frame.origin.y + Viewheight, 42,42);
    }
    else {
        _otherBrand.hidden = YES;
        _model.frame = CGRectMake(0, _brand.frame.origin.y + Viewheight - 1, _internalView.frame.size.width, Viewheight);
        _modelDropdown.frame = CGRectMake(_model.frame.origin.x + _model.frame.size.width - 43, _brand.frame.origin.y + Viewheight, 42,42);
    }
    
    _modelBtn.frame = _model.frame;
    if (isOtherModel) {
        _otherModel.hidden = NO;
        _otherModel.frame = CGRectMake(0, _model.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
        _carColor.frame = CGRectMake(0, _otherModel.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
    }
    else {
        _otherModel.hidden = YES;
        _carColor.frame = CGRectMake(0, _model.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
    }
    
    _platNo.frame = CGRectMake(0, _carColor.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
    
    _coeType.frame = CGRectMake(0, _platNo.frame.origin.y + Viewheight - 1, _internalView.frame.size.width, Viewheight);
    _coeTypeBtn.frame = _coeType.frame;
    _coeTypeDropdown.frame = CGRectMake(_coeType.frame.origin.x + _coeType.frame.size.width - 43, _platNo.frame.origin.y + Viewheight, 42,42);
    
    _carOwnerView.frame = CGRectMake(0, _coeType.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,60);
    _carOwnerDisableView.frame = CGRectMake(0, 0, _carOwnerView.frame.size.width, _carOwnerView.frame.size.height);
    _carOwnerLabel.frame = CGRectMake(19, 8, 275, 24);
    _yesBtn.frame = CGRectMake(0, 25, 95, 34);
    _noBtn.frame = CGRectMake(132, 25, 81, 34);
    
    if (_yesBtn.selected) {
        
        _eligibleLabel.hidden = YES;
        _eligibleBtn.hidden = YES;
        _carOwnerName.hidden = YES;
        _carOwnerNRICNo.hidden = YES;
        _driverAgreementView.frame = CGRectMake(0, _carOwnerView.frame.origin.y + _carOwnerView.frame.size.height - 1, _internalView.frame.size.width,Viewheight);
    }
    else {
        
        _eligibleLabel.hidden = NO;
        _eligibleBtn.hidden = NO;
        _carOwnerName.hidden = NO;
        _carOwnerNRICNo.hidden = NO;
        _eligibleLabel.frame = CGRectMake(0, _carOwnerView.frame.origin.y + _carOwnerView.frame.size.height - 1, _internalView.frame.size.width,Viewheight);
        _eigibleDisable.frame = _eligibleLabel.frame;
        _eligibleBtn.frame = CGRectMake(0, _carOwnerView.frame.origin.y + _carOwnerView.frame.size.height - 1, 50, Viewheight);
        
        _carOwnerName.frame = CGRectMake(0, _eligibleLabel.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
        _carOwnerNRICNo.frame = CGRectMake(0, _carOwnerName.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
        _driverAgreementView.frame = CGRectMake(0, _carOwnerNRICNo.frame.origin.y + Viewheight - 1, _internalView.frame.size.width,Viewheight);
    }
    _checkBtn.frame = CGRectMake(0, 0, 50, Viewheight);
    _pleaseReadLabel.frame = CGRectMake(43, 0, 75, Viewheight);
    _agreementBtn.frame = CGRectMake(105, 0, 180, Viewheight);
    _DriverAgreementDisableView.frame =  CGRectMake(0, 0, 90, Viewheight);
    
    float specialNoteHeight = [_specialNote sizeThatFits:_specialNote.frame.size].height;
    if (specialNoteHeight > 60.0) {
        specialNoteHeight = 60.0;
    }
    _specialNote.frame = CGRectMake(53, (_driverAgreementView.frame.origin.y + Viewheight) + (80.0 / 2.0) - (specialNoteHeight/2.0), _internalView.frame.size.width - 53 - 8, specialNoteHeight);
//    NSLog(@"%f",[_specialNote sizeThatFits:_specialNote.frame.size].height);
    _bookImage.frame = CGRectMake(18, (_driverAgreementView.frame.origin.y + Viewheight) + (80 / 2) - (_bookImage.frame.size.height/2), _bookImage.frame.size.width, _bookImage.frame.size.height);
    
    _internalView.frame = CGRectMake(13, 240, [[UIScreen mainScreen] bounds].size.width - 26, _driverAgreementView.frame.origin.y + Viewheight + 80);
    
    _addCarBtn.frame = CGRectMake(20, _internalView.frame.origin.y + _internalView.frame.size.height + 10, [[UIScreen mainScreen] bounds].size.width - 40, Viewheight + 2);
    
    _mainView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _addCarBtn.frame.origin.y + _addCarBtn.frame.size.height + 15);
    _scrollView.contentSize = CGSizeMake(0,_mainView.frame.size.height);
}
#pragma mark - end

#pragma mark - Textview delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self.keyboardControls setActiveField:textView];
    [self hidePickerView];
    [_scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y + 144) animated:YES];
    _scrollView.scrollEnabled = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    float specialNoteHeight = [_specialNote sizeThatFits:_specialNote.frame.size].height;
    if (specialNoteHeight > 60.0) {
        specialNoteHeight = 60.0;
    }
    _specialNote.frame = CGRectMake(53, (_driverAgreementView.frame.origin.y + Viewheight) + (80.0 / 2.0) - (specialNoteHeight/2.0), _internalView.frame.size.width - 53 - 8, specialNoteHeight);
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
    [self hidePickerView];
    [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + 144) animated:YES];
    _scrollView.scrollEnabled = NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *alphaNumberSet = [[NSCharacterSet characterSetWithCharactersInString:AlphaNumeric_Only_Characters] invertedSet];
     NSCharacterSet *numeric = [[NSCharacterSet characterSetWithCharactersInString:Numeric_Only_Characters] invertedSet];
    if(textField == _carOwnerName)
    {
        if (range.length > 0 && [string length] == 0)
        {
            return YES;
        }
        if (textField.text.length > 80 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if (textField==_carOwnerNRICNo)
    {
        //allow backspace
        if (textField.text.length>9&&range.length==0)
        {
            return  NO;
        }
        switch (textField.text.length)
        {
            case 0:
            {
                BOOL retVal =  ([string rangeOfCharacterFromSet:alphaNumberSet].location == NSNotFound);
                return retVal;
            }
                
            case 8:
            {
                BOOL retVal =  ([string rangeOfCharacterFromSet:alphaNumberSet].location == NSNotFound);
                return retVal;
            }
                break;
            
            default:
            {
                BOOL retVal =  ([string rangeOfCharacterFromSet:numeric].location == NSNotFound);
                return retVal;
            }
        }
    }
    else if (textField==_platNo)
    {
        NSCharacterSet *alphaNumberSet = [[NSCharacterSet characterSetWithCharactersInString:AlphaNumeric_Only_CharactersPlatNo] invertedSet];
        if (textField.text.length>9&&range.length==0)
        {
            return  NO;
        }
        else
        {
            BOOL retVal =  ([string rangeOfCharacterFromSet:alphaNumberSet].location == NSNotFound);
            return retVal;
        }
    
    }
    return YES;
}
#pragma mark - end

#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls1 selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls {
    
    _scrollView.scrollEnabled = YES;
//    if ([[UIScreen mainScreen] bounds].size.height < 580) {
//        if (([[UIScreen mainScreen] bounds].size.height - 64) < _scrollView.contentOffset.y) {
//            [_scrollView setContentOffset:CGPointMake(0, -([[UIScreen mainScreen] bounds].size.height - _scrollView.contentOffset.y - (5 * 44))) animated:YES];
//        }
//    }
//    else {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - UIView actions
- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)carInfoAction:(UIButton *)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddCarInfoViewController *infoCarView =[storyboard instantiateViewControllerWithIdentifier:@"AddCarInfoViewController"];
    [self.navigationController pushViewController:infoCarView animated:YES];
}

- (IBAction)brandAction:(UIButton *)sender {
    
    pickerType = @"Brand";
    [self.view endEditing:YES];
    [self hidePickerView];
    if (brandArray.count != 0) {
        [_scrollView setContentOffset:CGPointMake(0, _brand.frame.origin.y + 72) animated:YES];
        [self showPickerView:[[selectedOccupationPickerIndex objectForKey:@"Brand"] intValue]];
    }
}

- (IBAction)modelAction:(UIButton *)sender {
    
    pickerType = @"Model";
    [self.view endEditing:YES];
    [self hidePickerView];
    if (modelArray.count != 0) {
        [_scrollView setContentOffset:CGPointMake(0, _model.frame.origin.y + 72) animated:YES];
        [self showPickerView:[[selectedOccupationPickerIndex objectForKey:@"Model"] intValue]];
    }
}

- (IBAction)coeTypeAction:(UIButton *)sender {
    
    pickerType = @"COEType";
    [self.view endEditing:YES];
    [self hidePickerView];
    if (coeTypeArray.count != 0) {
        [_scrollView setContentOffset:CGPointMake(0, _coeType.frame.origin.y + 72) animated:YES];
        [self showPickerView:[[selectedOccupationPickerIndex objectForKey:@"COE"] intValue]];
    }
}

- (IBAction)noCarOwner:(UIButton *)sender {
    
    [self hidePickerView];
    [self.view endEditing:YES];
    if (!_noBtn.selected) {
        _yesBtn.selected = NO;
        _noBtn.selected = YES;
        [self viewFrameCustomization];
    }
    if (_eligibleBtn.selected) {
        [textFieldArray removeAllObjects];
        
        if (isOtherModel && isOtherBrand) {
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherBrand){
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherModel){
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else {
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
        [self.keyboardControls setDelegate:self];
    }
}

- (IBAction)yesCarOwner:(UIButton *)sender {
    
    [self hidePickerView];
    [self.view endEditing:YES];
    if (!_yesBtn.selected) {
        _noBtn.selected = NO;
        _yesBtn.selected = YES;
        [self viewFrameCustomization];
    }
    
    [textFieldArray removeAllObjects];
    if (isOtherModel && isOtherBrand) {
        [textFieldArray addObject:_otherBrand];
        [textFieldArray addObject:_otherModel];
        [textFieldArray addObject:_carColor];
        [textFieldArray addObject:_platNo];
        [textFieldArray addObject:_specialNote];
    }
    else if (isOtherBrand){
        [textFieldArray addObject:_otherBrand];
        [textFieldArray addObject:_carColor];
        [textFieldArray addObject:_platNo];
        [textFieldArray addObject:_specialNote];
    }
    else if (isOtherModel){
        [textFieldArray addObject:_otherModel];
        [textFieldArray addObject:_carColor];
        [textFieldArray addObject:_platNo];
        [textFieldArray addObject:_specialNote];
    }
    else {
        [textFieldArray addObject:_carColor];
        [textFieldArray addObject:_platNo];
        [textFieldArray addObject:_specialNote];
    }
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
}

- (IBAction)eligible:(UIButton *)sender {
    
    [self hidePickerView];
    [self.view endEditing:YES];
    if (_eligibleBtn.selected) {
        _eligibleBtn.selected = NO;
        [textFieldArray removeAllObjects];
        if (isOtherModel && isOtherBrand) {
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherBrand){
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherModel){
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_specialNote];
        }
        else {
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_specialNote];
        }
        
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
        [self.keyboardControls setDelegate:self];
    }
    else {
        _eligibleBtn.selected = YES;
        [textFieldArray removeAllObjects];
        
        if (isOtherModel && isOtherBrand) {
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherBrand){
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else if (isOtherModel){
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        else {
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
            [textFieldArray addObject:_carOwnerName];
            [textFieldArray addObject:_carOwnerNRICNo];
            [textFieldArray addObject:_specialNote];
        }
        
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
        [self.keyboardControls setDelegate:self];
    }
    [self enabledDisabledTextfield];
}

- (IBAction)checkAgreement:(UIButton *)sender {
    
    [self.view endEditing:YES];
    [self hidePickerView];
    if (_checkBtn.selected) {
        _checkBtn.selected = NO;
    }
    else {
        _checkBtn.selected = YES;
    }
}

- (IBAction)driverAgreement:(UIButton *)sender {
    
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    CmsContentViewController *objCms = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CmsContentViewController"];
    objCms.cmsId = @"adogocaragreement";
    objCms.title = @"Adogo Driver's Agreement";
    objCms.gotItString = self.title;
    [self.navigationController pushViewController:objCms animated:YES];
    [self.view endEditing:YES];
    [self hidePickerView];
}

- (IBAction)submitCar:(UIButton *)sender {
    
    isAWSAlertShow=0;
    [self.view endEditing:YES];
    [self hidePickerView];
    _scrollView.scrollEnabled = YES;
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if([self performValidationForSubmitCar]) {
        
        NSArray *keys = [carImages allKeys];
        int flag = 0;
        for (int i = 0; i < keys.count; i++) {
            
            if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"isSuccess"] intValue] == 0) {
                if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"setImage"] intValue] == 1) {
                    flag = 1;
                    break;
                }
                
            }
        }
        if (flag == 0) {
            
            [myDelegate showIndicator:@"Uploading Data..."];
            [self performSelector:@selector(addCarService) withObject:nil afterDelay:.1];
        }
        else {
            
            [myDelegate showIndicator:@"Uploading Images..."];
            [self performSelector:@selector(uploadAWSImages) withObject:nil afterDelay:.1];
        }
    }
}

- (IBAction)pickerViewDone:(UIBarButtonItem *)sender {
    
    _scrollView.scrollEnabled = YES;
    NSInteger index = [_pickerView selectedRowInComponent:0];
    if ([pickerType isEqualToString:@"Brand"]) {
        _brand.text = [[brandArray objectAtIndex:index] objectForKey:@"brand_name"];
        [selectedOccupationPickerIndex setObject:[NSString stringWithFormat:@"%d", (int)index] forKey:@"Brand"];
        isOtherModel = NO;
        _otherModel.text = @"";
        _model.text = @"";
        if ([_brand.text isEqualToString:@"Other"]) {
            isOtherBrand = YES;
            isOtherModel = YES;
            _otherModel.text = @"";
            _model.text = @"Other";
            [textFieldArray removeAllObjects];
            if (_eligibleBtn.selected && _noBtn.selected && isOtherModel ) {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
                [textFieldArray addObject:_specialNote];
            }
            else if (isOtherModel) {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            else {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
            [self.keyboardControls setDelegate:self];
            
            [modelArray removeAllObjects];
            NSMutableDictionary *otherField = [NSMutableDictionary new];
            [otherField setObject:@"Other" forKey:@"model"];
            [otherField setObject:@"0" forKey:@"id"];
            [modelArray addObject:otherField];
        }
        else {
            isOtherBrand = NO;
            selectedBrandId = [[[brandArray objectAtIndex:index] objectForKey:@"id"] intValue];
            
            [textFieldArray removeAllObjects];
            if (_eligibleBtn.selected && _noBtn.selected && isOtherModel ) {
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
                [textFieldArray addObject:_specialNote];
            }
            else if (isOtherModel) {
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            else {
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
            [self.keyboardControls setDelegate:self];
            [myDelegate showIndicator];
            [self performSelector:@selector(carModelList) withObject:nil afterDelay:.1];
        }
        [self viewFrameCustomization];
    }
    else if ([pickerType isEqualToString:@"Model"]) {
        _model.text = [[modelArray objectAtIndex:index] objectForKey:@"model"];
        [selectedOccupationPickerIndex setObject:[NSString stringWithFormat:@"%d", (int)index] forKey:@"Model"];
        
        if ([_model.text isEqualToString:@"Other"]) {
            isOtherModel = YES;
            [textFieldArray removeAllObjects];
            if (_eligibleBtn.selected && _noBtn.selected && isOtherBrand ) {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
                [textFieldArray addObject:_specialNote];
            }
            else if (isOtherBrand) {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            else {
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
            [self.keyboardControls setDelegate:self];
            
        }
        else {
            isOtherModel = NO;
            [textFieldArray removeAllObjects];
            if (_eligibleBtn.selected && _noBtn.selected && isOtherBrand ) {
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
                [textFieldArray addObject:_specialNote];
            }
            else if (isOtherBrand) {
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            else {
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_specialNote];
            }
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
            [self.keyboardControls setDelegate:self];
        }
        [self viewFrameCustomization];
    }
    else {
        _coeType.text = [[coeTypeArray objectAtIndex:index] objectForKey:@"car_type"];
        [selectedOccupationPickerIndex setObject:[NSString stringWithFormat:@"%d", (int)index] forKey:@"COE"];
    }
    
    if ([[UIScreen mainScreen] bounds].size.height < 580) {
        if (([[UIScreen mainScreen] bounds].size.height - 64) < _scrollView.contentOffset.y) {
            [_scrollView setContentOffset:CGPointMake(0, -([[UIScreen mainScreen] bounds].size.height - _scrollView.contentOffset.y - (5 * 44))) animated:YES];
        }
    }
    else {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [self hidePickerView];
}

- (IBAction)pickerViewCancel:(UIBarButtonItem *)sender {
    
    [self hidePickerView];
}
#pragma mark - end

#pragma mark - Pickerview methods
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width,20)];
        pickerLabel.font = [UIFont railwayRegularWithSize:14];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    NSString *pickerStr;
    if ([pickerType isEqualToString:@"Brand"]) {
        pickerStr = [[brandArray objectAtIndex:row] objectForKey:@"brand_name"];
        pickerLabel.text = pickerStr;
    }
    else if ([pickerType isEqualToString:@"Model"]) {
        pickerStr = [[modelArray objectAtIndex:row] objectForKey:@"model"];
        pickerLabel.text = pickerStr;
    }
    else {
        pickerStr = [[coeTypeArray objectAtIndex:row] objectForKey:@"car_type"];
        pickerLabel.text = pickerStr;
    }
    return pickerLabel;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if ([pickerType isEqualToString:@"Brand"]) {
        return brandArray.count;
    }
    else if ([pickerType isEqualToString:@"Model"]) {
        return modelArray.count;
    }
    else {
        return coeTypeArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *pickerStr;
    if ([pickerType isEqualToString:@"Brand"]) {
        pickerStr = [[brandArray objectAtIndex:row] objectForKey:@"brand_name"];
    }
    else if ([pickerType isEqualToString:@"Model"]) {
        pickerStr = [[modelArray objectAtIndex:row] objectForKey:@"model"];
    }
    else {
        pickerStr = [[coeTypeArray objectAtIndex:row] objectForKey:@"car_type"];
    }
    return pickerStr;
}

- (void)hidePickerView {
    
    _scrollView.scrollEnabled = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _pickerView.frame = CGRectMake(_pickerView.frame.origin.x, 1000, self.view.bounds.size.width, _pickerView.frame.size.height);
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, 1000, self.view.bounds.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}

- (void)showPickerView:(int)index {
    
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:index inComponent:0 animated:YES];
    
    _scrollView.scrollEnabled = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    _pickerView.frame = CGRectMake(_pickerView.frame.origin.x, self.view.frame.size.height -  _pickerView.frame.size.height, self.view.bounds.size.width, _pickerView.frame.size.height);
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, _pickerView.frame.origin.y-44, self.view.bounds.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
    [_pickerView setNeedsLayout];
}
#pragma mark - end

#pragma mark - Call webservices
- (void)getCarDetail:(NSMutableDictionary *)responseObject {
    
//    NSLog(@"responseObject is %@",responseObject);
    editableData = [responseObject mutableCopy];
    _brand.text = [responseObject objectForKey:@"brand"];
    _model.text = [responseObject objectForKey:@"model"];
   
    _coeType.text = [responseObject objectForKey:@"car_type"];
    _carColor.text = [responseObject objectForKey:@"color"];
    _platNo.text = [responseObject objectForKey:@"plate_number"];
    NSData *data = [[responseObject objectForKey:@"special_note"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    _specialNote.text = goodValue;
    
    if ([[responseObject objectForKey:@"is_owner"] intValue] == 0) {
        _eigibleDisable.hidden = NO;
        _noBtn.selected = YES;
        _yesBtn.selected = NO;
        _eligibleBtn.selected = YES;
        _carOwnerName.text = [responseObject objectForKey:@"owner_name"];
        _carOwnerNRICNo.text = [responseObject objectForKey:@"owner_nric"];
        if (_eligibleBtn.selected) {
            [textFieldArray removeAllObjects];
            
            if (isOtherModel && isOtherBrand) {
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
            }
            else if (isOtherBrand){
                [textFieldArray addObject:_otherBrand];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
            }
            else if (isOtherModel){
                [textFieldArray addObject:_otherModel];
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
            }
            else {
                [textFieldArray addObject:_carColor];
                [textFieldArray addObject:_platNo];
                [textFieldArray addObject:_carOwnerName];
                [textFieldArray addObject:_carOwnerNRICNo];
            }
        }
    }
    else {
        _eigibleDisable.hidden = YES;
        _noBtn.selected = NO;
        _yesBtn.selected = YES;
        
        [textFieldArray removeAllObjects];
        if (isOtherModel && isOtherBrand) {
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
        }
        else if (isOtherBrand){
            [textFieldArray addObject:_otherBrand];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
        }
        else if (isOtherModel){
            [textFieldArray addObject:_otherModel];
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
        }
        else {
            [textFieldArray addObject:_carColor];
            [textFieldArray addObject:_platNo];
        }
        
    }
    [textFieldArray addObject:_specialNote];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    _checkBtn.selected = YES;
    [self setImageInEditableMode];
    [self viewFrameCustomization];
    [_collectionView reloadData];
    [self performSelector:@selector(carBrandList) withObject:nil afterDelay:.1];
}

- (void)setImageInEditableMode {
    
    NSArray *keys = [carImageFromDetail allKeys];
    for (int i = 0; i < [keys count]; i++) {
        
        NSMutableDictionary *tempDict;
        NSMutableArray *tempArray;
//        NSLog(@"%@",[keys objectAtIndex:i]);
        if ([keys containsObject:@"other_image"] && [[keys objectAtIndex:i] isEqualToString:@"other_image"]) {
            tempArray = [[carImageFromDetail objectForKey:[keys objectAtIndex:i]] mutableCopy];
        }
        else {
            tempDict = [[carImageFromDetail objectForKey:[keys objectAtIndex:i]] mutableCopy];
        }
        
        NSMutableDictionary *tempCarData;
        
        if ([[keys objectAtIndex:i] isEqualToString:@"left_image"]) {
            
            tempCarData = [[carImages objectForKey:@"LeftSide"] mutableCopy];
            [tempCarData setObject:@"1" forKey:@"isLocal"];
            [tempCarData setObject:[tempDict objectForKey:@"image"] forKey:@"imageName"];
            [tempCarData setObject:@"1" forKey:@"isSuccess"];
            [tempCarData setObject:[tempDict objectForKey:@"id"] forKey:@"carImageId"];
            [carImages setObject:tempCarData forKey:@"LeftSide"];
        }
        else if ([[keys objectAtIndex:i] isEqualToString:@"front_image"]) {
            
            tempCarData = [[carImages objectForKey:@"Front"] mutableCopy];
            [tempCarData setObject:@"1" forKey:@"isLocal"];
            [tempCarData setObject:[tempDict objectForKey:@"image"] forKey:@"imageName"];
            [tempCarData setObject:@"1" forKey:@"isSuccess"];
            [tempCarData setObject:[tempDict objectForKey:@"id"] forKey:@"carImageId"];
            [carImages setObject:tempCarData forKey:@"Front"];
        }
        else if ([[keys objectAtIndex:i] isEqualToString:@"right_image"]) {
            
            tempCarData = [[carImages objectForKey:@"RightSide"] mutableCopy];
            [tempCarData setObject:@"1" forKey:@"isLocal"];
            [tempCarData setObject:[tempDict objectForKey:@"image"] forKey:@"imageName"];
            [tempCarData setObject:@"1" forKey:@"isSuccess"];
            [tempCarData setObject:[tempDict objectForKey:@"id"] forKey:@"carImageId"];
            [carImages setObject:tempCarData forKey:@"RightSide"];
        }
        else if ([[keys objectAtIndex:i] isEqualToString:@"rear_image"]) {
            
            tempCarData = [[carImages objectForKey:@"Rear"] mutableCopy];
            [tempCarData setObject:@"1" forKey:@"isLocal"];
            [tempCarData setObject:[tempDict objectForKey:@"image"] forKey:@"imageName"];
            [tempCarData setObject:@"1" forKey:@"isSuccess"];
            [tempCarData setObject:[tempDict objectForKey:@"id"] forKey:@"carImageId"];
            [carImages setObject:tempCarData forKey:@"Rear"];
        }
        else if ([[keys objectAtIndex:i] isEqualToString:@"other_image"]) {
            
            for (int j = 0; j < [tempArray count]; j++) {
                
                tempCarData = [[tempArray objectAtIndex:j] mutableCopy];
                UIImage *tempOptionalImage = [UIImage imageNamed:@"carPlaceholder"];
                [tempCarData setObject:@"carPlaceholder" forKey:@"placeholderImage"];
                [tempCarData setObject:@"1" forKey:@"isLocal"];
                [tempCarData setObject:@"1" forKey:@"isSuccess"];
                [tempCarData setObject:[tempCarData objectForKey:@"image"] forKey:@"imageName"];
                [tempCarData setObject:tempOptionalImage forKey:@"myImage"];
                
                [tempCarData setObject:@"0" forKey:@"setImage"];
                [tempCarData setObject:[tempCarData objectForKey:@"id"] forKey:@"carImageId"];
                [carImages setObject:tempCarData forKey:[NSString stringWithFormat:@"Optional%d", j]];
            }
        }
    }
}

- (void)carBrandList {
    
    [coeTypeArray removeAllObjects];
    [brandArray removeAllObjects];
    [[CarService sharedManager] getCarBrandListing:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        brandArray = [[responseObject objectForKey:@"branddata"] mutableCopy];
        NSMutableDictionary *otherField = [NSMutableDictionary new];
        [otherField setObject:@"Other" forKey:@"brand_name"];
        [otherField setObject:@"0" forKey:@"id"];
        [brandArray addObject:otherField];
        
        coeTypeArray = [[responseObject objectForKey:@"vehicle_type"] mutableCopy];
    }
                                           failure:^(NSError *error) {
                                               NSMutableDictionary *otherField = [NSMutableDictionary new];
                                               [otherField setObject:@"Other" forKey:@"brand_name"];
                                               [otherField setObject:@"0" forKey:@"id"];
                                               [brandArray addObject:otherField];
                                    }];
}

- (void)carModelList {
    
    [modelArray removeAllObjects];
    [[CarService sharedManager] getCarModelListing:[NSString stringWithFormat:@"%d", selectedBrandId] success:^(id responseObject) {
//        NSLog(@"responseObject is %@",responseObject);
        
        modelArray = [[responseObject objectForKey:@"car_models"] mutableCopy];
        NSMutableDictionary *otherField = [NSMutableDictionary new];
        [otherField setObject:@"Other" forKey:@"model"];
        [otherField setObject:@"0" forKey:@"id"];
        [modelArray addObject:otherField];
    }
                                           failure:^(NSError *error) {
                                               NSMutableDictionary *otherField = [NSMutableDictionary new];
                                               [otherField setObject:@"Other" forKey:@"model"];
                                               [otherField setObject:@"0" forKey:@"id"];
                                               [modelArray addObject:otherField];
                                           }];
}

- (void)addCarService {
    
    [modelArray removeAllObjects];
    NSData *data = [_specialNote.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *front_image = [[carImages objectForKey:@"Front"] objectForKey:@"imageName"];
    NSString *rear_image = [[carImages objectForKey:@"Rear"] objectForKey:@"imageName"];
    NSString *right_image = [[carImages objectForKey:@"RightSide"] objectForKey:@"imageName"];
    NSString *left_image = [[carImages objectForKey:@"LeftSide"] objectForKey:@"imageName"];
    
    if ([front_image containsString:@"https:"]) {
        NSArray *imageNameSeparation = [front_image componentsSeparatedByString:@"/"];
        front_image = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
    }
    if ([rear_image containsString:@"https:"]) {
        NSArray *imageNameSeparation = [rear_image componentsSeparatedByString:@"/"];
        rear_image = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
    }
    if ([right_image containsString:@"https:"]) {
        NSArray *imageNameSeparation = [right_image componentsSeparatedByString:@"/"];
        right_image = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
    }
    if ([left_image containsString:@"https:"]) {
        NSArray *imageNameSeparation = [left_image componentsSeparatedByString:@"/"];
        left_image = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
    }
    
    NSString *is_default_car;
    if (!isEditCar) {
        if (carCount > 1) {
            is_default_car = @"0";
        }
        else {
            is_default_car = @"1";
        }
    }
    else {
        is_default_car = [editableData objectForKey:@"is_default_car"];
    }
    
    NSString *old_plate_number = @"";
    if (isEditCar) {
        old_plate_number = [editableData objectForKey:@"plate_number"];
    }
    
    NSMutableDictionary *tempDict;
    NSMutableArray *otherImages = [NSMutableArray new];
    for (int i = 0; i < carImages.count - 4; i++) {
        
        if ([[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"isSuccess"] intValue] == 1) {
            tempDict =  [NSMutableDictionary new];
            
            if ([[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"imageName"] containsString:@"https:"]) {
                NSArray *imageNameSeparation = [[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"imageName"] componentsSeparatedByString:@"/"];
                [tempDict setObject:[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"carImageId"] forKey:@"id"];
                [tempDict setObject:[imageNameSeparation objectAtIndex:imageNameSeparation.count - 1] forKey:@"name"];
                [otherImages addObject:tempDict];
            }
            else {
                
                [tempDict setObject:[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"carImageId"] forKey:@"id"];
                [tempDict setObject:[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", i]] objectForKey:@"imageName"] forKey:@"name"];
                [otherImages addObject:tempDict];
            }
        }
    }
    
    NSDictionary *carImagesData = @{@"front_image":
                                        @{@"id":[[carImages objectForKey:@"Front"] objectForKey:@"carImageId"], @"name":front_image},
                                    @"rear_image":
                                        @{@"id":[[carImages objectForKey:@"Rear"] objectForKey:@"carImageId"], @"name":rear_image},
                                    @"right_image":
                                        @{@"id":[[carImages objectForKey:@"RightSide"] objectForKey:@"carImageId"], @"name":right_image},
                                    @"left_image":
                                        @{@"id":[[carImages objectForKey:@"LeftSide"] objectForKey:@"carImageId"], @"name":left_image},
                                    @"other_image": otherImages};
    [[CarService sharedManager] addEditCarService:_platNo.text imageDict:carImagesData
                                           car_id:carId brand:(isOtherBrand ? _otherBrand.text : _brand.text) model:(isOtherModel ? _otherModel.text : _model.text) color:_carColor.text car_type:_coeType.text is_owner:(_yesBtn.selected ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) owner_name:(_noBtn.selected ? _carOwnerName.text : @"") owner_nric:(_noBtn.selected ? [_carOwnerNRICNo.text uppercaseString] : @"") special_note:goodValue awsFolderName:awsFolderName is_default_car:is_default_car old_plate_number:(NSString *)old_plate_number success:^(id responseObject) {
//                                               NSLog(@"responseObject is %@",responseObject);
                                               
                                               SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                               [alert addButton:@"OK" actionBlock:^(void) {
                                                   [self goBack];
                                                   
                                               }];
                                              [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
                                           }
                                          failure:^(NSError *error) {
                                              
                                          }];
}

- (void)goBack
{
    if (isEditCar)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark - end

#pragma mark - Show actionsheet method
- (void)showActionSheet: (NSString *)title {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             
                                                             AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                             if(authStatus == AVAuthorizationStatusAuthorized) {
                                                                 
                                                                 [self openDefaultCamera];
                                                                 
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusDenied){
                                                                 
                                                                 [self showAlertCameraAccessDenied];
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusRestricted){
                                                                 
                                                                [self showAlertCameraAccessDenied];
                                                             }
                                                             else if(authStatus == AVAuthorizationStatusNotDetermined){
                                                                 
                                                                 [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                                                                     if(granted){
                                                                         
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                                                             NSLog(@"6");
                                                                             
                                                                             [self openDefaultCamera];
                                                                         });
                                                                     }
                                                                     
                                                                 }];
                                                             }
                                                         }];
    
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                              picker.delegate = self;
                                                              picker.allowsEditing = NO;
                                                              picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              picker.navigationBar.tintColor = [UIColor whiteColor];
                                                              
                                                              [self presentViewController:picker animated:YES completion:NULL];
                                                          }];
    
    UIAlertAction * defaultAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alert addAction:cameraAction];
    [alert addAction:galleryAction];
    [alert addAction:defaultAct];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openDefaultCamera {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showAlertCameraAccessDenied {
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        [self showAlertMessage:@"Camera Access" message:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission."];
    }
    else {
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Settings" actionBlock:^(void) {
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert showWarning:nil title:@"Camera Access" subTitle:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission." closeButtonTitle:@"Cancel" duration:0.0f];
    }
}
#pragma mark - end

#pragma mark - ImagePicker delegate
- (NSString *)getImageName:(UIImage*)image {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpeg",datestr,[UserDefaultManager getValue:@"userId"]];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
    NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
    [imageData writeToFile:filePath atomically:YES];
    return fileName;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)info {
    
    UIImage *image = [image1 fixOrientation];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    if ([selectImagePickerView isEqualToString:@"Front"]) {
        tempDict = [[carImages objectForKey:@"Front"] mutableCopy];
        [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
        [tempDict setObject:image forKey:@"myImage"];
        [tempDict setObject:@"1" forKey:@"setImage"];
        [tempDict setObject:@"0" forKey:@"isSuccess"];
        [tempDict setObject:@"1" forKey:@"isLocal"];
        [carImages setObject:tempDict forKey:@"Front"];
    }
    else if ([selectImagePickerView isEqualToString:@"RightSide"]) {
        tempDict = [[carImages objectForKey:@"RightSide"] mutableCopy];
        [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
        [tempDict setObject:image forKey:@"myImage"];
        [tempDict setObject:@"1" forKey:@"setImage"];
        [tempDict setObject:@"0" forKey:@"isSuccess"];
        [tempDict setObject:@"1" forKey:@"isLocal"];
        [carImages setObject:tempDict forKey:@"RightSide"];
    }
    else if ([selectImagePickerView isEqualToString:@"Rear"]) {
        tempDict = [[carImages objectForKey:@"Rear"] mutableCopy];
        [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
        [tempDict setObject:image forKey:@"myImage"];
        [tempDict setObject:@"1" forKey:@"setImage"];
        [tempDict setObject:@"0" forKey:@"isSuccess"];
        [tempDict setObject:@"1" forKey:@"isLocal"];
        [carImages setObject:tempDict forKey:@"Rear"];
    }
    else if ([selectImagePickerView isEqualToString:@"LeftSide"]) {
        tempDict = [[carImages objectForKey:@"LeftSide"] mutableCopy];
        [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
        [tempDict setObject:image forKey:@"myImage"];
        [tempDict setObject:@"1" forKey:@"setImage"];
        [tempDict setObject:@"1" forKey:@"isLocal"];
        [tempDict setObject:@"0" forKey:@"isSuccess"];
        [carImages setObject:tempDict forKey:@"LeftSide"];
    }
    else {
        tempDict = [[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", (int)addMoreCarIndex]] mutableCopy];
        [tempDict setObject:[self getImageName:image] forKey:@"imageName"];
        [tempDict setObject:image forKey:@"myImage"];
        [tempDict setObject:@"1" forKey:@"setImage"];
        [tempDict setObject:@"0" forKey:@"isSuccess"];
        [tempDict setObject:@"1" forKey:@"isLocal"];
        [tempDict setObject:@"1" forKey:@"isEdit"];
        [carImages setObject:tempDict forKey:[NSString stringWithFormat:@"Optional%d", (int)addMoreCarIndex]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Hide/show placeholder NRIC button
- (void)hidePlaceHolderNricImages:(LBorderView*)btn label:(UILabel*)label {
    
    btn.dashPattern = 0;
    btn.spacePattern = 0;
    btn.borderWidth = 0;
    btn.cornerRadius = 3;
    btn.borderColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    label.hidden = YES;
}

- (void)showPlaceHolderNricImages:(LBorderView*)btn label:(UILabel*)label {
    
    btn.borderType = BorderTypeDashed;
    btn.dashPattern = 2;
    btn.spacePattern = 2;
    btn.borderWidth = 0.5;
    btn.cornerRadius = 3;
    btn.borderColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5f];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateSelected];
    label.hidden = NO;
}
#pragma mark - end

#pragma mark - Submit validations
- (BOOL)performValidationForSubmitCar {
    
    if (([[[carImages objectForKey:@"Front"] objectForKey:@"setImage"] intValue] == 0) && ([[[carImages objectForKey:@"Front"] objectForKey:@"isLocal"] intValue] == 0)) {
        [UserDefaultManager showAlertMessage:@"Please upload front side image of the car."];
        return NO;
    }
    else if (([[[carImages objectForKey:@"RightSide"] objectForKey:@"setImage"] intValue] == 0) && ([[[carImages objectForKey:@"RightSide"] objectForKey:@"isLocal"] intValue] == 0)) {
        [UserDefaultManager showAlertMessage:@"Please upload right side image of the car."];
        return NO;
    }
    else if (([[[carImages objectForKey:@"Rear"] objectForKey:@"setImage"] intValue] == 0) && ([[[carImages objectForKey:@"Rear"] objectForKey:@"isLocal"] intValue] == 0)) {
        [UserDefaultManager showAlertMessage:@"Please upload rear side image of the car."];
        return NO;
    }
    else if (([[[carImages objectForKey:@"LeftSide"] objectForKey:@"setImage"] intValue] == 0) && ([[[carImages objectForKey:@"LeftSide"] objectForKey:@"isLocal"] intValue] == 0)) {
        [UserDefaultManager showAlertMessage:@"Please upload left side image of the car."];
        return NO;
    }
    else if ([_brand isEmpty] || [_model isEmpty] || [_carColor isEmpty] || [_platNo isEmpty] || [_coeType isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (isOtherBrand && [_otherBrand isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (isOtherModel && [_otherModel isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (_noBtn.selected && !_eligibleBtn.selected) {
        [UserDefaultManager showAlertMessage:@"Please select the check box."];
        return NO;
    }
    else if (_noBtn.selected && ([_carOwnerName isEmpty] || [_carOwnerNRICNo isEmpty])) {
        [UserDefaultManager showAlertMessage:@"Please fill in all the fields."];
        return NO;
    }
    else if (!_checkBtn.selected) {
        [UserDefaultManager showAlertMessage:@"Please accept the agreement."];
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - Upload AWS images
- (void)uploadAWSImages {
    
    
    NSArray *keys = [carImages allKeys];
    for (int i = 0; i < keys.count; i++) {
        
        if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"isSuccess"] intValue] == 0) {
            if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"setImage"] intValue] == 1) {
                
                NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"imageName"]];
                AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
                uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
                uploadRequest.body = [NSURL fileURLWithPath:filePath];
                uploadRequest.contentType = @"image";
                uploadRequest.key = [[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"imageName"];
                
                if (isEditCar) {
                    uploadRequest.bucket = [NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%d", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],[carId intValue]];
//                    NSLog(@"-----------%@----------",[NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%d", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],[carId intValue]]);
                }
                else {
                    uploadRequest.bucket = [NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%d", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],carCount];
//                    NSLog(@"-----------%@----------",[NSString stringWithFormat:@"%@/uploads/users/carowners/carowner_%@/car_%d", [UserDefaultManager getValue:@"BucketName"],[UserDefaultManager getValue:@"userId"],carCount]);
                }
                [self upload:uploadRequest imageType:[keys objectAtIndex:i]];
            }
        }
    }
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest imageType:(NSString *)imageType {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        [UserDefaultManager showAlertMessage:@"There was an error faced while uploading the image. Please try again."];

//                        return;
                    }
                
                    });
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isAWSAlertShow==0) {
                        isAWSAlertShow=1;
                        [myDelegate stopIndicator];
                        [UserDefaultManager showAlertMessage:@"There was an error faced while uploading the image. Please try again."];

//                        return;
                    }

                });
            }
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"complete");
//                NSLog(@"%@",imageType);
                
                NSMutableDictionary *tempDict = [NSMutableDictionary new];
                tempDict = [[carImages objectForKey:imageType] mutableCopy];
                [tempDict setObject:@"1" forKey:@"isSuccess"];
                [carImages setObject:tempDict forKey:imageType];
                NSArray *keys = [carImages allKeys];
                int flag = 0;
                for (int i = 0; i < keys.count; i++) {
                    
                    if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"isSuccess"] intValue] == 0) {
                        if ([[[carImages objectForKey:[keys objectAtIndex:i]] objectForKey:@"setImage"] intValue] == 1) {
                            flag = 1;
                            break;
                        }
                        
                    }
                }
                if (flag == 0) {
                    [myDelegate stopIndicator];
                    [myDelegate showIndicator:@"Uploading Data..."];
                    [self performSelector:@selector(addCarService) withObject:nil afterDelay:.1];
                }
            });
        }
        return nil;
    }];
}

#pragma mark - end

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (carImages.count < 10) {
        return carImages.count + 1;
    }
    return carImages.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier;
    AddCarCollectionViewCell *cell;
    
    if (indexPath.row != carImages.count) {
        identifier = @"carImage";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell displayData:(int)indexPath.row data:carImages isEditMode:isEditCar];//
    }
    else {
        identifier = @"addMoreCarImage";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    }
    return cell;
}

- (void)downloadingCompleted:(UIImage *)myImage imageType:(NSString *)imageType {
    
    NSMutableDictionary *tempCarData;
    tempCarData = [[carImages objectForKey:imageType] mutableCopy];
    [tempCarData setObject:myImage forKey:@"myImage"];
    [tempCarData setObject:@"1" forKey:@"setImage"];
    [carImages setObject:tempCarData forKey:imageType];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        if (![[[carImages objectForKey:@"Front"] objectForKey:@"isSuccess"] isEqualToString:@"1"]) {
            selectImagePickerView = @"Front";
            [self showActionSheet:@"Select front image"];
        }
    }
    else if (indexPath.row == 1) {
        if (![[[carImages objectForKey:@"RightSide"] objectForKey:@"isSuccess"] isEqualToString:@"1"]) {
            selectImagePickerView = @"RightSide";
            [self showActionSheet:@"Select right side image"];
        }
    }
    else if (indexPath.row == 2) {
        if (![[[carImages objectForKey:@"Rear"] objectForKey:@"isSuccess"] isEqualToString:@"1"]) {
            selectImagePickerView = @"Rear";
            [self showActionSheet:@"Select rear image"];
        }
    }
    else if (indexPath.row == 3) {
        if (![[[carImages objectForKey:@"LeftSide"] objectForKey:@"isSuccess"] isEqualToString:@"1"]) {
            selectImagePickerView = @"LeftSide";
            [self showActionSheet:@"Select left side image"];
        }
    }
    else {
        selectImagePickerView = @"";
        if (indexPath.row == carImages.count) {
            
            addMoreCarIndex = (int)carImages.count - 4;
            [self setOptionalImage];
        }
        else {
            if (![[[carImages objectForKey:[NSString stringWithFormat:@"Optional%d", (int)indexPath.row - 4]] objectForKey:@"isSuccess"] isEqualToString:@"1"]) {
                addMoreCarIndex = (int)indexPath.row - 4;
                [self showActionSheet:@"Select optional image"];
            }
        }
    }
}
#pragma mark - end

#pragma mark - Show alert message
- (void)showAlertMessage:(NSString *)title message:(NSString*)message {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showWarning:nil title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
#pragma mark - end

#pragma mark - Set optional image initially
- (void)setOptionalImage {
    
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    UIImage *tempOptionalImage = [UIImage imageNamed:@"carPlaceholder"];
    [tempDict setObject:@"No Image" forKey:@"imageName"];
    [tempDict setObject:@"carPlaceholder" forKey:@"placeholderImage"];
    [tempDict setObject:@"0" forKey:@"isLocal"];
    [tempDict setObject:@"0" forKey:@"isSuccess"];
    [tempDict setObject:tempOptionalImage forKey:@"myImage"];
    [tempDict setObject:@"0" forKey:@"setImage"];
    [tempDict setObject:@"0" forKey:@"carImageId"];
    [tempDict setObject:@"0" forKey:@"isEdit"];
    [carImages setObject:tempDict forKey:[NSString stringWithFormat:@"Optional%d", addMoreCarIndex]];
    [_collectionView reloadData];
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
