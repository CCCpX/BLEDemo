//
//  KPHandheldManager.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPHandheldManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KPBTHelper.h"
#import "KPHandheldDevice+Protected.h"
#import "KPGattSerialProfile.h"

@interface KPHandheldManager ()<CBCentralManagerDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSDate *lastScanDate;
@property (nonatomic, strong) NSMutableDictionary *connectRecords;
@end

#define kServiceUUID @"74278BDA-B644-4520-8F0C-720EAF059935" //服务的UUID

@implementation KPHandheldManager

- (instancetype)init {
    return [self initWithDelegate:nil stateRestorationIdentifier:nil];
}

- (instancetype)initWithDelegate:(id<KPHandheldManagerDelegate>)delegate {
    return [self initWithDelegate:delegate stateRestorationIdentifier:nil];
}

- (instancetype)initWithDelegate:(id<KPHandheldManagerDelegate>)delegate stateRestorationIdentifier:(NSString *)stateRestorationIdentifier {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.connectRecords = [NSMutableDictionary dictionary];
        if (stateRestorationIdentifier.length>0) {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:stateRestorationIdentifier}];
        } else {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        }
    }
    return self;
}

- (void)startScan_error:(NSError *__autoreleasing *)error {
    // 停止所有之前的扫描
    [self stopScan_error:nil];
    // 记录开始扫描的时间
    self.lastScanDate = [NSDate date];
    // 检查蓝牙是否打开
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (error) { *error = [KPBTHelper basicError:@"Bluetooth is not on" domain:NSStringFromClass([self class]) code:DeviceError_BluetoothNotOn]; return; }
    }
    
    // 1. 取回已知的外围设备(曾经被发现或连接过)
    NSArray *knownPeripherals = [self.centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObjects:[CBUUID UUIDWithString:kServiceUUID], nil]];
    for (CBPeripheral *peripheral in knownPeripherals) {
        KPHandheldDevice *handheld;
        if ((handheld = [self.connectRecords objectForKey:peripheral.identifier])) {
            [self notifyDelegateOfDiscoverHandheld:handheld error:nil];
        } else {
            //  如果此设备正在被其他App连接时
            if ((handheld = [[KPHandheldDevice alloc] initWithPeripheral:peripheral])) {
                [self.connectRecords setObject:handheld forKey:handheld.identifier];
                [handheld.peripheral readRSSI];
                handheld.lastDiscovered = [NSDate date];
                handheld.state = DeviceState_Discovered;
                [self notifyDelegateOfDiscoverHandheld:handheld error:nil];
            }
        }
    }
    // 2. 取回已经被连接的外围设备(同一部手机上的其他App)
    NSArray *conectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:kServiceUUID], nil]];
    for (CBPeripheral *peripheral in conectedPeripherals) {
        KPHandheldDevice *handheld;
        // 如果连接记录里已经有此设备, 就直接调用self的didDiscover代理
        if ((handheld = [self.connectRecords objectForKey:peripheral.identifier])) {
            [self notifyDelegateOfDiscoverHandheld:handheld error:nil];
        } else {
            //  如果此设备正在被其他App连接时
            if ((handheld = [[KPHandheldDevice alloc] initWithPeripheral:peripheral])) {
                [self.connectRecords setObject:handheld forKey:handheld.identifier];
                [handheld.peripheral readRSSI];
                handheld.lastDiscovered = [NSDate date];
                handheld.state = DeviceState_Discovered;
                [self notifyDelegateOfDiscoverHandheld:handheld error:nil];
            }
        }
    }
//    KPLog(@"开始扫描...");
    // 3. 扫描周边所有的设备
    NSArray *services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:GLOBAL_SERIAL_SERVICE_UUID], nil];
    [self.centralManager scanForPeripheralsWithServices:services options:0];
}

- (void)stopScan_error:(NSError *__autoreleasing *)error {
    // 蓝牙必须在打开及可用状态
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (error) { *error = [KPBTHelper basicError:@"Bluetooth is not on" domain:NSStringFromClass([self class]) code:DeviceError_BluetoothNotOn]; return; }
    }
    // 清除过时的连接记录
    [self removeStaleDevice:self.lastScanDate];
    [self.centralManager stopScan];
//    KPLog(@"停止扫描.");
}

- (void)connectToHandheld:(KPHandheldDevice *)device_ error:(NSError *__autoreleasing *)error {
    KPHandheldDevice *device = [self.connectRecords objectForKey:device_.identifier];
    if (!device) {
        if (error) { *error = [KPBTHelper basicError:@"未找到对应的外围设备" domain:NSStringFromClass([self class]) code:DeviceError_NoPeriphealDiscovered]; return; }
    } else if (device.state == DeviceState_ConnectedAndValidated) {
        if (error) { *error = [KPBTHelper basicError:@"设备已被连接" domain:NSStringFromClass([self class]) code:DeviceError_AlreadyConnected]; return; }
    } else if (device.state == DeviceState_AttemptingConnection || device.state == DeviceState_AttemptingValidation) {
        if (error) { *error = [KPBTHelper basicError:@"设备正在连接中" domain:NSStringFromClass([self class]) code:DeviceError_AlreadyConnecting]; return; }
    } else if (device.state != DeviceState_Discovered) {
        if (error) { *error = [KPBTHelper basicError:@"不支持的设备类型" domain:NSStringFromClass([self class]) code:DeviceError_DeviceNotEligible]; return; }
    }
    // 标记设备为正在连接中...
    device.state = DeviceState_AttemptingConnection;
    // 尝试连接设备
    [self.centralManager connectPeripheral:device.peripheral options:nil];
}

