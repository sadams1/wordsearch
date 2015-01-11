//
//  MGConfiguration.h
//  MGAds
//
//  Created by Marius Rott on 11/23/12.
//  Copyright (c) 2012 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>

#define     MG_ADS_REVMOB_APP_ID        @"5483d58375f089d01576436c"
#define     MG_ADS_CHARTBOOST_APP_ID    @"54a618d743150f168db11000"
#define     MG_ADS_CHARTBOOST_APP_SIG   @"ccd1abbd5955829fd1f385a6ec6837cbe5dfa9c3"


#define     MG_REFETCH_AFTER            30

#define     MG_APP_AD_MIN_DISPLAY       1
#define     MG_APP_AD_SECONDS_BETWEEN   90


typedef enum
{
    MgAdsProviderRevMob = 1,
    MgAdsProviderChartboost,
    MgAdsProviderPlayHaven,
    MgAdsProviderAppLovin
} MgAdsTypeProvider;

#define     MG_ADS_PROVIDER_ORDER_1     MgAdsProviderAppLovin
#define     MG_ADS_PROVIDER_ORDER_2     MgAdsProviderChartboost
#define     MG_ADS_PROVIDER_ORDER_3     MgAdsProviderRevMob
#define     MG_ADS_PROVIDER_ORDER_4     MgAdsProviderPlayHaven
#define     MG_ADS_NUM_PROVIDERS        4

