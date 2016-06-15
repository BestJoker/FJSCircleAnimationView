//
//  FJSCircleLoadingView.m
//  练习
//
//  Created by 付金诗 on 16/6/15.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import "FJSCircleLoadingView.h"

@interface FJSCircleLoadingView ()
@property (nonatomic, strong) UILabel * centerLabel;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor * lineBackgroundColor;
@property (nonatomic, strong) UIColor * lineColor;

@property (nonatomic, strong) CAShapeLayer * circleBackgroundLayer;
@property (nonatomic, strong) CALayer * circleLayer;
@property (nonatomic, strong) CAGradientLayer * circleMaskLayer;
@property (nonatomic, strong) CAShapeLayer * circleAnimLayer;
@end
@implementation FJSCircleLoadingView

+ (instancetype)circleLoadingViewWithFrame:(CGRect)frame LineColor:(UIColor *)lineColor LineBackgroundColor:(UIColor *)lineBackgroundColor
{
    return [[FJSCircleLoadingView alloc] initWithFrame:frame LineColor:lineColor LineBackgroundColor:lineBackgroundColor];
}

- (instancetype)initWithFrame:(CGRect)frame LineColor:(UIColor *)lineColor LineBackgroundColor:(UIColor *)lineBackgroundColor
{
    self = [super initWithFrame:frame];
    if (self) {
        //找到宽和高的最小值,为了保证视图是圆形的所以需要重新设置frame.
        CGFloat minWidth = MIN(frame.size.width, frame.size.height);
        self.lineWidth = minWidth / 10;
        self.lineColor = lineColor;
        self.lineBackgroundColor = lineBackgroundColor;
        self.bounds = CGRectMake(0, 0, minWidth, minWidth);
        self.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        //创建中间的label
        UILabel *label   = [[UILabel alloc] initWithFrame:CGRectMake(minWidth * 0.2, minWidth * 0.2, minWidth * 0.6, minWidth * 0.6)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = lineColor;
        label.font = [UIFont systemFontOfSize:minWidth * 0.4];
        [self addSubview:label];
        self.centerLabel = label;
        
        [self setupBackgroundLayer];
        [self setupAnimationLayer];
        [self startAnimating];
    }
    return self;
}
#pragma mark -- 创建各种Layer
- (void)setupBackgroundLayer
{
    //1.创建一个一直存在的底部环形
    self.circleBackgroundLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.circleBackgroundLayer.bounds = self.layer.bounds;
    self.circleBackgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.circleBackgroundLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleBackgroundLayer.lineWidth = self.lineWidth;
    self.circleBackgroundLayer.strokeColor = [self.lineBackgroundColor colorWithAlphaComponent:0.3].CGColor;
    self.circleBackgroundLayer.path = [self getBezierPathWithScale:1.0].CGPath;
    [self.layer addSublayer:self.circleBackgroundLayer];
}

#pragma mark -- 设置动画的圆弧
- (void)setupAnimationLayer
{
    //2.创建一段1/4的弧形
    self.circleAnimLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.circleAnimLayer.bounds = self.layer.bounds;
    self.circleAnimLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.circleAnimLayer.lineCap = @"round";
    self.circleAnimLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleAnimLayer.lineWidth = self.lineWidth;
    self.circleAnimLayer.strokeColor = self.lineColor.CGColor;
    self.circleAnimLayer.path = [self getBezierPathWithScale:0.25].CGPath;
    
    //3.给上面一段弧形添加渐变颜色
    self.circleMaskLayer = [[CAGradientLayer alloc] initWithLayer:self.layer];
    self.circleMaskLayer.bounds = self.layer.bounds;
    self.circleMaskLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //切记这个数组中装的是CGColor而不是UIColor 否则不会出现颜色渐变.
    self.circleMaskLayer.colors = [NSArray arrayWithObjects:(id)[self.lineColor colorWithAlphaComponent:0.0].CGColor,(id)[self.lineColor colorWithAlphaComponent:0.8].CGColor,(id)[self.lineColor colorWithAlphaComponent:1.0].CGColor, nil];
    self.circleMaskLayer.locations = @[@(0),@(1)];
    self.circleMaskLayer.startPoint = CGPointMake(0.5, 0);
    self.circleMaskLayer.endPoint = CGPointMake(1, 0.5);
    [self.circleMaskLayer setMask:self.circleAnimLayer];
    
    //4.创建一条layer,来加载这个渐变的masklayer.方便我们后期通知动画的变化,而不是直接添加到self.layer上去.
    self.circleLayer = [[CALayer alloc] initWithLayer:self.layer];
    self.circleLayer.bounds = self.layer.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.circleLayer addSublayer:self.circleMaskLayer];
    [self.layer addSublayer:self.circleLayer];
}

