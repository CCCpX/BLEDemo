//
//  KPGattSerialProfile.m
//  KPBLEDemo
//
//  Created by CPX on 10/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPGattSerialProfile.h"

@interface KPGattSerialProfile ()<KPPeripheralProtocol>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *serialService;
@property (nonatomic, strong) CBCharacteristic *serialReadCharacteristic;
@property (nonatomic, strong) CBCharacteristic *serialWriteCharacteristic;
@end

@implementation KPGattSerialProfile

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral delegate:(id<KPGattSerialProfileDelegate>)delegate {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.delegate = delegate;
    }
    return self;
}

- (void)sendMessageData:(NSData *)data {
    if (data.length) {
        for (CBCharacteristic *characteristic in self.serialService.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLOBAL_SERIAL_WRITE_UUID]]) {
                [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        if (peripheral.services) {
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[CBUUID UUIDWithString:GLOBAL_SERIAL_SERVICE_UUID]]) {
//                    KPLog(@"发现串联服务: %@",service);
                    self.serialService = service;
                    [_peripheral discoverCharacteristics:nil forService:service];
                    [self processCharacteristics];
                    if (self.serialReadCharacteristic) {
//                        KPLog(@"发现串联服务特征值");
                        if (self.serialReadCharacteristic.isNotifying) {
                            
                        } else {
                            [self.peripheral setNotifyValue:YES forCharacteristic:self.serialReadCharacteristic];
                        }
                    } else {
                        NSArray *characteristics = [NSArray arrayWithObjects:GLOBAL_SERIAL_READ_UUID, nil];
                        [self.peripheral discoverCharacteristics:characteristics forService:service];
                    }
                }
            }
        } else {
//            KPLog(@"%@: 未找到对应的service",self.class.description);
        }
    } else {
//        KPLog(@"无法获取对应的串联通信服务");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        if ([service isEqual:self.serialService]) {
            [self processCharacteristics];
            if (self.serialReadCharacteristic) {
//                KPLog(@"发现串联服务特征值");
                [peripheral readValueForCharacteristic:self.serialReadCharacteristic];
                if (!self.serialReadCharacteristic.isNotifying) {
                    [self.peripheral setNotifyValue:YES forCharacteristic:self.serialReadCharacteristic];
                }
            } else {
//                KPLog(@"%@: 未找到服务对应的特征值",self.class.description);
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        NSData *data = characteristic.value;
        if (self.delegate && [self.delegate respondsToSelector:@selector(gattSerialProfile:receiveIncomingData:)]) {
            [self.delegate gattSerialProfile:self receiveIncomingData:data];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
//        KPLog(@"通知获取characteristic: %@",characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
//        KPLog(@"外围设备接收数据失败:%@",characteristic.UUID.UUIDString);
    } else {
//        KPLog(@"外围设备接收数据成功:%@",characteristic.UUID.UUIDString);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        
    }
}

#pragma mark - private method
- (void)processCharacteristics {
    if (self.serialService) {
        if (self.serialService.characteristics) {
            for (CBCharacteristic *characteristic in self.serialService.characteristics) {
//                KPLog(@"获取特征值:%@",characteristic);
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLOBAL_SERIAL_READ_UUID]]) {
                    self.serialReadCharacteristic = characteristic;
                } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLOBAL_SERIAL_WRITE_UUID]]) {
                    self.serialWriteCharacteristic = characteristic;
                }
            }
        }
    }
}

@end
