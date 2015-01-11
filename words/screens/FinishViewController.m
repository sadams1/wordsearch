//
//  FinishViewController.m
//  words
//
//  Created by Marius Rott on 9/12/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "FinishViewController.h"
#import "GameSession.h"
#import "QuestPopupManager.h"
#import "SettingsViewController.h"
#import "MGLinkAdsManager.h"
#import "MGShare.h"
#import "CoinsManager.h"
#import "SoundUtils.h"
#import "configuration.h"
#import "Game.h"
#import "ImageUtils.h"
#import "Flurry.h"
#import "MGAdsManager.h"
#import "Appirater.h"
#import <Chartboost/Chartboost.h>
#import "GADBannerView.h"

@interface FinishViewController ()
{
    id<GameViewControllerDelegate> _delegate;
    GameSession *_gameSession;  //  retained in parent viewcontroller
    QuestPopupManager *_questPopupManager;
    BOOL _isPaused;
    BOOL _showShareReward;
}

@property (nonatomic, retain) GADBannerView *bannerView;

- (void)refreshView;

@end

@implementation FinishViewController

- (id)initWithDelegate:(id<GameViewControllerDelegate>)delegate gameSession:(GameSession *)gameSession isPaused:(BOOL)isPaused
{
    NSString *xib = @"FinishViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"FinishViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        _delegate = delegate;
        _gameSession = gameSession;
        _isPaused = isPaused;
        
        //  check if show share reward
        #define ARC4RANDOM_MAX      0x100000000
        double val = ((double)arc4random() / ARC4RANDOM_MAX);
        if (val > MG_SHARE_SHOW_SHARE_REWARD_PROBABILITY)
            _showShareReward = false;
        else if (!_isPaused)
            _showShareReward = true;
        
        //Getting quests completed
        int questsCompleted = [_gameSession getQuestsCompleted].count;
        NSLog(@"Quests completed: %d", questsCompleted);
        
        //Turning quest stuff off for now
        //  show popups
        //if ([_gameSession getQuestsCompleted].count)
        //{
        //    _questPopupManager = [[QuestPopupManager alloc] initWithFinishedQuests:[_gameSession getQuestsCompleted]
        //                                                                   inView:self.view];
        //}
        //[_questPopupManager showPopups];
    }
    return self;
}

