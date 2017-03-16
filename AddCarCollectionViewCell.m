//
//  AddCarCollectionViewCell.m
//  Adogo
//
//  Created by Ranosys on 02/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AddCarCollectionViewCell.h"

@implementation AddCarCollectionViewCell
@synthesize carImage, imageType, addOptionalCar;

#pragma mark - Display data on cell
- (void)displayData:(int)index data:(NSMutableDictionary*)data isEditMode:(BOOL)isEditCar{
    
    addOptionalCar.hidden = YES;
    carImage.hidden = NO;
    if (index == 0) {
        imageType.text = @"Front";
        if ([[[data objectForKey:@"Front"] objectForKey:@"setImage"] intValue] == 0) {
            
            if (isEditCar && [[[data objectForKey:@"Front"] objectForKey:@"isLocal"] intValue] == 1) {
                [self downloadImages:self imageUrl:[[data objectForKey:@"Front"] objectForKey:@"imageName"] placeholderImage:[[data objectForKey:@"Front"] objectForKey:@"placeholderImage"] myImageType:@"Front"];
            }
            else {
                carImage.image = [UIImage imageNamed:[[data objectForKey:@"Front"] objectForKey:@"imageName"]];
                carImage.contentMode = UIViewContentModeCenter;
                carImage.backgroundColor = [UIColor whiteColor];
            }
        }
        else {
            carImage.contentMode = UIViewContentModeScaleAspectFit;
            carImage.image = [[data objectForKey:@"Front"] objectForKey:@"myImage"];
            carImage.backgroundColor = [UIColor clearColor];
        }
    }
    else if (index == 1) {
        imageType.text = @"Right Side";
        if ([[[data objectForKey:@"RightSide"] objectForKey:@"setImage"] intValue] == 0) {
            
            if (isEditCar && [[[data objectForKey:@"RightSide"] objectForKey:@"isLocal"] intValue] == 1) {
                [self downloadImages:self imageUrl:[[data objectForKey:@"RightSide"] objectForKey:@"imageName"] placeholderImage:[[data objectForKey:@"RightSide"] objectForKey:@"placeholderImage"] myImageType:@"RightSide"];
            }
            else {
                carImage.image = [UIImage imageNamed:[[data objectForKey:@"RightSide"] objectForKey:@"imageName"]];
                carImage.contentMode = UIViewContentModeCenter;
                carImage.backgroundColor = [UIColor whiteColor];
            }
        }
        else {
            carImage.contentMode = UIViewContentModeScaleAspectFit;
            carImage.image = [[data objectForKey:@"RightSide"] objectForKey:@"myImage"];
            carImage.backgroundColor = [UIColor clearColor];
        }
    }
    else if (index == 2) {
        imageType.text = @"Rear";
        if ([[[data objectForKey:@"Rear"] objectForKey:@"setImage"] intValue] == 0) {
            
            if (isEditCar && [[[data objectForKey:@"Rear"] objectForKey:@"isLocal"] intValue] == 1) {
                [self downloadImages:self imageUrl:[[data objectForKey:@"Rear"] objectForKey:@"imageName"] placeholderImage:[[data objectForKey:@"Rear"] objectForKey:@"placeholderImage"] myImageType:@"Rear"];
            }
            else {
                carImage.image = [UIImage imageNamed:[[data objectForKey:@"Rear"] objectForKey:@"imageName"]];
                carImage.contentMode = UIViewContentModeCenter;
                carImage.backgroundColor = [UIColor whiteColor];
            }
        }
        else {
            carImage.contentMode = UIViewContentModeScaleAspectFit;
            carImage.image = [[data objectForKey:@"Rear"] objectForKey:@"myImage"];
            carImage.backgroundColor = [UIColor clearColor];
        }
    }
    else if (index == 3) {
        imageType.text = @"Left Side";
        if ([[[data objectForKey:@"LeftSide"] objectForKey:@"setImage"] intValue] == 0) {
            
            if (isEditCar && [[[data objectForKey:@"LeftSide"] objectForKey:@"isLocal"] intValue] == 1) {
                [self downloadImages:self imageUrl:[[data objectForKey:@"LeftSide"] objectForKey:@"imageName"] placeholderImage:[[data objectForKey:@"LeftSide"] objectForKey:@"placeholderImage"] myImageType:@"LeftSide"];
            }
            else {
                carImage.image = [UIImage imageNamed:[[data objectForKey:@"LeftSide"] objectForKey:@"imageName"]];
                carImage.contentMode = UIViewContentModeCenter;
                carImage.backgroundColor = [UIColor whiteColor];
            }
        }
        else {
            carImage.contentMode = UIViewContentModeScaleAspectFit;
            carImage.image = [[data objectForKey:@"LeftSide"] objectForKey:@"myImage"];
            carImage.backgroundColor = [UIColor clearColor];
        }
    }
    else{
        imageType.text = @"Optional";
        if ([[[data objectForKey:[NSString stringWithFormat:@"Optional%d", (int)index - 4]] objectForKey:@"setImage"] intValue] == 0) {
            
            if (isEditCar && [[[data objectForKey:[NSString stringWithFormat:@"Optional%d", (int)index - 4]] objectForKey:@"isLocal"] intValue] == 1) {
                
                    [self downloadImages:self imageUrl:[[data objectForKey:[NSString stringWithFormat:@"Optional%d", (int)index - 4]] objectForKey:@"imageName"] placeholderImage:[[data objectForKey:[NSString stringWithFormat:@"Optional%d", (int)index - 4]] objectForKey:@"placeholderImage"] myImageType:[NSString stringWithFormat:@"Optional%d", (int)index - 4]];
            }
            else {
                carImage.contentMode = UIViewContentModeCenter;
                carImage.image = [UIImage imageNamed:@""];
                carImage.hidden = YES;
                addOptionalCar.hidden = NO;
                addOptionalCar.borderType = BorderTypeDashed;
                addOptionalCar.dashPattern = 2;
                addOptionalCar.spacePattern = 2;
                addOptionalCar.borderWidth = 0.5;
                addOptionalCar.cornerRadius = 3;
                addOptionalCar.borderColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5f];
                carImage.backgroundColor = [UIColor whiteColor];
            }
        }
        else {
            carImage.contentMode = UIViewContentModeScaleAspectFit;
            carImage.image = [[data objectForKey:[NSString stringWithFormat:@"Optional%d", (int)index - 4]] objectForKey:@"myImage"];
            carImage.backgroundColor = [UIColor clearColor];
        }
    }
}
#pragma mark - end

#pragma mark - Image downloading using afnetworking
- (void)downloadImages:(AddCarCollectionViewCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage myImageType:(NSString *)myImageType {

    __weak UIImageView *weakRef = cell.carImage;
    __weak NSString *weakRefImageType = myImageType;
    if ([myImageType isEqualToString:@"Optional0"]) {
        weakRefImageType = @"Optional0";
    }
    else if ([myImageType isEqualToString:@"Optional1"]) {
         weakRefImageType = @"Optional1";
    }
    else if ([myImageType isEqualToString:@"Optional2"]) {
         weakRefImageType = @"Optional2";
    }
    else if ([myImageType isEqualToString:@"Optional3"]) {
         weakRefImageType = @"Optional3";
    }
    else if ([myImageType isEqualToString:@"Optional4"]) {
        weakRefImageType = @"Optional4";
    }
    else if ([myImageType isEqualToString:@"Optional5"]) {
        weakRefImageType = @"Optional5";
    }
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.carImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.backgroundColor = [UIColor clearColor];
        [_delegate downloadingCompleted:image imageType:weakRefImageType];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
