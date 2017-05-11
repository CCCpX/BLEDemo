//
//  KPHandheldDevice+Protected.h
//  KPBLEDemo
//
//  Created by CPX on 09/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPHandheldDevice.h"

@interface KPHandheldDevice (Protected)

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
-(void)interrogateAndValidate;

-(CBPeripheral*)peripheral;

-(void)setState:(KPHandheldDeviceState)state;
-(void)setRSSI:(NSNumber *)RSSI;
-(void)setAdvertisementData:(NSDictionary*)adData;
-(void)setLastDiscovered:(NSDate*)date;

@end
