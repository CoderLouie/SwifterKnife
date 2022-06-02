//
//  UIView+Private.h
//  SwifterKnife
//
//  Created by 李阳 on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Private_Add)

/// 1为Disabled，2为Highlighted，3未知，0普通状态
@property (nonatomic, assign) NSInteger drawMode;

@end

NS_ASSUME_NONNULL_END
