//
//  KPHandheldManager.h
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPHandheldDevice.h"

@protocol KPHandheldManagerDelegate;
@interface KPHandheldManager : NSObject
/// 主设备对象的代理, (CoreBluetooth严重依赖回调模式)
@property (nonatomic, weak) id<KPHandheldManagerDelegate> delegate;
/// 初始化主设备对象并返回
- (instancetype)initWithDelegate:(id<KPHandheldManagerDelegate>)delegate;
/// 从之前保存的状态中初始化
- (instancetype)initWithDelegate:(id<KPHandheldManagerDelegate>)delegate stateRestorationIdentifier:(NSString *)stateRestorationIdentifier;

/// 开始扫描外围设备, error见KPBTError
- (void)startScan_error:(NSError **)error;
/// 停止扫描外围设备
- (void)stopScan_error:(NSError **)error;
/// 用户发起连接设备请求
- (void)connectToHandheld:(KPHandheldDevice *)device error:(NSError **)error;
/// 断开连接
- (void)disconnectToHandheld:(KPHandheldDevice *)device error:(NSError **)error;
/// 断开所有连接
- (void)disconnectFromAllHandheld:(NSError **)error;

@end

@protocol KPHandheldManagerDelegate <NSObject>
- (void)handheldManagerDidUpdateState:(KPHandheldManager *)hhManager;
- (void)handheldManager:(KPHandheldManager *)hhManager didDiscoverHandheld:(KPHandheldDevice *)handheld error:(NSError *)error;
- (void)handheldManager:(KPHandheldManager *)hhManager didConnectHandheld:(KPHandheldDevice *)handheld error:(NSError *)error;
- (void)handheldManager:(KPHandheldManager *)hhManager didDisconnectHandheld:(KPHandheldDevice *)handheld error:(NSError *)error;

@end
