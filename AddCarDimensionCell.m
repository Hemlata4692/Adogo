//
//  AddCarDimensionCell.m
//  Adogo
//
//  Created by Ranosys on 10/05/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "AddCarDimensionCell.h"

@implementation AddCarDimensionCell
@synthesize carSidelabel, carImage, carDimensionView, lengthField, heightField, submitBtn, lengthLabel, heightLabel, lengthMeasurement, heightMeasurement, approvedByAdmin, approvedLabel, adminNote, noteBackView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Display data on cell
- (void)displayCellData:(NSMutableArray *)data index:(int)index {
    
    if ([[[data objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"right_image"]) {
        
        carSidelabel.text = @"  Right Side";
        adminNote.text = [[[data objectAtIndex:index] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self downloadImages:self imageUrl:[[data objectAtIndex:index] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
        
        [self setMeasurements:[data objectAtIndex:index]];
    }
    else if ([[[data objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"left_image"]) {
        
        carSidelabel.text = @"  Left Side";
                adminNote.text = [[[data objectAtIndex:index] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [self downloadImages:self imageUrl:[[data objectAtIndex:index] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
                [self setMeasurements:[data objectAtIndex:index]];
    }
    else if ([[[data objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"front_image"]) {
        
        carSidelabel.text = @"  Front";
        adminNote.text = [[[data objectAtIndex:index] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self downloadImages:self imageUrl:[[data objectAtIndex:index] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
        [self setMeasurements:[data objectAtIndex:index]];
    }
    else if ([[[data objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"rear_image"]) {
        
        carSidelabel.text = @"  Rear";
        adminNote.text = [[[data objectAtIndex:index] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self downloadImages:self imageUrl:[[data objectAtIndex:index] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
        [self setMeasurements:[data objectAtIndex:index]];
    }
    else if ([[[data objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"other_image"]) {
        
        carSidelabel.text = @"  Other";
        adminNote.text = [[[data objectAtIndex:index] objectForKey:@"note"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self downloadImages:self imageUrl:[[data objectAtIndex:index] objectForKey:@"image"] placeholderImage:@"carPlaceholder"];
        [self setMeasurements:[data objectAtIndex:index]];
    }
    
    if ([[[data objectAtIndex:index] objectForKey:@"is_approved"] isEqualToString:@"1"]) {
        
        adminNote.textColor = [UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0];
    }
    else {
        adminNote.textColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:85.0/255.0 alpha:1.0];
    }
    noteBackView.translatesAutoresizingMaskIntoConstraints = YES;

    float height = [self getDynamicLabelHeight:adminNote.text font:[UIFont railwayBoldWithSize:15] widthValue:[[UIScreen mainScreen] bounds].size.width - 16];
    noteBackView.hidden = NO;
    if (![adminNote.text isEqualToString:@""] && [adminNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        height = height + 8;
    }
    else {
        height = 0.0;
    }
    noteBackView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, height + 20);
    adminNote.numberOfLines = 0;
    adminNote.translatesAutoresizingMaskIntoConstraints = YES;
    adminNote.frame = CGRectMake(8, 48, [[UIScreen mainScreen] bounds].size.width - 16, height);
}
#pragma mark - end

#pragma mark - Get dynamic height according to string
- (float)getDynamicLabelHeight:(NSString *)text font:(UIFont *)font widthValue:(float)widthValue{
    
    CGSize size = CGSizeMake(widthValue,1000);
    CGRect textRect=[text
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:font}
                     context:nil];
    return textRect.size.height;
}
#pragma mark - end

#pragma mark - Measurement handling
- (void)setMeasurements:(NSMutableDictionary *)data {
    
    [carDimensionView setViewBorder:carDimensionView color:[UIColor whiteColor]];
    [carDimensionView setCornerRadius:3.0f];
    carDimensionView.backgroundColor = [UIColor colorWithRed:(116.0/255.0) green:(124.0/255.0) blue:(145.0/255.0) alpha:1.0f];
    
    if ([[data objectForKey:@"isMeasurHeigthSubmit"] isEqualToString:@"0"]) {
        heightField.hidden=NO;
        heightMeasurement.hidden = YES;
        heightLabel.hidden = YES;
        heightField.text = [data objectForKey:@"measurHeigth"];
    }
    else
    {
        carDimensionView.layer.borderColor =[UIColor clearColor].CGColor;
        carDimensionView.layer.borderWidth = 0.0;
        [carDimensionView setCornerRadius:0.0f];
        carDimensionView.backgroundColor = [UIColor clearColor];
        
        heightMeasurement.hidden = NO;
        heightLabel.hidden = NO;
        heightField.hidden=YES;
        heightField.text = [data objectForKey:@"measurHeigth"];
        heightMeasurement.text = [data objectForKey:@"measurHeigth"];
    }

    if ([[data objectForKey:@"isMeasurLengthSubmit"] isEqualToString:@"0"]) {
        lengthField.hidden=NO;
        lengthMeasurement.hidden = YES;
        lengthLabel.hidden = YES;
        lengthField.text = [data objectForKey:@"measurLength"];
    }
    else
    {
        carDimensionView.layer.borderColor =[UIColor clearColor].CGColor;
        carDimensionView.layer.borderWidth = 0.0;
        [carDimensionView setCornerRadius:0.0f];
        carDimensionView.backgroundColor = [UIColor clearColor];
        
        lengthField.text = [data objectForKey:@"measurLength"];
        lengthMeasurement.hidden = NO;
        lengthLabel.hidden = NO;
        lengthField.hidden=YES;
        lengthMeasurement.text = [data objectForKey:@"measurLength"];
    }
    
    if (![[data objectForKey:@"is_approved"] isEqualToString:@"0"]) {
        approvedByAdmin.hidden = NO;
        approvedLabel.hidden = NO;
    }
    else {
        approvedByAdmin.hidden = YES;
        approvedLabel.hidden = YES;
    }
}
#pragma mark - end

#pragma mark - Downloading image using afnetworking
- (void)downloadImages:(AddCarDimensionCell *)cell imageUrl:(NSString *)imageUrl placeholderImage:(NSString *)placeholderImage {
    
    __weak UIImageView *weakRef = cell.carImage;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [cell.carImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:placeholderImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
        weakRef.backgroundColor = [UIColor clearColor];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}
#pragma mark - end
@end
