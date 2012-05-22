//
//  MagilitySettings.h
//  Magility
//
//  Created by Jonas Nockert on 5/21/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagilitySettings : NSObject
+ (NSString *)getSettingSetDefault:(NSString *)key
                        defaultstr:(NSString *)defaultstr;
+ (void)setSetting:(NSString *)key objtext:(NSString *)text;
@end
