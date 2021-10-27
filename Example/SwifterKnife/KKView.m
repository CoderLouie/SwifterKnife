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


/*
 
 
 
 case .iPadPro12Inch5: return "iPad Pro (12.9-inch) (5th generation)"
 case .iPadPro11Inch3: return "iPad Pro (11-inch) (3rd generation)"
 case .iPad9: return "iPad (9th generation)"
 case .iPadMini6: return "iPad Mini (6th generation)"
 case .iPadPro12Inch4: return "iPad Pro (12.9-inch) (4th generation)"
 case .iPadPro11Inch2: return "iPad Pro (11-inch) (2nd generation)"
 case .iPadAir4: return "iPad Air (4th generation)"
 case .iPad8: return "iPad (8th generation)"
 case .iPadAir3: return "iPad Air (3rd generation)"
 case .iPad7: return "iPad (7th generation)"
 case .iPadMini5: return "iPad Mini (5th generation)"
 case .iPadPro12Inch3: return "iPad Pro (12.9-inch) (3rd generation)"
 case .iPadPro11Inch: return "iPad Pro (11-inch)"
 case .iPad6: return "iPad (6th generation)"
 case .iPadPro12Inch2: return "iPad Pro (12.9-inch) (2nd generation)"
 case .iPadPro10Inch: return "iPad Pro (10.5-inch)"
 case .iPad5: return "iPad (5th generation)"
 case .iPadPro9Inch: return "iPad Pro (9.7-inch)"
 case .iPadPro12Inch: return "iPad Pro (12.9-inch)"
 case .iPadMini4: return "iPad Mini 4"
 case .iPadAir2: return "iPad Air 2"
 case .iPad4: return "iPad (4th generation)"
 case .iPadMini3: return "iPad Mini 3"
 case .iPadAir: return "iPad Air"
 case .iPadMini2: return "iPad Mini 2"
 case .iPad3: return "iPad (3rd generation)"
 case .iPadMini: return "iPad Mini"
 case .iPad2: return "iPad 2"
 
 */
