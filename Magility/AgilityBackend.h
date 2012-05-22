//
//  AgilityBackend.h
//  Magility
//
//  Created by Jonas Nockert on 5/14/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgilityBackend : NSObject
- (void)apiLogin;
- (void)apiGetPresets;
- (void)apiConnectPreset:(NSString *)preset_name;
@property (retain) MagilityViewController *mainView;
@end
