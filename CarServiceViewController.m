//
//  CarServiceViewController.m
//  Adogo
//
//  Created by Hema on 26/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "CarServiceViewController.h"
#import <MapKit/MapKit.h>
#import "CarService.h"
#import "SCLAlertView.h"

@import MapKit;
@import GoogleMaps;

@interface CarServiceViewController ()<GMSMapViewDelegate,UIGestureRecognizerDelegate>
{
    GMSCameraPosition *camera;
    GMSMarker *marker;
    CLLocationCoordinate2D globCoordinate;
    CGSize size;
    CGRect textRect;
    NSMutableDictionary *carServicingData;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    int imageIndex;
    NSString* locationAddress, *locationType;
    id json;
    NSMutableArray *uploadedImages;
}
@property (weak, nonatomic)  NSString *points;
@property (weak, nonatomic) IBOutlet UIPageControl *SliderPageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *carServiceScrollView;
@property (weak, nonatomic) IBOutlet UIView *carServiceView;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressSeperatorLabel;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *carServiceLabel;
@property (weak, nonatomic) IBOutlet UIView *priceDetailsView;
@property (weak, nonatomic) IBOutlet UIButton *confirmRedeemBtn;

@end

@implementation CarServiceViewController
@synthesize carServiceScrollView,carServiceView,carImageView,priceLabel,pointsLabel,descriptionLabel,detailsView,shopNameLabel,addressLabel,contactLabel,addressSeperatorLabel,mapView,carServiceLabel,priceDetailsView,confirmRedeemBtn,SliderPageControl,availablePoints;
@synthesize productId,productType;
@synthesize points;
@synthesize redeemViewObject;

#pragma mark - UIView life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    uploadedImages = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    
    [carImageView setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerImageLeft:)];
    swipeImageLeft.delegate=self;
    UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBannerImageRight:)];
    swipeImageRight.delegate=self;
    
    // Setting the swipe direction.
    [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    carServiceLabel.text = productType;
    [carImageView addGestureRecognizer:swipeImageLeft];
    [carImageView addGestureRecognizer:swipeImageRight];
    SliderPageControl.userInteractionEnabled = NO;
    SliderPageControl.currentPage = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [carServiceView setCornerRadius:3.0f];
    [carServiceScrollView setCornerRadius:3.0f];
    [addressLabel setViewBorder:addressLabel color:[UIColor colorWithRed:51.0/255.0 green:58.0/255.0 blue:74.0/255.0 alpha:1.0]];
    
    mapView.myLocationEnabled = NO;
    mapView.delegate = self;
    
    [myDelegate showIndicator];
    [self performSelector:@selector(redeemProductDetail) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Swipe Images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
    
}

- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
}

- (void) swipeBannerImageLeft: (UISwipeGestureRecognizer *)sender
{
    imageIndex++;
    if (imageIndex<uploadedImages.count)
    {
        carImageView.image =[uploadedImages objectAtIndex:imageIndex];
        UIImageView *moveIMageView = carImageView;
        [self addLeftAnimationPresentToView:moveIMageView];
        int page=imageIndex;
        SliderPageControl.currentPage=page;
    }
    else
    {
        imageIndex--;
    }
}

- (void) swipeBannerImageRight: (UISwipeGestureRecognizer *)sender
{
    imageIndex--;
    if (imageIndex<uploadedImages.count)
    {
        carImageView.image =[uploadedImages objectAtIndex:imageIndex];
        UIImageView *moveIMageView = carImageView;
        [self addRightAnimationPresentToView:moveIMageView];
        int page=imageIndex;
        SliderPageControl.currentPage=page;
    }
    else
    {
        imageIndex++;
    }
}

#pragma mark - end

