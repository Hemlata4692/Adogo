//
//  DriverProfileCell.m
//  Adogo
//
//  Created by Sumit on 04/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "DriverProfileCell.h"

@implementation DriverProfileCell
@synthesize driverName;
@synthesize driverImage;
@synthesize driverMobileNo;
@synthesize editProfileButton;
@synthesize viewProfileButton;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayData:(NSDictionary *)dataDict {
    
    if (![dataDict isEqual:@""]&&dataDict.count>0)
    {
        editProfileButton.layer.cornerRadius = 3;
        driverName.numberOfLines = 2;
        driverName.text = [dataDict objectForKey:@"name"];
        driverMobileNo.text = [UserDefaultManager getValue:@"mobileNumber"];
        //setting user image
        driverImage.layer.cornerRadius = 45.0;
        driverImage.contentMode = UIViewContentModeScaleAspectFill;
        driverImage.clipsToBounds = YES;
        
       viewProfileButton.layer.cornerRadius = 3;
       
        NSArray *imageNameSeparation = [[dataDict objectForKey:@"profile_picture"] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageNameSeparation objectAtIndex:imageNameSeparation.count - 1];
        
        if (![imageName isEqualToString:@""]  && imageName != nil) {
            [UserDefaultManager setValue:[dataDict objectForKey:@"profile_picture"] key:@"profileImageUrl"];
        }
        else {
            if (![[dataDict objectForKey:@"facebook_image_url"] isEqualToString:@""]) {
                [UserDefaultManager setValue:[dataDict objectForKey:@"facebook_image_url"] key:@"profileImageUrl"];
            }
        }
        __weak UIImageView *weakRef = driverImage;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[UserDefaultManager getValue:@"profileImageUrl"]]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [driverImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"user_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.image = image;
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
            weakRef.clipsToBounds = YES;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        //end
    }
}
@end
