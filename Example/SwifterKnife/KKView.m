//
//  KKView.m
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "KKView.h"

//#import <SwifterKnife/SwifterKnife-Swift.h>
@import SwifterKnife;

@implementation KKView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UILabel *label = [UILabel new];
    UIFont *font = [UIFont systemFontOfSize:14];
//    label.font = [SwiftyFitsize sf_font:font];
//    label.font = SF_Font(font);
//    CGFloat val = [SwiftyFitsize sf_float:15];
//    CGFloat val = [Screen safeInsetB];
    NSLog(@"%f", Screen.safeAreaT);
    
    
    CGFloat val = SFH_Value(5);
//    [SwiftyFitsize shared].referenceH;
    return self;
}

@end
 
