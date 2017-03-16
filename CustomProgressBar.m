//
//  CustomProgressBar.m
//  CustomProgressbar
//
//  Created by Ranosys on 21/06/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "CustomProgressBar.h"

@interface CustomProgressBar (){
    
    UIView *vi1;
    UIView *vi;
    float paddingValue;
}
@end

@implementation CustomProgressBar

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)backgroundColor innerViewColor:(UIColor*)innerViewColor progressValue:(float)progressValue myView:(UIView *)myView padding:(float)padding{

    self=[super initWithFrame:frame];
    if (self) {
    
        paddingValue = padding;
        vi = [[UIView alloc] initWithFrame:frame];
        vi.backgroundColor = backgroundColor;
        [myView addSubview:vi];
        
        float width = (vi.frame.size.width - (padding * 2.0)) * progressValue ;
        
        vi1 = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, width, vi.frame.size.height - (padding * 2.0))];
        vi1.backgroundColor = innerViewColor;
        [vi addSubview:vi1];
        
        vi.layer.cornerRadius = vi.frame.size.height / 2.0;
        vi.layer.masksToBounds = YES;
        vi1.layer.cornerRadius = vi1.frame.size.height / 2.0;
        vi1.layer.masksToBounds = YES;

    }
    return self;
}

- (void)changeProgress:(float)value {

    float width = (vi.frame.size.width - (paddingValue * 2.0)) * value ;
    vi1.frame = CGRectMake(paddingValue, paddingValue, width, vi1.frame.size.height);
}
@end
