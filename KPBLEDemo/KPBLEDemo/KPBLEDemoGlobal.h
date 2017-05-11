//
//  KPBLEDemoGlobal.h
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#ifndef KPBLEDemoGlobal_h
#define KPBLEDemoGlobal_h

// based on http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
#if DEBUG == 1
#define KPLog NSLog
#else
#define KPLog(...)
#endif

#endif /* KPBLEDemoGlobal_h */
