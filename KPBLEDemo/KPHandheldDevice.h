//
//  KPHandheldDevice.h
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPBLEDevice.h"
typedef NS_ENUM(NSInteger, KPHandheldDeviceError) {
    /**
     *  An input argument was invalid
     */
    DeviceError_InvalidArgument = 0,
    /**
     *  Bluetooth is not turned on
     */
    DeviceError_BluetoothNotOn,
    /**
     *  Device is not connected
     */
    DeviceError_NotConnected,
    /**
     *  No Peripheral discovered with corresponding UUID
     */
    DeviceError_NoPeriphealDiscovered,
    /**
     *  Device with UUID already connected to this device
     */
    DeviceError_AlreadyConnected,
    /**
     *  A device with this UUID is in the process of being connected to
     */
    DeviceError_AlreadyConnecting,
    /**
     *  The device's current state is not eligible for a connection attempt
     */
    DeviceError_DeviceNotEligible,
    /**
     *  No device with this UUID is currently connected
     */
    DeviceError_FailedDisconnect
};

typedef NS_ENUM(NSInteger, KPHandheldDeviceState) {
    /// Used for initialization and unknown error states
    DeviceState_Unknown = 0,
    /// device has been discovered by a central
    DeviceState_Discovered,
    /// device is attempting to connect with a central
    DeviceState_AttemptingConnection,
    /// device is undergoing validation
    DeviceState_AttemptingValidation,
    /// deivce is connected
    DeviceState_ConnectedAndValidated,
    /// deivce is undergoing disconnection
    DeviceState_AttemptingDisconnection,
    /// device is disconnected
    DeviceState_DisConnected
};

@interface KPHandheldDevice : KPBLEDevice

@property (nonatomic, readonly) NSUUID *identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) KPHandheldDeviceState state;
@property (nonatomic, readonly) NSDate *lastDiscovered;
@property (nonatomic, readonly) NSDictionary *advertisementData;
@property (nonatomic, readonly) NSNumber *RSSI;

@end