- (void)dealloc
{
    [self.labelTitle release];
    [self.labelPoints release];
    if (_questPopupManager)
        [_questPopupManager release];
    [self.buttonMoreGames release];
    [self.buttonNext release];
    [self.buttonRestart release];
    [self.buttonPackage release];
    [self.buttonSettings release];
    [self.buttonFacebook release];
    [self.buttonTwitter release];
    [self.labelButtonNext release];
    [self.labelButtonRestart release];
    [self.labelButtonSettings release];
    [self.labelButtonPackages release];
    [self.labelButtonMoreGames release];
    [self.imageViewMoreGames release];
    [self.viewStars release];
    [self.labelShare release];
    [self.labelFacebookCoins release];
    [self.labelTwitterCoins release];
    [self.viewShareSeparator release];
    [self.imageViewFacebookCoins release];
    [self.imageViewTwitterCoins release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelButtonNext.text = NSLocalizedString(@"nextGame", nil);
    self.labelButtonRestart.text = NSLocalizedString(@"restart", nil);
    self.labelButtonSettings.text = NSLocalizedString(@"settings", nil);
    self.labelButtonPackages.text = NSLocalizedString(@"backToPackage", nil);
    self.labelButtonMoreGames.text = NSLocalizedString(@"moreGames", nil);
    
    if (_isPaused)
    {
        self.labelTitle.text = NSLocalizedString(@"gamePaused", nil);
        self.labelButtonNext.text = NSLocalizedString(@"resumeGame", nil);
        self.labelPoints.hidden = YES;
        self.labelTime.hidden = YES;
        self.labelShare.hidden = YES;
        self.viewShareSeparator.hidden = YES;
        self.buttonFacebook.hidden = YES;
        self.buttonTwitter.hidden = YES;
        self.labelFacebookCoins.hidden = YES;
        self.labelTwitterCoins.hidden = YES;
        self.imageViewFacebookCoins.hidden = YES;
        self.imageViewTwitterCoins.hidden = YES;
    }
    else
    {
        self.labelTitle.text = NSLocalizedString(@"congratulations", nil);
        self.labelButtonNext.text = NSLocalizedString(@"nextGame", nil);
        
        int show = false;
#ifdef FREE_VERSION
        show = [[MGAdsManager sharedInstance] displayAdInViewController:self];
#endif
//        if (!show)
//        {
//            [Appirater userDidSignificantEvent:YES];
//        }
        
        if (_questPopupManager)
        {
            [_questPopupManager showPopups];
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.labelPoints.font = [UIFont fontWithName:@"Segoe UI" size:26];
            self.labelTime.font = [UIFont fontWithName:@"Segoe UI" size:26];
            self.labelShare.font = [UIFont fontWithName:@"Segoe UI" size:26];
            self.labelFacebookCoins.font = [UIFont fontWithName:@"Nexa Bold" size:22];
            self.labelTwitterCoins.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        }
        else
        {
            self.labelPoints.font = [UIFont fontWithName:@"Segoe UI" size:16];
            self.labelTime.font = [UIFont fontWithName:@"Segoe UI" size:16];
            self.labelShare.font = [UIFont fontWithName:@"Segoe UI" size:16];
            self.labelFacebookCoins.font = [UIFont fontWithName:@"Nexa Bold" size:12];
            self.labelTwitterCoins.font = [UIFont fontWithName:@"Nexa Bold" size:12];
        }
        
        
        self.labelPoints.textColor = THEME_COLOR_GRAY_TEXT;
        
        self.labelPoints.text = [NSString stringWithFormat:NSLocalizedString(@"%d points", nil), [_gameSession getSessionPoints]];
        if ([_gameSession isHighscore])
        {
            self.labelTime.text = [NSString stringWithFormat:NSLocalizedString(@"New Record: %@", nil), [_gameSession getTimeString:[_gameSession getSessionTimeInterval]]];
            self.labelTime.textColor = THEME_COLOR_RED;
        }
        else
        {
            self.labelTime.text = [NSString stringWithFormat:NSLocalizedString(@"Time: %@", nil), [_gameSession getTimeString:[_gameSession getSessionTimeInterval]]];
            self.labelTime.textColor = THEME_COLOR_GRAY_TEXT;
        }
        
        NSNumber *sum = [_gameSession.game.sessions valueForKeyPath:@"@sum.points"];
        if (sum.intValue >= GAME_TOTAL_POINTS)
        {
            sum = [NSNumber numberWithInt:GAME_TOTAL_POINTS];
        }
        UIView *stars = [ImageUtils getStarImageViewForPercentage:sum.floatValue / (float)GAME_TOTAL_POINTS];
        [self.view addSubview:stars];
        stars.center = self.viewStars.center;
        
        self.labelShare.textColor = THEME_COLOR_GRAY_TEXT;
        
        self.labelFacebookCoins.textColor = THEME_COLOR_BLUE;
        self.labelFacebookCoins.text = [NSString stringWithFormat:@"%d", COINS_REWARD_SHARE];
        
        self.labelTwitterCoins.textColor = THEME_COLOR_BLUE;
        self.labelTwitterCoins.text = [NSString stringWithFormat:@"%d", COINS_REWARD_SHARE];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Nexa Bold" size:50];
        self.labelGameName.font = [UIFont fontWithName:@"Nexa Bold" size:30];
        self.labelButtonNext.font = [UIFont fontWithName:@"Segoe UI" size:30];
        self.labelButtonRestart.font = [UIFont fontWithName:@"Segoe UI" size:30];
        self.labelButtonSettings.font = [UIFont fontWithName:@"Segoe UI" size:30];
        self.labelButtonPackages.font = [UIFont fontWithName:@"Segoe UI" size:30];
        self.labelButtonMoreGames.font = [UIFont fontWithName:@"Segoe UI" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Nexa Bold" size:22];
        self.labelGameName.font = [UIFont fontWithName:@"Nexa Bold" size:20];
        self.labelButtonNext.font = [UIFont fontWithName:@"Segoe UI" size:15];
        self.labelButtonRestart.font = [UIFont fontWithName:@"Segoe UI" size:15];
        self.labelButtonSettings.font = [UIFont fontWithName:@"Segoe UI" size:15];
        self.labelButtonPackages.font = [UIFont fontWithName:@"Segoe UI" size:15];
        self.labelButtonMoreGames.font = [UIFont fontWithName:@"Segoe UI" size:15];
    }
    
    self.view.backgroundColor = THEME_COLOR_GRAY;
    self.labelTitle.textColor = THEME_COLOR_BLUE;
    
    self.labelGameName.text = NSLocalizedString(_gameSession.game.name, nil);
    
    
    UIImage *imageBackButton = [ImageUtils imageWithColor:THEME_COLOR_GRAY_BACKGROUND
                                                 rectSize:self.buttonNext.frame.size];
    
    
    self.labelButtonNext.textColor = THEME_COLOR_GRAY_TEXT;
    [self.buttonNext setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonNext setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonNext setBackgroundImage:imageBackButton
                               forState:UIControlStateHighlighted];
    
    
    self.labelButtonRestart.textColor = THEME_COLOR_GRAY_TEXT;
    [self.buttonRestart setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonRestart setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonRestart setBackgroundImage:imageBackButton
                               forState:UIControlStateHighlighted];

    
    self.labelButtonSettings.textColor = THEME_COLOR_GRAY_TEXT;
    [self.buttonSettings setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonSettings setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonSettings setBackgroundImage:imageBackButton
                               forState:UIControlStateHighlighted];

    
    self.labelButtonPackages.textColor = THEME_COLOR_GRAY_TEXT;
    [self.buttonPackage setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonPackage setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonPackage setBackgroundImage:imageBackButton
                               forState:UIControlStateHighlighted];

    
    self.labelButtonMoreGames.textColor = THEME_COLOR_GRAY_TEXT;
    [self.buttonMoreGames setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateNormal];
    [self.buttonMoreGames setTitleColor:THEME_COLOR_GRAY_TEXT forState:UIControlStateHighlighted];
    [self.buttonMoreGames setBackgroundImage:imageBackButton
                               forState:UIControlStateHighlighted];

    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    static BOOL loaded = NO;
    if (!loaded)
    {
        [self configureBannerView];
        loaded = YES;
    }
    
//    if (![[MGLinkAdsManager sharedInstance] isAvailable])
//    {
//        self.buttonMoreGames.hidden = YES;
//        self.labelButtonMoreGames.hidden = YES;
//        self.imageViewMoreGames.hidden = YES;
//    }
}

- (void)viewDidLayoutSubviews
{
    
}

- (void)configureBannerView
{
    self.constraintBannerHeight.constant = 0;
    
    if (![[MGAdsManager sharedInstance] isAdsEnabled])
    {
        return;
    }
    GADBannerView *bannerView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
    }
    else
    {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    bannerView.adUnitID = MY_BANNER_UNIT_ID;
    self.constraintBannerHeight.constant = bannerView.adSize.size.height;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView.rootViewController = self;
    [self.viewBannerContainer addSubview:bannerView];
    bannerView.center = CGPointMake(self.viewBannerContainer.frame.size.width / 2, self.viewBannerContainer.frame.size.height / 2);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Initiate a generic request to load it with an ad.
        GADRequest *request = [GADRequest request];
        [bannerView loadRequest:request];
    });
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{
    if (_showShareReward)
    {
        self.labelShare.text = NSLocalizedString(@"shareAndWin", nil);
        self.labelFacebookCoins.hidden = NO;
        self.labelTwitterCoins.hidden = NO;
        self.imageViewFacebookCoins.hidden = NO;
        self.imageViewTwitterCoins.hidden = NO;
    }
    else
    {
        self.labelShare.text = NSLocalizedString(@"share", nil);
        self.labelFacebookCoins.hidden = YES;
        self.labelTwitterCoins.hidden = YES;
        self.imageViewFacebookCoins.hidden = YES;
        self.imageViewTwitterCoins.hidden = YES;
    }
}

- (void)doButtonBack:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonBack"];
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    if (_isPaused)
    {
        if ([_delegate respondsToSelector:@selector(onResume)])
        {
            [self.navigationController popViewControllerAnimated:NO];
            [_delegate onResume];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(onBack)])
        {
            [_delegate onBack];
        }
    }
    
}

