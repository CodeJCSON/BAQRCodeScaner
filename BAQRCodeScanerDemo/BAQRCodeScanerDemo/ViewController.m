//
//  ViewController.m
//  BAQRCodeScanerDemo
//
//  Created by 博爱 on 16/4/5.
//  Copyright © 2016年 博爱之家. All rights reserved.
//

#import "ViewController.h"
#import "BAQRCodeScaner.h"
#import "BABaseViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

- (IBAction)scanBtnClick:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"扫描二维码";
}

- (IBAction)scanBtnClick:(UIButton *)sender
{
    BAQRCodeScaner *scanerVC = [[BAQRCodeScaner alloc] init];
    [self.navigationController pushViewController:scanerVC animated:YES];
    
    __block typeof(scanerVC) weakController = scanerVC;
    
    /*! QRString 扫描返回的字符串 */
    scanerVC.returnQRString = ^(NSString *QRString){
        NSLog(@"%@",QRString);
        
        if ([QRString containsString:@"www."] || [QRString containsString:@"http://"] )
        {
            BABaseViewController *webVC = [[BABaseViewController alloc] init];
            webVC.url = QRString;
            [weakController.navigationController pushViewController:webVC animated:YES];
        }
    };
}
@end
