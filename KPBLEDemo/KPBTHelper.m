//
//  KPBTHelper.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "KPBTHelper.h"

@implementation KPBTHelper

+ (NSError *) basicError:(NSString*)description domain:(NSString*)domain code:(KPHandheldDeviceError)code {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:errorDetail];
    KPLog(@"Error: %@ %@", error, [error userInfo]);
    return error;
}

@end
