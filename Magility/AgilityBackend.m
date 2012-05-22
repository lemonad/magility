//
//  AgilityBackend.m
//  Magility
//
//  Created by Jonas Nockert on 5/14/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import "MagilityViewController.h"
#import "MagilitySettings.h"
#import "AgilityBackend.h"
#import "SMWebRequest.h"
#import "smxmldocument/SMXMLDocument.h"

@interface AgilityBackend()
@property (nonatomic) NSString *apiServer;
@property (nonatomic) NSString *apiUsername;
@property (nonatomic) NSString *apiPassword;
@property (nonatomic) NSString *apiToken;
@property (nonatomic) NSMutableDictionary *apiPresets;
@property (nonatomic) NSString *presetSelected;
@end

@implementation AgilityBackend
@synthesize apiServer = _apiServer;
@synthesize apiUsername = _apiUsername;
@synthesize apiPassword = _apiPassword;
@synthesize apiToken = _apiToken;
@synthesize apiPresets = _apiPresets;
@synthesize mainView = _mainView;
@synthesize presetSelected = _presetSelected;

- (NSMutableDictionary *)apiPresets {
    if (_apiPresets == nil) {
        _apiPresets = [[NSMutableDictionary alloc] init];
    }
    return _apiPresets;
}

- (id)init {
    self = [super init];
    if (self) {
        // Register notification receiver for api calls.
        // This beause it takes three iPath API calls
        // to connect to a preset (login, get presets and
        // connect preset). This way, anywhere you are in
        // the API call stack, it should take you through
        // the steps in the right order.
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(apiHandler:)
                   name:@"iPathAPI"
                 object:nil];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(settingsChangedHandler:)
         name:@"SettingsChanged"
         object:nil];
    }
    return self;
}

- (void)dealloc {
    // Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)apiHandler:(NSNotification *)notification {
    if (!self.apiToken) {
        NSLog(@"logging in...");

        // Since we're not logged in, we can't trust the current list of presets
        [self setApiPresets:nil];

        return [self login];
    } else if ([self.apiPresets count] <= 0) {
        NSLog(@"getting presets...");
        return [self getPresets];
    } else if (self.presetSelected) {
        NSLog(@"connecting preset...");
        NSString *preset = self.presetSelected;
        self.presetSelected = nil;
        return [self connectPreset:preset];
    }
}

- (void)settingsChangedHandler:(NSNotification *)notification {
    NSLog(@"Settings Changed [2]");

    NSString *hostname = [MagilitySettings
                          getSettingSetDefault:@"hostname"
                          defaultstr:@""];
    NSString *username = [MagilitySettings
                          getSettingSetDefault:@"username"
                                    defaultstr:@""];
    NSString *password = [MagilitySettings
                          getSettingSetDefault:@"password"
                          defaultstr:@""];

    if (![hostname isEqualToString:self.apiServer]) {
        self.apiServer = hostname;
        [self setApiToken:nil];
    }
    if (![username isEqualToString:self.apiUsername]) {
        self.apiUsername = username;
        [self setApiToken:nil];
    }
    if (![password isEqualToString:self.apiPassword]) {
        self.apiPassword = password;
        [self setApiToken:nil];
    }
}

- (void)apiLogin {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"iPathAPI"
     object:nil
     userInfo:nil];
}

- (void)apiGetPresets {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"iPathAPI"
     object:nil
     userInfo:nil];
}

- (void)apiConnectPreset:(NSString *)preset_name {
    self.presetSelected = preset_name;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"iPathAPI"
     object:nil
     userInfo:nil];
}

/*
 Login and get a new authentication token for API access.

 Example of a successful response:
   <api_response>
     <version>1</version>
     <timestamp>2011-02-04 15:26:20</timestamp>
     <success>1</success>
     <token>5cf494a71c29e9465a57a81e0a2d602c</token>
   </api_response>
*/
- (void)login {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/?v=1&method=login&username=%@&password=%@",
                                       self.apiServer, self.apiUsername, self.apiPassword]];
    SMWebRequest *request = [SMWebRequest requestWithURL:url];
    [request addTarget:self action:@selector(loginComplete:)
      forRequestEvents:SMWebRequestEventComplete];
    [self.mainView.statusLabel setText:@"Logging in..."];
    [request start];
}

- (void)loginComplete:(NSData *)data {
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];

    if (error) {
        NSLog(@"Error while parsing the document: %@", error);
        [self.mainView.statusLabel setText:@"Fel: Kunde inte logga in (felaktig XML)"];
        return;
    }

    BOOL success = [[document.root valueWithPath:@"success"] boolValue];
    NSLog(@"Success: %@", (success ? @"YES" : @"NO"));
    if (!success) {
        SMXMLElement *errors = [document.root childNamed:@"errors"];
        for (SMXMLElement *error in [errors childrenNamed:@"error"]) {
            NSString *msg = [error valueWithPath:@"msg"];
            NSString *code = [error valueWithPath:@"code"];
            NSLog(@"API returned error '%@' (code %@)", msg, code);
        }
        [self.mainView.statusLabel setText:@"Fel: Kunde inte logga in"];
        return;
    }

    NSString *token = [document.root valueWithPath:@"token"];
    NSLog(@"Token: %@", token);
    self.apiToken = token;

    [self.mainView.statusLabel setText:@"Logged in"];

    NSLog(@"sending notification");
    // Send notification of success
    [[NSNotificationCenter defaultCenter]
            postNotificationName:@"iPathAPI"
                          object:nil
                        userInfo:nil];
}

