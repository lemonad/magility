//
//  MagilityViewController.m
//  Magility
//
//  Created by Jonas Nockert on 5/22/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MagilityViewController.h"
#import "MagilitySettings.h"
#import "AgilityBackend.h"
#import "SMWebRequest.h"
#import "smxmldocument/SMXMLDocument.h"

@interface MagilityViewController ()
@property (nonatomic) BOOL currentChosenPreset;
@property (nonatomic) AgilityBackend *agilityBackend;
@end

@implementation MagilityViewController
@synthesize buttonOne = _buttonOne;
@synthesize buttonTwo = _buttonTwo;
@synthesize buttonThree = _buttonThree;
@synthesize buttonFour = _buttonFour;
@synthesize currentChosenPreset = _currentChosenPreset;
@synthesize agilityBackend = _agilityBackend;
@synthesize statusLabel = _statusLabel;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;

- (AgilityBackend *)agilityBackend {
    if (!_agilityBackend) _agilityBackend = [[AgilityBackend alloc] init];
    return _agilityBackend;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Register notification receiver for settings changed
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(settingsChangedHandler:)
     name:@"SettingsChanged"
     object:nil];

    [self setupCustomButton:self.buttonOne];
    [self setupCustomButton:self.buttonTwo];
    [self setupCustomButton:self.buttonThree];
    [self setupCustomButton:self.buttonFour];

    self.agilityBackend.mainView = self;

    NSLog(@"Sending settings changed notification");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SettingsChanged"
     object:nil];

    [self.agilityBackend apiLogin];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setButtonOne:nil];
    [self setButtonTwo:nil];
    [self setButtonThree:nil];
    [self setButtonFour:nil];
    [self setStatusLabel:nil];
    [self setSubtitleLabel:nil];
    [self setTitleLabel:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)handleButtonSettings:(UIButton *)button
                    titleStr:(NSString *)titleStr
                   presetStr:(NSString *)presetStr
                  defaultStr:(NSString *)defaultStr {
    NSString *text = [MagilitySettings
                      getSettingSetDefault:titleStr
                      defaultstr:defaultStr];
    NSString *preset = [MagilitySettings
                        getSettingSetDefault:presetStr
                        defaultstr:@""];
    [button setTitle:text forState:UIControlStateNormal];
    if ([preset length] <= 0) {
        button.enabled = NO;
    } else {
        button.enabled = YES;
    }
}

- (void)settingsChangedHandler:(NSNotification *)notification {
    NSLog(@"Settings Changed");
    [self handleButtonSettings:self.buttonOne
                      titleStr:@"button1title"
                     presetStr:@"button1preset"
                    defaultStr:@"1"];
    [self handleButtonSettings:self.buttonTwo
                      titleStr:@"button2title"
                     presetStr:@"button2preset"
                    defaultStr:@"2"];
    [self handleButtonSettings:self.buttonThree
                      titleStr:@"button3title"
                     presetStr:@"button3preset"
                    defaultStr:@"3"];
    [self handleButtonSettings:self.buttonFour
                      titleStr:@"button4title"
                     presetStr:@"button4preset"
                    defaultStr:@"4"];

    NSString *text = [MagilitySettings
                      getSettingSetDefault:@"title"
                                defaultstr:@"Hello"];
    [self.titleLabel setText:text];

    text = [MagilitySettings
            getSettingSetDefault:@"subtitle"
                      defaultstr:@"World"];
    [self.subtitleLabel setText:text];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    NSString *preset1 = [MagilitySettings
                         getSettingSetDefault:@"button1preset"
                         defaultstr:@""];
    NSString *preset2 = [MagilitySettings
                         getSettingSetDefault:@"button2preset"
                         defaultstr:@""];
    NSString *preset3 = [MagilitySettings
                         getSettingSetDefault:@"button3preset"
                         defaultstr:@""];
    NSString *preset4 = [MagilitySettings
                         getSettingSetDefault:@"button4preset"
                         defaultstr:@""];

    if (sender.tag == 1 && [preset1 length] > 0) {
        [self.agilityBackend apiConnectPreset:preset1];
    } else if (sender.tag == 2 && [preset2 length] > 0) {
        [self.agilityBackend apiConnectPreset:preset2];
    } else if (sender.tag == 3 && [preset3 length] > 0) {
        [self.agilityBackend apiConnectPreset:preset3];
    } else if (sender.tag == 4 && [preset4 length] > 0) {
        [self.agilityBackend apiConnectPreset:preset4];
    } else {
        return;
    }

    sender.selected = YES;
    sender.enabled = NO;

    if (sender.tag != 1 && [preset1 length] > 0) {
        self.buttonOne.enabled = YES;
        self.buttonOne.selected = NO;
    }
    if (sender.tag != 2 && [preset2 length] > 0) {
        self.buttonTwo.enabled = YES;
        self.buttonTwo.selected = NO;
    }
    if (sender.tag != 3 && [preset3 length] > 0) {
        self.buttonThree.enabled = YES;
        self.buttonThree.selected = NO;
    }
    if (sender.tag != 4 && [preset4 length] > 0) {
        self.buttonFour.enabled = YES;
        self.buttonFour.selected = NO;
    }
}

- (void)setupCustomButton:(UIButton *)button {
    // self.buttonOne.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = UITextAlignmentCenter;

    CALayer *layer = [button layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10.0f]; //note that when radius is 0, the border is a rectangle
    [layer setBorderWidth:1.0f];
    [layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

    // Since it's not possible to set background images for all states
    // through interface builder, we'll set all of them programatically
    UIImage *buttonImage = [UIImage imageNamed:@"button-background.png"];
    UIImage *buttonDisabledImage = [UIImage imageNamed:@"button-background-disabled.png"];
    UIImage *buttonShadedImage = [UIImage imageNamed:@"button-background-shaded.png"];

    [button setBackgroundImage:buttonImage
                      forState:UIControlStateHighlighted];

    [button setBackgroundImage:buttonShadedImage
                      forState:UIControlStateSelected];
    [button setBackgroundImage:buttonShadedImage
                      forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [button setBackgroundImage:buttonShadedImage
                      forState:(UIControlStateDisabled | UIControlStateSelected)];
    [button setBackgroundImage:buttonShadedImage
                      forState:(UIControlStateDisabled | UIControlStateSelected | UIControlStateHighlighted)];

    [button setBackgroundImage:buttonDisabledImage
                      forState:UIControlStateDisabled];
}

@end