#pragma mark - Call webservice
- (void)redeemProductDetail {
    
    [[CarService sharedManager] redeemProductdetail:productId success:^(id responseObject)
     {
         if ([responseObject[@"status"] intValue] == 400) {
             
             SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
             [alert addButton:@"OK" actionBlock:^(void) {
                 
                 [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
             }];
             [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
         }
         else {
             //NSLog(@"responseObject is %@",responseObject);
             NSMutableDictionary *tempDict=[responseObject objectForKey:@"data"];
             [self displayData:tempDict];
         }
     }
                                            failure:^(NSError *error) {
                                                
                                            }];
}

- (void)redeemProdcutApply {
    
    [[CarService sharedManager] redeemProductAppleyService:productId success:^(id responseObject)
     {
         SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
         [alert addButton:@"OK" actionBlock:^(void) {
             
             [redeemViewObject viewWillAppear:YES];
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
         }];
         [alert showWarning:nil title:@"Alert" subTitle:[responseObject objectForKey:@"message"] closeButtonTitle:nil duration:0.0f];
         
     }
                                                   failure:^(NSError *error) {
                                                   }];
}
#pragma mark - end

#pragma mark - Display data
- (void)downloadImages :(NSString *)urlStr index:(int)index
{
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    AFHTTPRequestOperation *posterOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    posterOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [posterOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject)
         {
             //NSLog(@"responseObject is %@",responseObject);
             [uploadedImages replaceObjectAtIndex:index withObject:responseObject];
             carImageView.image =[uploadedImages objectAtIndex:0];
             
         } else
         {
             
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //NSLog(@"Now showing poster request failed with error: %@", error);
     }];
    [posterOperation start];
    
}

- (void)displayData:(NSMutableDictionary *)dataDict {
    carImageView.contentMode = UIViewContentModeScaleAspectFit;
    descriptionLabel.translatesAutoresizingMaskIntoConstraints=YES;
    detailsView.translatesAutoresizingMaskIntoConstraints=YES;
    addressLabel.translatesAutoresizingMaskIntoConstraints=YES;
    carServiceView.translatesAutoresizingMaskIntoConstraints=YES;
    carServicingData = [dataDict mutableCopy];
    @try {
    
    for (int i=0; i<[[dataDict objectForKey:@"product_image"]count]; i++)
    {
        [uploadedImages addObject:[UIImage imageNamed:@"RedemptionCarPlaceholder"]];
    }
    carImageView.image = [UIImage imageNamed:@"RedemptionCarPlaceholder"];
        if (uploadedImages.count<=1) {
            SliderPageControl.hidden = YES;
        }
    SliderPageControl.numberOfPages = uploadedImages.count;
    for (int i=0; i<uploadedImages.count; i++)
    {
        [self downloadImages:[[dataDict objectForKey:@"product_image"] objectAtIndex:i] index:i];
    }
    
    NSAttributedString * priceStr = [[NSString stringWithFormat:@"Cash           S$%@",[carServicingData objectForKey:@"price_for_adg"]] setAttributrdString:[NSString stringWithFormat:@"S$%@",[carServicingData objectForKey:@"price_for_adg"]] stringFont:[UIFont railwayBoldWithSize:16] selectedColor:[UIColor colorWithRed:53.0/255.0 green:56.0/255.0 blue:73.0/255.0 alpha:1.0]];
    priceLabel.attributedText = priceStr;
    points = [carServicingData objectForKey:@"points"];
    NSAttributedString * pointsSstr = [[NSString stringWithFormat:@"Points       %@",[carServicingData objectForKey:@"points"]] setAttributrdString:[carServicingData objectForKey:@"points"] stringFont:[UIFont railwayRegularWithSize:16] selectedColor:[UIColor whiteColor]];
    pointsLabel.attributedText = pointsSstr;
    descriptionLabel.text = [carServicingData objectForKey:@"product_description"];
    shopNameLabel.text = [carServicingData objectForKey:@"shop_name"];
    addressLabel.text = [carServicingData objectForKey:@"address"];
    contactLabel.text = [carServicingData objectForKey:@"shop_phone_number"];
    locationAddress = [carServicingData objectForKey:@"address"];
    globCoordinate.longitude =[[dataDict valueForKeyPath:@"shop_location.lng"] doubleValue];
    globCoordinate.latitude = [[dataDict valueForKeyPath:@"shop_location.lat"] doubleValue];
    carImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    size = CGSizeMake(self.view.frame.size.width-42,999);
    textRect=[self setDynamicHeight:size textString:descriptionLabel.text fontSize:[UIFont railwayRegularWithSize:16]];
    
    descriptionLabel.frame =CGRectMake(12, carServiceLabel.frame.origin.y+carServiceLabel.frame.size.height+carImageView.frame.size.height+priceDetailsView.frame.size.height+5, self.view.frame.size.width-42, textRect.size.height+5);
    [descriptionLabel setViewBorder:descriptionLabel color:[UIColor colorWithRed:51.0/255.0 green:58.0/255.0 blue:74.0/255.0 alpha:1.0]];
    detailsView.frame =CGRectMake(0, descriptionLabel.frame.origin.y+descriptionLabel.frame.size.height+10, self.view.frame.size.width-30, detailsView.frame.size.height);
    
    size = CGSizeMake(135,80);
    textRect=[self setDynamicHeight:size textString:[carServicingData objectForKey:@"address"] fontSize:[UIFont railwayRegularWithSize:16]];
    addressLabel.frame =CGRectMake(addressLabel.frame.origin.x, addressLabel.frame.origin.y, 135, textRect.size.height+2);
    addressSeperatorLabel.frame=CGRectMake(0, addressLabel.frame.origin.y+addressLabel.frame.size.height+6, self.view.frame.size.width-30, 1);
    detailsView.frame =CGRectMake(0, descriptionLabel.frame.origin.y+descriptionLabel.frame.size.height+15, self.view.frame.size.width-30, 1+shopNameLabel.frame.origin.y+shopNameLabel.frame.size.height+7+addressLabel.frame.size.height+7+contactLabel.frame.size.height+1+35);
    float dynamicHeight=carServiceLabel.frame.origin.y+carServiceLabel.frame.size.height+carImageView.frame.size.height+priceDetailsView.frame.size.height+1+descriptionLabel.frame.size.height+15+detailsView.frame.size.height+1+mapView.frame.size.height+confirmRedeemBtn.frame.size.height;
    carServiceView.frame=CGRectMake(carServiceView.frame.origin.x, carServiceView.frame.origin.y, self.view.frame.size.width-30, dynamicHeight);
    [self getLocationFromAddressString];
        }
    @catch (NSException * e)
    {
        //NSLog(@"Exception: %@", e);
    }
}

- (void)downloadImages:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = carImageView;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [carImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

-(CGRect)setDynamicHeight:(CGSize)rectSize textString:(NSString *)textString fontSize:(UIFont *)fontSize {
    
    CGRect textHeight = [textString
                         boundingRectWithSize:rectSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:fontSize}
                         context:nil];
    return textHeight;
}
#pragma mark - end

#pragma mark - UIView actions
- (IBAction)cancelPopUpButtonAction:(id)sender {
    
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmAction:(id)sender
{
    //NSLog(@"[pointsLabel.text intValue] is %d",[points intValue]);
    if ([availablePoints intValue]<[points intValue]) {
        [UserDefaultManager showAlertMessage:@"You do not have enough points to redeem this product."];
        return;
    }
    else if([UserDefaultManager getValue:@"defaultCarId"]==nil)
    {
        [UserDefaultManager showAlertMessage:@"Please add a car to redeem this product."];
        return;
    }
    [myDelegate showIndicator];
    [self performSelector:@selector(redeemProdcutApply) withObject:nil afterDelay:.1];
}
#pragma mark - end

#pragma mark - Get latitude and longitude from address.
- (void)getLocationFromAddressString {
    
    [myDelegate stopIndicator];
    mapView.myLocationEnabled = NO;
    camera = [GMSCameraPosition cameraWithLatitude:globCoordinate.latitude
                                         longitude:globCoordinate.longitude
                                              zoom:16];
    mapView.camera = camera;
    marker.position = globCoordinate;
    marker.title = @"Address";
    marker.snippet = locationAddress;
    marker.tappable = true;
    marker.map= mapView;
    marker.draggable = true;
    
    GMSMarker *marker1 = [GMSMarker markerWithPosition:globCoordinate];
    marker1.title = @"Address";
    marker1.snippet = locationAddress;
    marker1.flat=YES;
    marker1.map = mapView;
}
#pragma mark - end
@end
