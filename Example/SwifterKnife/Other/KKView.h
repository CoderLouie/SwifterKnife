//
//  KKView.h
//  SwifterKnife_Example
//
//  Created by 李阳 on 2021/10/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (DesginSize)
@property (nonatomic, assign) CGSize desginSize;
@end

@interface KKView : UIView

@end

@interface ATButton : UIButton

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@end

@interface NSObject (Add)
+ (void)printAllMethods;
@end

//@interface UIImageView (Private)
//
////@property (nonatomic, assign) NSInteger drawMode;
//
//@end

NS_ASSUME_NONNULL_END
