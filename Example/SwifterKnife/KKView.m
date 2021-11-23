//
//  KKView.m
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "KKView.h"


@interface NSObject (KKAdd)
- (instancetype)then:(void (^)(id this))block;
@end
@implementation NSObject (KKAdd)
- (instancetype)then:(void (^)(id))block {
    block(self);
    return self;
}
@end
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
    
    NSNumber *num = @1;
    [num then:^(NSNumber *this) {
        
    }];
    
    CGFloat val = SFH_Value(5);
//    [SwiftyFitsize shared].referenceH;
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIRectClip(rect);
}

@end
 