- (IBAction)doButtonNext:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    if (_isPaused)
    {
        [Flurry logEvent:@"FINISH: doButtonResume"];
        if ([_delegate respondsToSelector:@selector(onResume)])
        {
            [self.navigationController popViewControllerAnimated:NO];
            [_delegate onResume];
        }
    }
    else
    {
        [Flurry logEvent:@"FINISH: doButtonNext"];
        if ([_delegate respondsToSelector:@selector(onNext)])
        {
            [_delegate onNext];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (void)doButtonMoreGames:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonMoreGames"];
    
//    if ([[MGLinkAdsManager sharedInstance] isAvailable])
//    {
//        [[MGLinkAdsManager sharedInstance] openAdLink];
//    }
    
//    [[UIApplication sharedApplication]
//     openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/id743655007?mt=8"]];

    [Chartboost showMoreApps:CBLocationDefault];
}

- (void)doButtonPackage:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonPackage"];
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    if ([_delegate respondsToSelector:@selector(onBack)])
    {
        [_delegate onBack];
    }
}

- (void)doButtonRestart:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonRestart"];
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    [self.navigationController popViewControllerAnimated:NO];
    if ([_delegate respondsToSelector:@selector(onRestart)])
    {
        [_delegate onRestart];
    }
}

-(void)doButtonSettings:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonSettings"];
    
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    SettingsViewController *settingsViewCont = [[[SettingsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:settingsViewCont animated:NO];
}

- (void)doButtonFacebook:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonFacebook"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"coins", [NSNumber numberWithInt:[[CoinsManager sharedInstance] getCoins]], nil]];
    
    if (!self.imageViewFacebookCoins.hidden)
    {
        [[MGShare sharedInstance] facebookShareString:[self getShareMessage]
                                   fromViewController:self
                                           completion:^(bool completed) {
                                               if (completed)
                                               {
                                                   [[CoinsManager sharedInstance] addCoins:COINS_REWARD_SHARE];
                                                   [[SoundUtils sharedInstance] playMusic:SoundTypeCoinsAdded];
                                                   _showShareReward = false;
                                                   [self refreshView];
                                               }
                                           }];
    }
    else
    {
        [[MGShare sharedInstance] facebookShareString:[self getShareMessage]
                                   fromViewController:self
                                           completion:nil];
    }
}

