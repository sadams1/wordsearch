//
//  SettingsViewController.m
//  words
//
//  Created by Marius Rott on 9/13/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundUtils.h"
#import "MKLocalNotificationsScheduler.h"
#import "Flurry.h"
#import "configuration.h"
#import "ImageUtils.h"
#import "MGIAPHelper.h"

@interface SettingsViewController ()

- (void)refreshView;

@end

@implementation SettingsViewController

- (id)init
{
    NSString *xib = @"SettingsViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"SettingsViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [self.labelTitle release];
    [self.labelButtonNotifications release];
    [self.labelButtonSounds release];
    [self.labelButtonEmail release];
    [self.buttonEmail release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshView];
    
    
    self.labelTitle.text = NSLocalizedString(@"settings", nil);
    self.labelButtonNotifications.text = NSLocalizedString(@"notifications", nil);
    self.labelButtonSounds.text = NSLocalizedString(@"sounds", nil);
    self.labelButtonRestore.text = NSLocalizedString(@"restorePurchases", nil);
    self.labelButtonEmail.text = NSLocalizedString(@"email", nil);
    
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Marker Felt" size:50];
        self.labelButtonNotifications.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
        self.labelButtonNotificationsOnOff.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
        self.labelButtonSounds.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
        self.labelButtonEmail.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
        self.labelButtonRestore.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
        self.labelButtonSoundsOnOff.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Marker Felt" size:25];
        self.labelButtonNotifications.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        self.labelButtonNotificationsOnOff.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        self.labelButtonSounds.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        self.labelButtonEmail.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        self.labelButtonRestore.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        self.labelButtonSoundsOnOff.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
    }
    
    self.view.backgroundColor = THEME_COLOR_GRAY;
    self.labelTitle.textColor = THEME_COLOR_BLUE;
    
    UIImage *imageBackButton = [ImageUtils imageWithColor:THEME_COLOR_GRAY_BACKGROUND
                                                 rectSize:self.buttonEmail.frame.size];
    
    
    self.labelButtonNotifications.textColor = THEME_COLOR_GRAY_TEXT;
    
    self.labelButtonSounds.textColor = THEME_COLOR_GRAY_TEXT;
    
    self.labelButtonEmail.textColor = THEME_COLOR_GRAY_TEXT;
    
    self.labelButtonRestore.textColor = THEME_COLOR_GRAY_TEXT;
    
    [self.buttonNotifications setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonNotifications setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonNotifications setBackgroundImage:imageBackButton
                                forState:UIControlStateHighlighted];
    
    [self.buttonSounds setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonSounds setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonSounds setBackgroundImage:imageBackButton
                                forState:UIControlStateHighlighted];
    
    [self.buttonEmail setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonEmail setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonEmail setBackgroundImage:imageBackButton
                                   forState:UIControlStateHighlighted];

    [self.buttonRestore setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonRestore setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonRestore setBackgroundImage:imageBackButton
                                forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{
    if ([SoundUtils sharedInstance].soundOn)
    {
        self.labelButtonSoundsOnOff.text = NSLocalizedString(@"on", nil);
        self.labelButtonSoundsOnOff.textColor = THEME_COLOR_BLUE;
    }
    else
    {
        self.labelButtonSoundsOnOff.text = NSLocalizedString(@"off", nil);
        self.labelButtonSoundsOnOff.textColor = THEME_COLOR_GRAY_TEXT;
    }
    
    if ([MKLocalNotificationsScheduler sharedInstance].notificationsOn)
    {
        self.labelButtonNotificationsOnOff.text = NSLocalizedString(@"on", nil);
        self.labelButtonNotificationsOnOff.textColor = THEME_COLOR_BLUE;
    }
    else
    {
        self.labelButtonNotificationsOnOff.text = NSLocalizedString(@"off", nil);
        self.labelButtonNotificationsOnOff.textColor = THEME_COLOR_GRAY_TEXT;
    }
    
    NSLog(@"%d - sound ", [SoundUtils sharedInstance].soundOn);
    NSLog(@"%d - notifications", [MKLocalNotificationsScheduler sharedInstance].notificationsOn);
}

- (void)doButtonClose:(id)sender
{
    [Flurry logEvent:@"SETTINGS: doButtonBack"];
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)doButtonCredits:(id)sender
{
    
}

- (void)doButtonEmail:(id)sender
{
    [Flurry logEvent:@"SETTINGS: doButtonEmail"];
    
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later.
	// So, we must verify the existence of the above class and provide a workaround for devices running
	// earlier versions of the iPhone OS.
	// We display an email composition interface if MFMailComposeViewController exists and the device
	// can send emails.	Display feedback message, otherwise.
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil) {
        //[self displayMailComposerSheet];
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			[self displayMailComposerSheet];
		}
		else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"This device is not configured to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [self.view addSubview:alert];
            [alert show];
            [alert release];
		}
	}
	else	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"This device is not configured to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.view addSubview:alert];
        [alert show];
        [alert release];
	}
}

- (void)doButtonRestore:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    [[MGIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)doButtonNotifications:(id)sender
{
    [MKLocalNotificationsScheduler sharedInstance].notificationsOn = ![MKLocalNotificationsScheduler sharedInstance].notificationsOn;
    
    [Flurry logEvent:@"SETTINGS: doButtonNotifications"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"SoundOn", [NSNumber numberWithBool:[MKLocalNotificationsScheduler sharedInstance].notificationsOn], nil]];
    
    [self refreshView];
}

- (void)doButtonSounds:(id)sender
{
    [SoundUtils sharedInstance].soundOn = ![SoundUtils sharedInstance].soundOn;
    
    [Flurry logEvent:@"SETTINGS: doButtonSounds"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"SoundOn", [NSNumber numberWithBool:[SoundUtils sharedInstance].soundOn], nil]];
    
    [self refreshView];
}


#pragma mark Compose Mail/SMS

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayMailComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"appwizeapps@gmail.com"];
	
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *model = [currentDevice model];
    NSString *systemVersion = [currentDevice systemVersion];
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *emailBody = [NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\nApp Name: %@ \nModel: %@ \nSystem Version: %@ \nLanguage: %@ \nCountry: %@ \nApp Version: %@", appName, model, systemVersion, language, country, appVersion];
    
	[picker setToRecipients:toRecipients];
    [picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker
                       animated:YES
                     completion:^{
                         
                     }];
	[picker release];
}

#pragma mark -
#pragma mark Dismiss Mail/SMS view controller

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
            UIAlertView* alert;
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"There was an error sending your message. Please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
