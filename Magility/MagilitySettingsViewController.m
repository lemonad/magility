//
//  MagilitySettingsViewController.m
//  Magility
//
//  Created by Jonas Nockert on 5/18/12.
//  Copyright (c) 2012 Karnkraftsakerhet och Utbildning AB. All rights reserved.
//

#import "MagilitySettingsViewController.h"
#import "MagilitySettings.h"

@interface MagilitySettingsViewController()
@property (nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@end

@implementation MagilitySettingsViewController
@synthesize activeField = _activeField;
@synthesize scrollView = _scrollView;
@synthesize titleText = _titleText;
@synthesize subtitleText = _subtitleText;
@synthesize agilityHostName = _agilityHostName;
@synthesize agilityUsername = _agilityUsername;
@synthesize agilityPassword = _agilityPassword;
@synthesize button1Title = _button1Title;
@synthesize button2Title = _button2Title;
@synthesize button3Title = _button3Title;
@synthesize button4Title = _button4Title;
@synthesize button1Preset = _button1Preset;
@synthesize button2Preset = _button2Preset;
@synthesize button3Preset = _button3Preset;
@synthesize button4Preset = _button4Preset;
@synthesize singleTap = _singleTap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.titleText.text = [MagilitySettings
                           getSettingSetDefault:@"title"
                           defaultstr:@"Hello"];
    self.subtitleText.text = [MagilitySettings
                              getSettingSetDefault:@"subtitle"
                              defaultstr:@"World"];
    self.agilityHostName.text = [MagilitySettings
                                 getSettingSetDefault:@"hostname"
                                 defaultstr:@""];
    self.agilityUsername.text = [MagilitySettings
                                 getSettingSetDefault:@"username"
                                 defaultstr:@""];
    self.agilityPassword.text = [MagilitySettings
                                 getSettingSetDefault:@"password"
                                 defaultstr:@""];
    self.button1Title.text = [MagilitySettings
                              getSettingSetDefault:@"button1title"
                              defaultstr:@"1"];
    self.button2Title.text = [MagilitySettings
                              getSettingSetDefault:@"button2title"
                              defaultstr:@"2"];
    self.button3Title.text = [MagilitySettings
                              getSettingSetDefault:@"button3title"
                              defaultstr:@"3"];
    self.button4Title.text = [MagilitySettings
                              getSettingSetDefault:@"button4title"
                              defaultstr:@"4"];
    self.button1Preset.text = [MagilitySettings
                               getSettingSetDefault:@"button1preset"
                               defaultstr:@""];
    self.button2Preset.text = [MagilitySettings
                               getSettingSetDefault:@"button2preset"
                               defaultstr:@""];
    self.button3Preset.text = [MagilitySettings
                               getSettingSetDefault:@"button3preset"
                               defaultstr:@""];
    self.button4Preset.text = [MagilitySettings
                               getSettingSetDefault:@"button4preset"
                               defaultstr:@""];

    [self registerForKeyboardNotifications];

    /* Dismiss keyboard on scrollview touch */
    self.singleTap = [[UITapGestureRecognizer alloc]
                      initWithTarget:self
                              action:@selector(singleTapGestureCaptured:)];
    self.singleTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:self.singleTap];
}

/* Dismiss keyboard on scrollview touch */
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    // Perhaps we need to check touchPoint for the correct kind of touch?
    // CGPoint touchPoint = [gesture locationInView:self.scrollView];
    [self.view endEditing:YES];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrollView removeGestureRecognizer:self.singleTap];

    [self setTitleText:nil];
    [self setSubtitleText:nil];
    [self setAgilityHostName:nil];
    [self setAgilityUsername:nil];
    [self setAgilityPassword:nil];
    [self setButton1Title:nil];
    [self setButton2Title:nil];
    [self setButton3Title:nil];
    [self setButton4Title:nil];
    [self setButton1Preset:nil];
    [self setButton2Preset:nil];
    [self setButton3Preset:nil];
    [self setButton4Preset:nil];
    [self setScrollView:nil];

    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(keyboardWasShown:)
            name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(keyboardWillBeHidden:)
            name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]
                     CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0,
                                                  0.0,
                                                  kbSize.height,
                                                  0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

    CGPoint origin = self.activeField.frame.origin;
    origin.y += self.activeField.frame.size.height;
    origin.y -= self.scrollView.contentOffset.y;

    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0,
                                          self.activeField.frame.origin.y +
                                          self.activeField.frame.size.height -
                                          aRect.size.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender {
    self.activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender {
    self.activeField = nil;
    [sender resignFirstResponder];
}

- (IBAction)titleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"title" objtext:sender.text];
}

- (IBAction)subtitleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"subtitle" objtext:sender.text];
}

- (IBAction)serverEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"hostname" objtext:sender.text];
}

- (IBAction)usernameEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"username" objtext:sender.text];
}

- (IBAction)passwordEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"password" objtext:sender.text];
}

- (IBAction)button1TitleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button1title" objtext:sender.text];
}

- (IBAction)button2TitleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button2title" objtext:sender.text];
}

- (IBAction)button3TitleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button3title" objtext:sender.text];
}

- (IBAction)button4TitleEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button4title" objtext:sender.text];
}

- (IBAction)button1PresetEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button1preset" objtext:sender.text];
}

- (IBAction)button2PresetEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button2preset" objtext:sender.text];
}

- (IBAction)button3PresetEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button3preset" objtext:sender.text];
}

- (IBAction)button4PresetEdited:(UITextField *)sender {
    [MagilitySettings setSetting:@"button4preset" objtext:sender.text];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Sending settings changed notification");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SettingsChanged"
                   object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
