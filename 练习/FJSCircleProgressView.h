//
//  FJSCircleProgressView.h
//  练习
//
//  Created by 付金诗 on 16/6/15.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJSCircleProgressView : UIView
@property (nonatomic,strong)NSString * centerString;/**< 中间label上的文字 */
@property (nonatomic, assign)CGFloat progress;/**< 进度 0~1之间 */


+ (instancetype)circleLoadingViewWithFrame:(CGRect)frame LineColor:(UIColor *)lineColor LineBackgroundColor:(UIColor *)lineBackgroundColor;
@end
