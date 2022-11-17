//
//  UIView+Private.h
//  SwifterKnife
//
//  Created by liyang on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, ImageGrayLevel) {
    ImageGrayLevelNone = 0,
    ImageGrayLevelLight,
    ImageGrayLevelDark,
    ImageGrayLevelMedium
};

@interface UIImageView (SwifterKnifeAdd)

/// 1为Disabled，2为Highlighted，3未知，0普通状态
//@property (nonatomic, assign) NSInteger drawMode;
@property (nonatomic, assign) ImageGrayLevel grayLevel;

@end

NS_ASSUME_NONNULL_END
