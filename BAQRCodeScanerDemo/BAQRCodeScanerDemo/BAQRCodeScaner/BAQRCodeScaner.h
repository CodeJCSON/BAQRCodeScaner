//
//  BAQRCodeScaner.h
//  hookTest
//
//  Created by 博爱 on 16/4/5.
//  Copyright © 2016年 博爱之家. All rights reserved.
//

#import <UIKit/UIKit.h>

/*! QRString 扫描返回的字符串 */
typedef void(^returnQRString)(NSString *QRString);

@import AVFoundation;
@interface BAQRCodeScaner : UIViewController

/*! 扫描完成回调 */
@property (nonatomic, copy) returnQRString returnQRString;

/*!
 *  首先要验证设备是否支持扫描
 *
 *  @param metadataObjectTypes 支持的扫描参数 如：AVMetadataObjectTypeQRCode
 *
 *  @return YES 支持，NO 不支持
 */
+ (BOOL )supportsMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes;


@end