#pragma mark -- 根据比例来进行圆弧路线的创建
- (UIBezierPath *)getBezierPathWithScale:(CGFloat)scale
{
    const double DOUBLE_M_PI = 2.0 * M_PI;
    const double startAngle = 0.75 * DOUBLE_M_PI;
    const double endAngle = startAngle +scale * DOUBLE_M_PI;
    CGFloat width = self.frame.size.width;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, width / 2)
                                          radius:width /2 - self.lineWidth
                                      startAngle:startAngle
                                        endAngle:endAngle
                                       clockwise:YES];
}

#pragma mark -- 开启动画
- (void)startAnimating
{
    /* 5.开始动画
    1.CABasicAnimation
    通过设定起始点，终点，时间，动画会沿着你这设定点进行移动。可以看做特殊的CAKeyFrameAnimation
    2.CAKeyframeAnimation
    Keyframe顾名思义就是关键点的frame，你可以通过设定CALayer的始点、中间关键点、终点的frame，时间，动画会沿你设定的轨迹进行移动
    3.CAAnimationGroup
    Group也就是组合的意思，就是把对这个Layer的所有动画都组合起来。PS：一个layer设定了很多动画，他们都会同时执行，如何按顺序执行我到时候再讲。
    4.CATransition
    这个就是苹果帮开发者封装好的一些动画，
     */
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform";
    NSValue *val1 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0 * M_PI, 0, 0, 1)];
    NSValue *val2 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.5 * M_PI, 0, 0, 1)];
    NSValue *val3 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.0 * M_PI, 0, 0, 1)];
    NSValue *val4 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.5 * M_PI, 0, 0, 1)];
    NSValue *val5 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(2.0 * M_PI, 0, 0, 1)];
    //一个数组，提供了一组关键帧的值，  当使用path的 时候 values的值自动被忽略。
    animation.values = @[val1, val2, val3, val4, val5];
    animation.duration = 1.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    //控制动画运行的节奏
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.circleLayer addAnimation:animation forKey:@"circleLayerAnimation"];
    
}

#pragma mark -- 结束动画
- (void)stopAnimating{
    [self.circleLayer removeAnimationForKey:@"circleLayerAnimation"];
}


-(void)setCenterText:(NSString *)centerText
{
    _centerText = centerText;
    self.centerLabel.text = centerText;
}


/*
 Gradient：本身就是梯度的意思，所以在这里就是作为渐变色来理解
 1，CAGradientLayer用于处理渐变色的层结构
 2，CAGradientLayer的渐变色可以做隐式动画
 3，大部分情况下，CAGradientLayer时和CAShapeLayer配合使用的。关于CAShapeLayer可以看我的这篇博客
 
 在bundle中,"GradientLayer坐标系.png"图片
 根据上图的坐标，设定好起点和终点，渐变色的方向就会根据起点指向终点的方向来渐变了。呆会代码里会有写。
 
 1，CAGradientLayer的坐标系统是从（0，0）到（1，1）绘制的矩形
 2，CAGradientLayer的frame值的size不为正方形的话，坐标系统会被拉伸
 3，CAGradientLayer的startPoint和endPoint会直接决定颜色的绘制方向
 4，CAGradientLayer的颜色分割点时以0到1的比例来计算的
 */


