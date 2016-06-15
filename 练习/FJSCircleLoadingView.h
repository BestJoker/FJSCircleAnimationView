//
//  FJSCircleLoadingView.h
//  练习
//
//  Created by 付金诗 on 16/6/15.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJSCircleLoadingView : UIView

@property (nonatomic, copy)NSString * centerText;

+ (instancetype)circleLoadingViewWithFrame:(CGRect)frame LineColor:(UIColor *)lineColor LineBackgroundColor:(UIColor *)lineBackgroundColor;


- (void)startAnimating;
- (void)stopAnimating;


@end
