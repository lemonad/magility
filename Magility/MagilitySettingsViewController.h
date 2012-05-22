//
//  MagilitySettingsViewController.h
//  Magility
//
//  Created by Jonas Nockert on 5/18/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagilitySettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *subtitleText;
@property (weak, nonatomic) IBOutlet UITextField *agilityHostName;
@property (weak, nonatomic) IBOutlet UITextField *agilityUsername;
@property (weak, nonatomic) IBOutlet UITextField *agilityPassword;
@property (weak, nonatomic) IBOutlet UITextField *button1Title;
@property (weak, nonatomic) IBOutlet UITextField *button2Title;
@property (weak, nonatomic) IBOutlet UITextField *button3Title;
@property (weak, nonatomic) IBOutlet UITextField *button4Title;
@property (weak, nonatomic) IBOutlet UITextField *button1Preset;
@property (weak, nonatomic) IBOutlet UITextField *button2Preset;
@property (weak, nonatomic) IBOutlet UITextField *button3Preset;
@property (weak, nonatomic) IBOutlet UITextField *button4Preset;
@end