/*
 - IOS 核心动画之CAKeyframeAnimation
 
 - 简单介绍
 
 是CApropertyAnimation的子类，跟CABasicAnimation的区别是：CABasicAnimation只能从一个数值(fromValue)变到另一个数值(toValue)，而CAKeyframeAnimation会使用一个NSArray保存这些数值
 
 - 属性解析：
 
 - values：就是上述的NSArray对象。里面的元素称为”关键帧”(keyframe)。动画对象会在指定的时间(duration)内，依次显示values数组中的每一个关键帧
 
 - path：可以设置一个CGPathRef\CGMutablePathRef,让层跟着路径移动。path只对CALayer的anchorPoint和position起作用。如果你设置了path，那么values将被忽略
 
 - keyTimes：可以为对应的关键帧指定对应的时间点,其取值范围为0到1.0,keyTimes中的每一个时间值都对应values中的每一帧.当keyTimes没有设置的时候,各个关键帧的时间是平分的
 
 - 说明：CABasicAnimation可看做是最多只有2个关键帧的CAKeyframeAnimation
 
 - Values方式：
 
 - CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
 
 animation.keyPath = @"position";
 
 NSValue *value1=[NSValue valueWithCGPoint:CGPointMake(100, 100)];
 
 NSValue *value2=[NSValue valueWithCGPoint:CGPointMake(200, 100)];
 
 NSValue *value3=[NSValue valueWithCGPoint:CGPointMake(200, 200)];
 
 NSValue *value4=[NSValue valueWithCGPoint:CGPointMake(100, 200)];
 
 NSValue *value5=[NSValue valueWithCGPoint:CGPointMake(100, 100)];
 
 animation.values=@[value1,value2,value3,value4,value5]; animation.repeatCount=MAXFLOAT;
 
 animation.removedOnCompletion = NO;
 
 animation.fillMode = kCAFillModeForwards;
 
 animation.duration = 4.0f;
 
 animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 
 animation.delegate=self;
 
 [self.myView.layer addAnimation:animation forKey:nil];
 
 - Path方式：
 
 - CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
 
 animation.keyPath = @"position";
 
 CGMutablePathRef path=CGPathCreateMutable();
 
 CGPathAddEllipseInRect(path, NULL, CGRectMake(150, 100, 100, 100));
 
 animation.path=path;
 
 CGPathRelease(path);
 
 animation.repeatCount=MAXFLOAT;
 
 animation.removedOnCompletion = NO;
 
 animation.fillMode = kCAFillModeForwards;
 
 animation.duration = 4.0f;
 
 animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 
 animation.delegate=self;
 
 [self.myView.layer addAnimation:animation forKey:nil];
 
 - keyPath可以使用的key
 
 - #define angle2Radian(angle) ((angle)/180.0*M_PI)
 
 - transform.rotation.x 围绕x轴翻转 参数：角度 angle2Radian(4)
 
 transform.rotation.y 围绕y轴翻转 参数：同上
 
 transform.rotation.z 围绕z轴翻转 参数：同上
 
 transform.rotation 默认围绕z轴
 
 transform.scale.x x方向缩放 参数：缩放比例 1.5
 
 transform.scale.y y方向缩放 参数：同上
 
 transform.scale.z z方向缩放 参数：同上
 
 transform.scale 所有方向缩放 参数：同上
 
 transform.translation.x x方向移动 参数：x轴上的坐标 100
 
 transform.translation.y x方向移动 参数：y轴上的坐标
 
 transform.translation.z x方向移动 参数：z轴上的坐标
 
 transform.translation 移动 参数：移动到的点 （100，100）
 
 opacity 透明度 参数：透明度 0.5
 
 backgroundColor 背景颜色 参数：颜色 (id)[[UIColor redColor] CGColor]
 
 cornerRadius 圆角 参数：圆角半径 5
 
 borderWidth 边框宽度 参数：边框宽度 5
 
 bounds 大小 参数：CGRect
 
 contents 内容 参数：CGImage
 
 contentsRect 可视内容 参数：CGRect 值是0～1之间的小数
 
 hidden 是否隐藏
 
 position
 
 shadowColor
 
 shadowOffset
 
 shadowOpacity
 
 shadowRadius
 
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
