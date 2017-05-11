//
//  KPGattSerialProfile.h
//  KPBLEDemo
//
//  Created by CPX on 10/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KPPeripheralProtocol.h"

#define GLOBAL_SERIAL_SERVICE_UUID @"FFE0"
#define GLOBAL_SERIAL_READ_UUID @"FFE1"
#define GLOBAL_SERIAL_WRITE_UUID @"FFE2"

@protocol KPGattSerialProfileDelegate;
@interface KPGattSerialProfile : NSObject
@property (nonatomic, weak) id <KPGattSerialProfileDelegate> delegate;
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral delegate:(id<KPGattSerialProfileDelegate>) delegate;
- (void)sendMessageData:(NSData *)data;
@end

@protocol KPGattSerialProfileDelegate <NSObject>
- (void)gattSerialProfile:(KPGattSerialProfile *)profile receiveIncomingData:(NSData *)data;
@end
