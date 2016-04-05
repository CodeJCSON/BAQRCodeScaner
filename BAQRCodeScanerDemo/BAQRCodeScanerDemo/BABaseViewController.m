//
//  BABaseViewController.m
//  BABaseProject
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "BABaseViewController.h"

@interface BABaseViewController ()

@end

@implementation BABaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *web = [UIWebView new];
    web.frame = self.view.bounds;
    
    [self.view addSubview:web];
    
    NSURL *urlS = [NSURL URLWithString:self.url];
    NSLog(@"正在打开网页：%@", self.url);
    NSURLRequest *request = [NSURLRequest requestWithURL:urlS];
    [web loadRequest:request];
    
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
