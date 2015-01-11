//
//  PackageViewController.m
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "PackageViewController.h"
#import "GameViewController.h"
#import "CoreDataUtils.h"
#import "Category.h"
#import "Game.h"
#import "PackageGameCell.h"
#import "StoreCoinsViewController.h"
#import "ImageUtils.h"
#import "Flurry.h"
#import "configuration.h"
#import "SoundUtils.h"
#import "GADBannerView.h"
#import "MGAdsManager.h"

@interface PackageViewController ()

@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSArray *games;

@property (nonatomic, retain) GADBannerView *bannerView;

- (void)configureGameCell:(PackageGameCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PackageViewController

- (id)initWithCategory:(Category *)category
{
    NSString *xib = @"PackageViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"PackageViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        self.category = category;
        
        NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                         ascending:YES] autorelease];
        self.games = [[self.category.games allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorID]];
        
        //  load cell
        NSString *xib = @"PackageGameCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"PackageGameCell_iPad";
        }
        self.cellLoaderGame = [UINib nibWithNibName:xib bundle:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.category release];
    [self.games release];
    [self.tableView release];
    [self.cellGame release];
    [self.cellLoaderGame release];
    [self.labelTitle release];
    [_viewBannerContainer release];
    [_constraintBannerHeight release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Marker Felt" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Marker Felt" size:20];
    }
    
    self.labelTitle.text = NSLocalizedString(self.category.name, nil);
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
    
    [self.tableView reloadData];
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

- (void)doButtonBack:(id)sender
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doButtonStore:(id)sender
{
    [Flurry logEvent:@"HOME: doButtonStore"];
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    [self.navigationController pushViewController:[StoreCoinsViewController sharedInstanceWithDelegate:nil
                                                                                    showNotEnoughCoins:NO] animated:NO];
}

#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.games.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 77;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        height = 130;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PackageGameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PackageGameCell"];
    if (cell == nil) {
        [self.cellLoaderGame instantiateWithOwner:self options:nil];
        cell = self.cellGame;
        self.cellGame = nil;
    }
    
    [self.cellLoaderGame instantiateWithOwner:self options:nil];
    
    [self configureGameCell:cell
                atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    Game *game = [self.games objectAtIndex:indexPath.row];
    GameViewController *gameViewCont = [[GameViewController alloc] initWithGame:game parentViewController:self];
    [self.navigationController pushViewController:gameViewCont animated:YES];
}

- (void)configureGameCell:(PackageGameCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Game *game = [self.games objectAtIndex:indexPath.row];
    cell.labelName.text = NSLocalizedString(game.name, nil);
    
    NSNumber *sum = [game.sessions valueForKeyPath:@"@sum.points"];
//    NSString *points = [NSString stringWithFormat:@"%d", sum.intValue];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:31];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:18];
       // NSLog( @"%@", [UIFont fontNamesForFamilyName:@"Comic Sans"] );
    }
    
    cell.labelName.text = cell.labelName.text;// [NSString stringWithFormat:@"%@ --- %@", points, cell.labelName.text];
    
    NSString *name = [NSString stringWithFormat:@"puzzle%d.png", game.identifier.intValue];
    UIImage *image = [UIImage imageNamed:name];
    if (image)
    {
        cell.imageViewIcon.image = [UIImage imageNamed:name];
    }
    else
    {
        cell.imageViewIcon.image = [UIImage imageNamed:@"puzzle.png"];
    }
    
    [cell.viewStars addSubview:[ImageUtils getStarImageViewForPercentage:sum.floatValue / (float)GAME_TOTAL_POINTS]];
}

#pragma mark -


@end
