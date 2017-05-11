//
//  KPHandheldDevice.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPHandheldDevice.h"
#import "KPHandheldDevice+Protected.h"
#import "KPGattSerialProfile.h"

@interface KPHandheldDevice ()<KPGattSerialProfileDelegate>
@property (nonatomic, readwrite) KPHandheldDeviceState state;
@property (nonatomic, strong) KPGattSerialProfile *gattSerialProfile;
@end

@implementation KPHandheldDevice
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super initWithPeripheral:peripheral];
    if (self) {
        
    }
    return self;
}

- (void)interrogateAndValidate {
    self.gattSerialProfile = [[KPGattSerialProfile alloc] initWithPeripheral:_peripheral delegate:self];
    _profiles = [NSArray arrayWithObjects:self.gattSerialProfile, nil];
    
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

- (void)sendSerialData:(NSData *)data {
    [self.gattSerialProfile sendMessageData:data];
}

#pragma mark - KPGattSerialProfileDelegate
- (void)gattSerialProfile:(KPGattSerialProfile *)profile receiveIncomingData:(NSData *)data {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheld:receiveSerialData:)]) {
        [self.delegate handheld:self receiveSerialData:data];
    }
}

#pragma mark - override method
- (void)rssiDidUpdateWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handheldDidUpdateRSSI:error:)]) {
        [self.delegate handheldDidUpdateRSSI:self error:error];
    }
}

@end
