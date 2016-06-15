//
//  RootViewController.m
//  练习
//
//  Created by 付金诗 on 15/12/17.
//  Copyright © 2015年 www.fujinshi.com. All rights reserved.
//

#import "RootViewController.h"
#import "FJSCircleLoadingView.h"
@interface RootViewController ()
@property (nonatomic,strong)FJSCircleLoadingView * cirCleView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cirCleView = [FJSCircleLoadingView circleLoadingViewWithFrame:CGRectMake(60, 100, 100, 100) LineColor:[UIColor blueColor] LineBackgroundColor:[UIColor greenColor]];
    self.cirCleView.centerText = @"诗";
    [self.view addSubview:self.cirCleView];
    
    
    
    
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
