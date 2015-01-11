//
//  MGAppLovin.h
//  flows
//
//  Created by Marius Rott on 16/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"
#import "ALAd.h"
#import "ALAdLoadDelegate.h"
#import "ALAdDisplayDelegate.h"

@interface MGAppLovin : NSObject <MGAdsProvider, ALAdLoadDelegate, ALAdDisplayDelegate>
{
    bool _isAvailable;
}

@property (strong, atomic)    ALAd* cachedAd;

@end
