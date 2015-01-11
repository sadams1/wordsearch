//
//  MGChartboost.h
//  MGAds
//
//  Created by Marius Rott on 1/9/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"
#import <Chartboost/Chartboost.h>

@interface MGChartboost : NSObject <MGAdsProvider, ChartboostDelegate>
{
    bool _isAvailable;
}

@property (strong, nonatomic) Chartboost* interstitial;

@end
