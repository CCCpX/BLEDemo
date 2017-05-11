//
//  KPBLEDevice.h
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface KPBLEDevice : NSObject <CBPeripheralDelegate> {
    CBPeripheral *_peripheral;
    NSDictionary *_advertisementData;
    NSDate *_lastDiscovered;
    NSArray *_profiles;
    NSNumber *_RSSI;
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
-(void)interrogateAndValidate;

@end
