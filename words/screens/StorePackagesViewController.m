//
//  StorePackagesViewController.m
//  flows
//
//  Created by Marius Rott on 10/23/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "StorePackagesViewController.h"
#import "configuration.h"
#import "MGIAPHelper.h"
#import "Flurry.h"
#import "SoundUtils.h"
#import "ImageUtils.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MGAdsManager.h"
#import "CoreDataUtils.h"
#import "Category.h"
#import "StorePackageCell.h"

@interface StorePackagesViewController ()
{
    BOOL _videoPlayed;
    BOOL _showVideoNoAds;
}

@property (nonatomic, retain) NSArray *skProducts;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *stringMessage;

- (void)loadSKProducts;

- (void)notificationProductPurchased:(NSNotification *)notification;
- (void)notificationProductPurchaseFailed:(NSNotification *)notification;

- (void)networkChanged:(NSNotification *)notification;

@end

@implementation StorePackagesViewController

- (id)init
{
    NSString *xib = @"StorePackagesViewController";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        xib = @"StorePackagesViewController_iPad";
    }
    self = [super initWithNibName:xib bundle:nil];
    if (self)
    {
        //  load data
        NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                          ascending:YES] autorelease];
        
        NSFetchRequest *requestCategory = [[[NSFetchRequest alloc] initWithEntityName:@"Category"] autorelease];
        requestCategory.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
        NSError *error1 = nil;
        self.categories = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestCategory error:&error1];
        
        //  load cell
        NSString *xib = @"StorePackageCell";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            xib = @"StorePackageCell_iPad";
        }
        self.cellLoaderPackage = [UINib nibWithNibName:xib bundle:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationProductPurchased:)
                                                     name:IAPHelperProductPurchasedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationProductPurchaseFailed:)
                                                     name:IAPHelperProductPurchaseFailedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.viewBackground release];
    [self.labelTitle release];
    [self.tableView release];
    [self.cellLoaderPackage release];
    [self.cellPackage release];
    [self.stringMessage release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.viewBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"window_store.png"]];
//    self.view.backgroundColor = THEME_COLOR_GRAY_BORDER;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    if (reachability.currentReachabilityStatus != NotReachable)
    {
        [self loadSKProducts];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkConnection", nil)
                                                        message:NSLocalizedString(@"networkConnectionMsg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.labelTitle.font = [UIFont fontWithName:@"Nexa Bold" size:30];
    }
    else
    {
        self.labelTitle.font = [UIFont fontWithName:@"Nexa Bold" size:20];
    }
    self.labelTitle.text = NSLocalizedString(@"unlockPackages", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewBackground.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doButtonClose:(id)sender
{
    [Flurry logEvent:@"STORE PACKAGES: doButtonBack"];
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeBack];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)networkChanged:(NSNotification *)notification
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"not reachable");
    }
    else
    {
        [self loadSKProducts];
    }
}

- (void)loadSKProducts
{
    if (!self.skProducts.count)
    {
        [[MGIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success)
            {
                self.skProducts = products;
                [self.tableView reloadData];
            }
        }];
    }
}


- (void)notificationProductPurchased:(NSNotification *)notification
{
    NSString *bundleID = notification.object;
    
    [Flurry logEvent:@"StorePackages: purchasedProduct"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                      @"bundleID",
                      bundleID,
                      nil]];
    
    //  disable MGAdsManager ads
    [[MGAdsManager sharedInstance] disableAds];
    
    [self.tableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                    message:[NSString stringWithFormat:@"You have successfully unlocked %@!", self.stringMessage]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)notificationProductPurchaseFailed:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase error"
                                                    message:@"There was an error completing your purchase. Please try again later!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (SKProduct *)getSKProductForBundleID:(NSString *)bundleID
{
    if (self.skProducts != nil && [self.skProducts count] > 0)
    {
        for (SKProduct *tmp in self.skProducts)
        {
            if ([tmp.productIdentifier compare:bundleID] == NSOrderedSame)
            {
                return tmp;
            }
        }
    }
    return nil;
}



#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    for (Category *category in self.categories)
    {
        NSLog(@"%@", category.bundleID);
        if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            count++;
        }
    }
    
    return count + 1;   //  for unlock all
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
    UITableViewCell *cell = nil;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"TABLE_VIEW_TYPE_STORE_CATEGORY"];
    if (cell == nil) {
        [self.cellLoaderPackage instantiateWithOwner:self options:nil];
        cell = self.cellPackage;
        self.cellPackage = nil;
    }
    
    [self.cellLoaderPackage instantiateWithOwner:self options:nil];
    
    [self configurePackageCell:(StorePackageCell*)cell
                   atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SoundUtils sharedInstance] playSoundEffect:SoundTypeClickOnButton];
    
    NSString *bundleID = STORE_BUNDLE_UNLOCK_ALL;
    self.stringMessage = @"All Packages";
    
    if (indexPath.row > 0)
    {
        int count = 0, index = 0;
        for (Category *category in self.categories)
        {
            if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
            {
                if (index + 1 == indexPath.row)
                {
                    break;
                }
                index++;
            }
            count++;
        }
        Category *category = [self.categories objectAtIndex:count];
        bundleID = category.bundleID;
        self.stringMessage = category.name;
    }
    
    [Flurry logEvent:@"STORE PACKAGES: selected category row: " withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"bundleID", bundleID, nil]];
    
    SKProduct *product = [self getSKProductForBundleID:bundleID];
    if (!product)
        return;
    
    [[MGIAPHelper sharedInstance] buyProduct:product];
}

- (void)configurePackageCell:(StorePackageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView new] autorelease];
    cell.selectedBackgroundView = [[UIView new] autorelease];
    
    int count = 0, index = 0;
    
    for (Category *category in self.categories)
    {
        count++;
        if (category.bundleID.length && ![[MGIAPHelper sharedInstance] productPurchased:category.bundleID])
        {
            if (index + 1 == indexPath.row)
            {
                break;
            }
            index++;
        }
    }
    Category *category = [self.categories objectAtIndex:count - 1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        cell.labelName.font = [UIFont fontWithName:@"Nexa Bold" size:26];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:20];
        cell.labelPrice.font = [UIFont fontWithName:@"Nexa Bold" size:22];
    }
    else
    {
        cell.labelName.font = [UIFont fontWithName:@"Nexa Bold" size:18];
        cell.labelDescription.font = [UIFont fontWithName:@"Segoe UI" size:14];
        cell.labelPrice.font = [UIFont fontWithName:@"Nexa Bold" size:22];
    }
    
    cell.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
    
    if (indexPath.row == 0)
    {
        cell.labelName.text = NSLocalizedString(@"unlockAllPackages", nil);
        cell.labelDescription.text = @"";
        cell.labelPrice.text = [MGIAPHelper priceForSKProduct:[self getSKProductForBundleID:STORE_BUNDLE_UNLOCK_ALL]];
    }
    else
    {
        cell.labelName.text = NSLocalizedString(category.name, nil);
        cell.labelDescription.text = [NSString stringWithFormat:@"%d puzzles", category.games.count];
        cell.labelPrice.text = [MGIAPHelper priceForSKProduct:[self getSKProductForBundleID:category.bundleID]];
    }
    
//    cell.labelName.textColor = [UIColor greenColor];
//    cell.labelDescription.textColor = THEME_COLOR_GRAY_TEXT;
    NSString *imageName = @"pack01.png";
    cell.imageViewIcon.image = [UIImage imageNamed:imageName];
}

#pragma mark -


@end
