//
//  KKView.m
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "KKView.h"
#import <objc/runtime.h>
  
@import SwifterKnife;


@implementation NSObject (Add)

+ (void)printAllMethods {
    Class cls = self;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableArray *names = [NSMutableArray array];
        for (unsigned int i = 0; i < methodCount; i++) {
            const char *name = sel_getName(method_getName(methods[i]));
            if (name) {
                [names addObject:[NSString stringWithUTF8String:name]];
            };
        }
        NSLog(@"all method of %@ is\n%@", self, names);
        free(methods);
    }
}

@end

@implementation KKView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UILabel *label = [UILabel new];
    UIFont *font = [UIFont systemFontOfSize:14].fit;
//    label.font = [SwiftyFitsize sf_font:font];
//    label.font = SF_Font(font);
//    CGFloat val = [SwiftyFitsize sf_float:15];
//    CGFloat val = [Screen safeInsetB];
    NSLog(@"%f", Screen.safeAreaT);
    CGFloat val = [Screen fit:3];
//    [SwiftyFitsize shared].referenceH;
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIRectClip(rect);
}

@end
 

@interface UIButton (Private)
- (void)_updateTitleView;

@end
@implementation ATButton

- (void)_updateTitleView {
    [super _updateTitleView];
    
    NSLog(@"");
}

- (CGSize)intrinsicContentSize {
    CGSize size = super.intrinsicContentSize;
    NSLog(@"");
    return size;
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    [self invalidateIntrinsicContentSize];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
}
- (void)layoutSubviews {
    CGRect rect = self.frame;
    [super layoutSubviews];
    rect = self.frame;
    NSLog(@"");
}

@end
