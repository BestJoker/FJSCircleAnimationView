
//
//  FJSCircleProgressView.m
//  练习
//
//  Created by 付金诗 on 16/6/15.
//  Copyright © 2016年 www.fujinshi.com. All rights reserved.
//

#import "FJSCircleProgressView.h"
#import <CoreText/CoreText.h>

NSString * const FJSCircleProgressCircleAnimationKey = @"FJSCircleProgressCircleAnimationKey";
NSString * const FJSCircleProgressTextAnimationKey = @"FJSCircleProgressTextAnimationKey";

@interface FJSCircleProgressView ()
@property (nonatomic,assign)CGFloat animationDuration;/**< 动画时间*/
@property (nonatomic,assign)CGFloat lineWidth;/**<线的宽度 */
@property (nonatomic,strong)UIColor * lineBackgroundColor;
@property (nonatomic,strong)UIColor * lineColor;

@property (nonatomic,strong)CAShapeLayer * circleBackgroundLayer;
@property (nonatomic,strong)CALayer * circleLayer;
@property (nonatomic,strong)CAShapeLayer * circleAniamtionLayer;
@property (nonatomic, strong) CAGradientLayer *circleMaskLayer;

@property (nonatomic,strong)CAShapeLayer * textBackgroundLayer;
@property (nonatomic,strong)CAShapeLayer * textAnimationLayer;
@end
@implementation FJSCircleProgressView

+ (instancetype)circleLoadingViewWithFrame:(CGRect)frame LineColor:(UIColor *)lineColor LineBackgroundColor:(UIColor *)lineBackgroundColor
{
    return [[FJSCircleProgressView alloc] initWithFrame:frame LineColor:lineColor LineBackgroundColor:lineBackgroundColor];
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
        self.animationDuration = 0.2;
        [self setupCircleAnimaionLayer];
        [self setupTextAnimationLayer];
        [self updatePath:0.0];
    }
    return self;
}
- (void)setupCircleAnimaionLayer
{
    UIBezierPath *path = [self getBezierPathWithScale];
    //1.创建一个一直存在的底部环形
    self.circleBackgroundLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.circleBackgroundLayer.bounds = self.layer.bounds;
    self.circleBackgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.circleBackgroundLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleBackgroundLayer.lineWidth = self.lineWidth;
    self.circleBackgroundLayer.strokeColor = [self.lineBackgroundColor colorWithAlphaComponent:0.3].CGColor;
    self.circleBackgroundLayer.path = path.CGPath;
    [self.layer addSublayer:self.circleBackgroundLayer];
    
    //2.创建一段1/4的弧形
    self.circleAniamtionLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.circleAniamtionLayer.bounds = self.layer.bounds;
    self.circleAniamtionLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.circleAniamtionLayer.lineCap = @"round";
    self.circleAniamtionLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleAniamtionLayer.lineWidth = self.lineWidth;
    self.circleAniamtionLayer.strokeColor = self.lineColor.CGColor;
    self.circleAniamtionLayer.path = path.CGPath;
    
    //3.给上面一段弧形添加渐变颜色
    self.circleMaskLayer = [[CAGradientLayer alloc] initWithLayer:self.layer];
    self.circleMaskLayer.bounds = self.layer.bounds;
    self.circleMaskLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //切记这个数组中装的是CGColor而不是UIColor 否则不会出现颜色渐变.
    self.circleMaskLayer.colors = [FJSCircleProgressView gradientColorArrayWithColor:@[self.lineBackgroundColor,self.lineColor,self.lineBackgroundColor]];
    self.circleMaskLayer.locations = @[@(0), @(0.5), @(1)];
    self.circleMaskLayer.startPoint = CGPointMake(0, 0);
    self.circleMaskLayer.endPoint = CGPointMake(1, 1);
    [self.circleMaskLayer setMask:self.circleAniamtionLayer];
    //4.创建一条layer,来加载这个渐变的masklayer.方便我们后期通知动画的变化,而不是直接添加到self.layer上去.
    self.circleLayer = [[CALayer alloc] initWithLayer:self.layer];
    self.circleLayer.bounds = self.layer.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.circleLayer addSublayer:self.circleMaskLayer];
    [self.layer addSublayer:self.circleLayer];

}

