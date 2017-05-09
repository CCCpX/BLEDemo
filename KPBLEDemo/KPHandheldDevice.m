//
//  KPHandheldDevice.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPHandheldDevice.h"
#import "KPHandheldDevice+Protected.h"

@interface KPHandheldDevice ()
@property (nonatomic, readwrite) KPHandheldDeviceState state;
@end

@implementation KPHandheldDevice
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super initWithPeripheral:peripheral];
    if (self) {
        
    }
    return self;
}

- (void)interrogateAndValidate {
    //TODO 此处可以收集设备、电池、gatt的信息
    [super interrogateAndValidate];
}

- (CBPeripheral *)peripheral {
    return _peripheral;
}

- (NSUUID *)identifier {
    if (_peripheral && _peripheral.identifier) {
        return _peripheral.identifier;
    }
    return nil;
}

- (NSString *)name {
    if (_peripheral.name) {
        return _peripheral.name;
    }
    return [_advertisementData objectForKey:CBAdvertisementDataLocalNameKey]?:@"Unknown";
}

- (KPHandheldDeviceState)state {
    return _state;
}

- (NSDate *)lastDiscovered {
    return _lastDiscovered;
}

- (NSDictionary *)advertisementData {
    return _advertisementData;
}

- (NSNumber *)RSSI {
    return _RSSI;
}

- (void)setLastDiscovered:(NSDate *)lastDiscovered {
    _lastDiscovered = lastDiscovered;
}

- (void)setAdvertisementData:(NSDictionary *)advertisementData {
    _advertisementData = advertisementData;
}

- (void)setRSSI:(NSNumber *)RSSI {
    _RSSI = RSSI;
}

@end
