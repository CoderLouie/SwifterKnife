//
//  UIView+Private.m
//  SwifterKnife
//
//  Created by liyang on 2022/6/2.
//

#import "UIView+Private.h"
 
@interface UIImageView (SwifterKnife_Private_Add)

/// 1为Disabled，2为Highlighted，3未知，0普通状态
@property (nonatomic, assign) NSInteger drawMode;

@end

@implementation UIImageView (SwifterKnifeAdd)

- (void)setGrayLevel:(ImageGrayLevel)grayLevel {
    if ([self respondsToSelector:@selector(setDrawMode:)]) {
        self.drawMode = grayLevel;
    }
}
- (ImageGrayLevel)grayLevel {
    if ([self respondsToSelector:@selector(drawMode)]) {
        return self.drawMode;
    }
    return ImageGrayLevelNone;
}

@end