- (void)disconnectToHandheld:(KPHandheldDevice *)device_ error:(NSError *__autoreleasing *)error {
    KPHandheldDevice *device = [self.connectRecords objectForKey:device_.identifier];
    if (!device) {
        if (error) { *error = [KPBTHelper basicError:@"断开连接失败, 未找到对应的设备" domain:NSStringFromClass([self class]) code:DeviceError_FailedDisconnect]; return; }
    }
    if (device.peripheral.state != CBPeripheralStateConnected ||
        device.peripheral.state != CBPeripheralStateConnecting) {
        if (error) { *error = [KPBTHelper basicError:@"断开连接失败, 当前设备未连接" domain:NSStringFromClass([self class]) code:DeviceError_FailedDisconnect]; return; }
    }
    device.state = (device.peripheral.state == CBPeripheralStateConnected ? DeviceState_AttemptingDisconnection:DeviceState_Discovered);
    
    [self.centralManager cancelPeripheralConnection:device.peripheral];
    
    if ([device.name isEqualToString:@"Unknown"] && device.RSSI == nil) {
        device.state = DeviceState_Discovered;
        [self notifyDelegateOfDisconnectHandheld:device error:nil];
    }
}

- (void)disconnectFromAllHandheld:(NSError *__autoreleasing *)error {
    for (NSUUID *identifier in self.connectRecords) {
        KPHandheldDevice *device = [self.connectRecords objectForKey:identifier];
        if (device.state == DeviceState_ConnectedAndValidated ||
            device.state == DeviceState_AttemptingValidation) {
            [self disconnectToHandheld:device error:nil];
        }
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheldManagerDidUpdateState:)]) {
        [self.delegate handheldManagerDidUpdateState:self];
    }
    switch (central.state) {
        case CBManagerStatePoweredOn:
//            KPLog(@"%@: Bluetooth ON", self.class.description);
            break;
        default:
//            KPLog(@"%@: Bluetooth state error: %@",self.class.description, @(central.state));
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    KPHandheldDevice *device = [self getDeviceFromCBPerpheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    if (device) {
        // 通知我们的代理已发现设备
        [self notifyDelegateOfDiscoverHandheld:device error:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    KPLog(@"已连接设备:%@",peripheral);
    KPHandheldDevice *device = [self.connectRecords objectForKey:peripheral.identifier];
    if (!device) { return; }
    // 标记设备状态为已连接
    device.state = DeviceState_ConnectedAndValidated;
    [self notifyDelegateOfConnectHandheld:device error:nil];
    // 验证已连接的设备
    [device interrogateAndValidate];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    KPLog(@"连接失败:%@",peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    KPHandheldDevice *device = [self.connectRecords objectForKey:peripheral.identifier];
    if (!device || error) { return; }
    device.state = DeviceState_Discovered;
//    KPLog(@"成功断开连接");
    [self notifyDelegateOfDisconnectHandheld:device error:error];
}

#pragma mark - private method
- (void)notifyDelegateOfDiscoverHandheld:(KPHandheldDevice *)device error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheldManager:didDiscoverHandheld:error:)]) {
        [self.delegate handheldManager:self didDiscoverHandheld:device error:error];
    }
}

- (void)notifyDelegateOfConnectHandheld:(KPHandheldDevice *)device error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheldManager:didConnectHandheld:error:)]) {
        [self.delegate handheldManager:self didConnectHandheld:device error:nil];
    }
}

- (void)notifyDelegateOfDisconnectHandheld:(KPHandheldDevice *)device error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheldManager:didDisconnectHandheld:error:)]) {
        [self.delegate handheldManager:self didDisconnectHandheld:device error:nil];
    }
}

// 从delegate返回的数据配置`KPHandheldDevice`
- (KPHandheldDevice *)getDeviceFromCBPerpheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary <NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    KPHandheldDevice *device;
    // 已经被发现的设备, 准备连接
    if ((device = [self.connectRecords objectForKey:peripheral.identifier])) {
//        KPLog(@"发现连接过的设备:%@",peripheral.identifier);
        device.lastDiscovered = [NSDate date];
        device.RSSI = RSSI;
        device.advertisementData = advertisementData;
    } else {
        // 之前未被发现的新设备
//        KPLog(@"发现新设备:%@",peripheral.identifier);
        device = [[KPHandheldDevice alloc] initWithPeripheral:peripheral];
        device.RSSI = RSSI;
        device.lastDiscovered = [NSDate date];
        device.advertisementData = advertisementData;
        device.state = DeviceState_Discovered;
        [self.connectRecords setObject:device forKey:peripheral.identifier];
    }
    return device;
}

// 移除过时的连接记录
- (void)removeStaleDevice:(NSDate *)expirationDate {
    NSMutableArray *markToBeRemoved = [NSMutableArray array];
    for (NSUUID *identifier in self.connectRecords) {
        KPHandheldDevice *device = [self.connectRecords objectForKey:identifier];
        if (device.state == DeviceState_Discovered && [device.lastDiscovered compare:expirationDate] == NSOrderedAscending) {
            [markToBeRemoved addObject:device];
        }
    }
    for (NSUUID *identifier in markToBeRemoved) {
        [self.connectRecords removeObjectForKey:identifier];
    }
}

@end
