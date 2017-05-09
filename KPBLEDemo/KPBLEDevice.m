//
//  KPBLEDevice.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPBLEDevice.h"

@implementation KPBLEDevice
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
    }
    return self;
}

- (void)interrogateAndValidate {
    [_peripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        if (peripheral.services) {
            for (CBService *service in peripheral.services) {
                KPLog(@"发现service: %@",service);
                [_peripheral discoverCharacteristics:nil forService:service];
            }
        } else {
            KPLog(@"%@: 未找到对应的service",self.class.description);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        KPLog(@"发现characteristic: %@",characteristic);
        KPLog(@"读取characteristic的value");
        [peripheral readValueForCharacteristic:characteristic];
        // 设置通知
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *data = characteristic.value;
    Byte *resultByte = (Byte *)[data bytes];
    
    KPLog(@"获取byte:%s",resultByte);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        KPLog(@"通知获取characteristic: %@",characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if (!error) {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        _RSSI = RSSI;
    }
}

@end
