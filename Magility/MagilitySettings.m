//
//  MagilitySettings.m
//  Magility
//
//  Created by Jonas Nockert on 5/21/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import "MagilitySettings.h"

@implementation MagilitySettings

+ (NSString *)getSettingSetDefault:(NSString *)key
                        defaultstr:(NSString *)defaultstr {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSString *text = [userdefaults stringForKey:key];
    if (text == nil) {
        text = defaultstr;
        [self setSetting:key objtext:text];
    }
    return text;
}

+ (void)setSetting:(NSString *)key objtext:(NSString *)text {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:text forKey:key];
    [userdefaults synchronize];
}

@end
