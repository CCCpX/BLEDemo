//
//  KPBTHelper.h
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPHandheldDevice.h"

@interface KPBTHelper : NSObject

+(NSError *) basicError:(NSString *)description domain:(NSString *)domain code:(KPHandheldDeviceError)code;

@end