/*
 Get list of connection presets.

 Example of a successful response:
   <api_response>
     <version>1</version>
     <timestamp>2012-01-19 12:52:28</timestamp>
     <success>1</success>
     <page>1</page>
     <results_per_page>1000</results_per_page>
     <count_preset>5</count_presets>
     <total_presets>5</total_presets>
     <connection_presets>
       <connection_preset item="1">
         <cp_id>5</cp_id>
         <cp_name>Jonas kickin' it oldschool</cp_name>
         <cp_description></cp_description>
         <cp_pairs>6</cp_pairs>
         <problem_cp_pairs/>
         <count_active_cp>5</count_active_cp>
         <connected_rx_count>6</connected_rx_count>
         <view_button>disabled</view_button>
         <shared_button>hidden</shared_button>
         <exclusive_button>hidden</exclusive_button>
         <user_id>1</user_id>
       </connection_preset>
       <connection_preset item="2">
         ...
       </connection_preset>
     </connection_presets>
   </api_response>
*/
- (void)getPresets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/?v=1&method=get_presets&token=%@",
                                       self.apiServer, self.apiToken]];
    SMWebRequest *request = [SMWebRequest requestWithURL:url];
    [request addTarget:self
                action:@selector(getPresetsComplete:)
      forRequestEvents:SMWebRequestEventComplete];
    [self.mainView.statusLabel setText:@"Fetching presets..."];
    [request start];
}

- (void)getPresetsComplete:(NSData *)data {
    // The iPath API returns invalid xml (!) so we need to fix
    // that before parsing
    [self.mainView.statusLabel setText:@"Correcting XML"];

    // 1. Convert nsdata to string
    NSString *datastr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    // 2. Correct xml
    NSString *xmlstr = [datastr
                        stringByReplacingOccurrencesOfString:@"<count_preset>"
                                                  withString:@"<count_presets>"];
    // 3. Convert back to nsdata
    NSData *correcteddata = [xmlstr dataUsingEncoding:NSUTF8StringEncoding];

    // Parse corrected xml
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:correcteddata
                                                        error:&error];
    if (error) {
        NSLog(@"Error while parsing the document: %@", error);
        [self.mainView.statusLabel setText:@"Fel: Kunde inte hämta presets (felaktig XML)"];
        return;
    }

    // Check if iPath API call succeeded
    BOOL success = [[document.root valueWithPath:@"success"] boolValue];
    NSLog(@"Success: %@", (success ? @"YES" : @"NO"));
    if (!success) {
        SMXMLElement *errors = [document.root childNamed:@"errors"];
        for (SMXMLElement *error in [errors childrenNamed:@"error"]) {
            NSString *msg = [error valueWithPath:@"msg"];
            NSString *code = [error valueWithPath:@"code"];
            NSLog(@"API returned error '%@' (code %@)", msg, code);
        }
        [self.mainView.statusLabel setText:@"Fel: Kunde inte hämta presets"];
        [self setApiToken:nil];
        return;
    }

    // Get all Agility presets
    SMXMLElement *presets = [document.root childNamed:@"connection_presets"];
    for (SMXMLElement *preset in [presets childrenNamed:@"connection_preset"]) {
        NSString *cp_id = [preset valueWithPath:@"cp_id"];
        NSString *cp_name = [preset valueWithPath:@"cp_name"];
        NSLog(@"Preset id=%@: '%@'", cp_id, cp_name);
        [self.apiPresets setObject:cp_id forKey:cp_name];
    }
    [self.mainView.statusLabel setText:@"Ready"];

    // Send notification of success
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"iPathAPI"
     object:nil
     userInfo:nil];
}

/*
 Connect preset

 Example of a successful response:
    <api_response>
      <version>1</version>
      <timestamp>2011-02-04 15:24:15</timestamp>
      <success>1</success>
    </api_response>
*/
- (void)connectPreset:(NSString *)presetName {
    // Convert preset name to preset id
    NSString *presetID = [self.apiPresets objectForKey:presetName];
    if (presetID == nil) {
        NSString *errstr = [NSString
                            stringWithFormat:@"Preset '%@' not a recognized Agility preset", presetName];
        [self.mainView.statusLabel setText:errstr];
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/?v=1&method=connect_preset&token=%@&id=%@&view_only=1&force=1",
                                       self.apiServer, self.apiToken, presetID]];
    SMWebRequest *request = [SMWebRequest requestWithURL:url];
    [request addTarget:self
                action:@selector(connectPresetComplete:)
      forRequestEvents:SMWebRequestEventComplete];
    [self.mainView.statusLabel setText:@"Connecting preset..."];
    [request start];
}

- (void)connectPresetComplete:(NSData *)data {
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    if (error) {
        NSLog(@"Error while parsing the document: %@", error);
        [self.mainView.statusLabel setText:@"Fel: Kunde inte aktivera preset (felaktig XML)"];
        return;
    }

    BOOL success = [[document.root valueWithPath:@"success"] boolValue];
    NSLog(@"Success: %@", (success ? @"YES" : @"NO"));
    if (!success) {
        SMXMLElement *errors = [document.root childNamed:@"errors"];
        for (SMXMLElement *error in [errors childrenNamed:@"error"]) {
            NSString *msg = [error valueWithPath:@"msg"];
            NSString *code = [error valueWithPath:@"code"];
            NSLog(@"API returned error '%@' (code %@)", msg, code);
        }
        [self.mainView.statusLabel setText:@"Fel: Kunde inte aktivera preset"];
        [self setApiToken:nil];
        return;
    }
    [self.mainView.statusLabel setText:@"Ready"];

    // Send notification of success
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"iPathAPI"
     object:nil
     userInfo:nil];
}

@end
