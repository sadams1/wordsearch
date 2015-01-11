//
//  CoreDataUtils.m
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "CoreDataUtils.h"

@implementation CoreDataUtils

+ (CoreDataUtils *)sharedInstance
{
    static CoreDataUtils *instance;
    if (instance == nil)
    {
        instance = [[CoreDataUtils alloc] init];
    }
    return instance;
}

- (void)dealloc
{
    [self.managedObjectContext release];
    [super dealloc];
}

@end
