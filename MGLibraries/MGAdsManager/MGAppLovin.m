//
//  MGAppLovin.m
//  flows
//
//  Created by Marius Rott on 16/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "MGAppLovin.h"
#import "Flurry.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"

@implementation MGAppLovin


- (id)init
{
    self = [super init];
    if (self)
    {
        _isAvailable = false;
        
        
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderAppLovin;
}

- (void)fetchAds
{
    [[[ALSdk shared] adService] loadNextAd: [ALAdSize sizeInterstitial] andNotify: self];
}

- (BOOL)isAvailable
{
    return _isAvailable;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [Flurry logEvent:@"MGAdsManager: AppLovin"];
    [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
}



-(void) adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    self.cachedAd = ad;
    _isAvailable = true;
}

-(void) adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Ad could not be loaded (network timeout or no-fill)
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}


-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view
{
    
}

-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

-(void) ad:(ALAd *) ad wasClickedIn: (UIView *)view
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}


@end
