//
//  OCUtils.h
//  Chatbabe
//
//  Created by 李阳 on 2023/06/07.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 下发类型
typedef NS_OPTIONS(NSInteger, IssuedDataType) {
    IssuedDataNone              = 1 << 0,   //  不获取下发数据
    IssuedDataAll               = 1 << 1,   //  获取所有下发数据(订阅, 广告, 评分, 渠道开关)
    IssuedDataSub               = 1 << 2,   //  sub下发
    IssuedDataAd                = 1 << 3,   //  广告下发
    IssuedDataRating            = 1 << 4,   //  评分下发
    IssuedDataChannelSwitch     = 1 << 5,   //  渠道开关下发
    IssuedDataProjectCfg        = 1 << 6    //  项目配置下发
};

/// 用于 暴露 用OC/C/C++实现的功能 给swift调用

FOUNDATION_EXTERN double OCBenchmark(void (^block)(void)); 

@interface _ExceptionCatcher: NSObject

+ (BOOL)catchException:(__attribute__((noescape)) void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

NS_ASSUME_NONNULL_END