- (void)doButtonTwitter:(id)sender
{
    [Flurry logEvent:@"FINISH: doButtonTwitter"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"coins", [NSNumber numberWithInt:[[CoinsManager sharedInstance] getCoins]], nil]];
    
    if (!self.imageViewTwitterCoins.hidden)
    {
        [[MGShare sharedInstance] twitterShareString:[self getShareMessage]
                                  fromViewController:self
                                          completion:^(bool completed) {
                                              if (completed)
                                              {
                                                  [[CoinsManager sharedInstance] addCoins:COINS_REWARD_SHARE];
                                                  [[SoundUtils sharedInstance] playMusic:SoundTypeCoinsAdded];
                                                  _showShareReward = false;
                                                  [self refreshView];
                                              }
                                          }];
    }
    else
    {
        [[MGShare sharedInstance] twitterShareString:[self getShareMessage]
                                  fromViewController:self
                                          completion:nil];
    }
}

- (NSString*)getShareMessage
{
    NSMutableArray *messages = [[[NSMutableArray alloc] init] autorelease];
    
    if ([_gameSession isHighscore])
    {
        [messages addObject:[NSString stringWithFormat:@"I just improved my time record in Word Search. Check out this puzzle game!"]];
        [messages addObject:[NSString stringWithFormat:@"%@ : this is my new record in Word Search. Check these wonderful puzzles right now!", [_gameSession getTimeString:[_gameSession getSessionTimeInterval]]]];
    }
    else
    {
        [messages addObject:[NSString stringWithFormat:@"Check this very addictive puzzle game: Word Search!"]];
        [messages addObject:[NSString stringWithFormat:@"I just completed a \"%@\" puzzle in Word Search. Give it a try you too!", _gameSession.game.name]];
        [messages addObject:[NSString stringWithFormat:@"I can't stop playing this puzzle game. Word Search is fantastic!"]];
        [messages addObject:[NSString stringWithFormat:@"This Word Search puzzle game is fantastic. You haven't played something like this!"]];
        [messages addObject:[NSString stringWithFormat:@"Word Search is my favorite puzzle game. I can't stop playing it!"]];
    }
    
    return [messages objectAtIndex:arc4random() % (messages.count)];
}

@end