#pragma mark -- 设置文字的变化layer
- (void)setupTextAnimationLayer
{
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:(self.centerString.length?self.centerString:@"")];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.bounds.size.width * 0.2] range:NSMakeRange(0, text.length)];
    UIBezierPath *path = [FJSCircleProgressView pathRefFromText:text reversed:YES];
    CGPoint position  = CGPointMake(CGRectGetMaxX(self.bounds) - CGRectGetMidX(path.bounds), CGRectGetMaxY(self.bounds)- CGRectGetMidY(path.bounds));
    
    self.textBackgroundLayer  = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.textBackgroundLayer .bounds        = self.layer.bounds;
    self.textBackgroundLayer .position      = position;
    self.textBackgroundLayer .fillColor     = [UIColor clearColor].CGColor;
    self.textBackgroundLayer .lineWidth     = self.lineWidth / 6;
    self.textBackgroundLayer .strokeColor   = self.lineBackgroundColor.CGColor;
    self.textBackgroundLayer .path          = path.CGPath;
    [self.layer addSublayer:self.textBackgroundLayer ];
    
    self.textAnimationLayer = [[CAShapeLayer alloc] initWithLayer:self.layer];
    self.textAnimationLayer.bounds        = self.layer.bounds;
    self.textAnimationLayer.position      = position;
    self.textAnimationLayer.fillColor     = [UIColor clearColor].CGColor;
    self.textAnimationLayer.lineWidth     = self.lineWidth / 6;
    self.textAnimationLayer.strokeColor   = self.lineColor.CGColor;
    self.textAnimationLayer.path          = path.CGPath;
    [self.layer addSublayer:self.textAnimationLayer];
}


+ (UIBezierPath *)pathRefFromText:(NSAttributedString *)text reversed: (BOOL)reversed
{
    CGMutablePathRef letters = CGPathCreateMutable();
    CTLineRef line           = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)text);
    CFArrayRef runArray      = CTLineGetGlyphRuns(line);
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++){
        CTRunRef run      = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++){
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            CGPathRef letter       = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            CGAffineTransform t    = CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(letters, &t, letter);
            CGPathRelease(letter);
        }
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:letters];
    CGRect boundingBox = CGPathGetBoundingBox(letters);
    CGPathRelease(letters);
    CFRelease(line);
    
    [path applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
    [path applyTransform:CGAffineTransformMakeTranslation(0.0, boundingBox.size.height)];
    
    if (reversed) {
        return [path bezierPathByReversingPath] ;
    }
    return path;
}


-(void)setCenterString:(NSString *)centerString
{
    _centerString = centerString;
    [self setupTextAnimationLayer];
    [self updatePath:0.0];
}


#pragma mark -- 进行圆弧路线的创建
- (UIBezierPath *)getBezierPathWithScale
{
    const double DOUBLE_M_PI = 2.0 * M_PI;
    const double startAngle = 0.75 * DOUBLE_M_PI;
    const double endAngle = startAngle + DOUBLE_M_PI;
    CGFloat width = self.frame.size.width;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, width / 2)
                                          radius:width /2 - self.lineWidth
                                      startAngle:startAngle
                                        endAngle:endAngle
                                       clockwise:YES];
}


+ (NSArray *)gradientColorArrayWithColor:(NSArray *)colors{
    if (!colors) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) {
        [array addObject:(id)color.CGColor];
    }
    return array;
}


-(void)setProgress:(CGFloat)progress
{
    progress = MAX(MIN(progress, 1.0), 0.0); // keep it between 0 and 1
    if (_progress == progress) {
        return;
    }
    [self animateToProgress:progress];
    [self updatePath:progress];
    _progress = progress;
}

#pragma mark --
- (void)animateToProgress:(float)progress {
    [self stopAnimation];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration          = self.animationDuration;
    animation.fromValue         = @(self.progress);
    animation.toValue           = @(progress);
    animation.delegate          = self;
    [self.circleAniamtionLayer addAnimation:animation forKey:FJSCircleProgressCircleAnimationKey];
    [self.textAnimationLayer addAnimation:animation forKey:FJSCircleProgressTextAnimationKey];
    _progress = progress;
}

- (void)updatePath:(float)progress {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.circleAniamtionLayer.strokeEnd = progress;
    self.textAnimationLayer.strokeEnd = progress;
    [CATransaction commit];
}

- (void)stopAnimation {
    [self.circleAniamtionLayer removeAnimationForKey:FJSCircleProgressCircleAnimationKey];
    [self.textAnimationLayer removeAnimationForKey:FJSCircleProgressTextAnimationKey];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
