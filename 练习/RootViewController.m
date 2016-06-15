//
//  RootViewController.m
//  练习
//
//  Created by 付金诗 on 15/12/17.
//  Copyright © 2015年 www.fujinshi.com. All rights reserved.
//

#import "RootViewController.h"
#import "FJSCircleLoadingView.h"
#import "FJSCircleProgressView.h"
@interface RootViewController ()
@property (nonatomic,strong)FJSCircleLoadingView * cirCleView;
@property (nonatomic,strong)FJSCircleProgressView * progressView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cirCleView = [FJSCircleLoadingView circleLoadingViewWithFrame:CGRectMake(60, 100, 100, 100) LineColor:[UIColor redColor] LineBackgroundColor:[UIColor lightGrayColor]];
    self.cirCleView.centerText = @"Best";
    [self.view addSubview:self.cirCleView];
    
    [self.cirCleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(100);
        make.centerX.equalTo(self.view);
        make.width.and.height.equalTo(@100);
    }];
    
    self.progressView = [FJSCircleProgressView circleLoadingViewWithFrame:CGRectMake(60, 300, 100, 100) LineColor:[UIColor redColor] LineBackgroundColor:[UIColor lightGrayColor]];
    self.progressView.centerString = @"Joker";
    self.progressView.progress = 0.3;
    [self.view addSubview:self.progressView];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cirCleView.mas_bottom).with.offset(40);
        make.centerX.equalTo(self.view);
        make.width.and.height.equalTo(@100);
    }];
    
    UISlider * sliderView = [UISlider new];
    sliderView.value = self.progressView.progress;
    [sliderView addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderView];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%.2f",self.progressView.progress];

    [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset(40);
        make.right.equalTo(self.view).with.offset(-40);
    }];
    
}


- (void)sliderAction:(UISlider *)slider
{
    NSLog(@"value == %f",slider.value);
    self.navigationItem.title = [NSString stringWithFormat:@"%.2f",slider.value];
    self.progressView.progress = slider.value;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
