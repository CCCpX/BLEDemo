//
//  KPBLEDevice.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPBLEDevice.h"
#import "KPGattSerialProfile.h"
#import "KPPeripheralProtocol.h"

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
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
                [profile peripheral:peripheral didDiscoverServices:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
                [profile peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
                [profile peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
                [profile peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didWriteValueForDescriptor:error:)]) {
                [profile peripheral:peripheral didWriteValueForDescriptor:descriptor error:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]) {
                [profile peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    for (id<KPPeripheralProtocol> profile in _profiles) {
        if (profile) {
            if ([profile respondsToSelector:@selector(peripheral:didReadRSSI:error:)]) {
                [profile peripheral:peripheral didReadRSSI:RSSI error:error];
            }
        }
    }
    _RSSI = RSSI;
    [self rssiDidUpdateWithError:error];
}

#pragma mark "Virtual" Methods
- (void)rssiDidUpdateWithError:(NSError *)error {
    
}

@end
