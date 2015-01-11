//
//  PackageViewController.h
//  words
//
//  Created by Marius Rott on 9/5/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreCoinsViewController.h"

@class Category;
@class PackageGameCell;

@interface PackageViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet PackageGameCell *cellGame;
@property (nonatomic, retain) UINib *cellLoaderGame;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;

@property (nonatomic, retain) IBOutlet UIView *viewBannerContainer;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *constraintBannerHeight;


- (id)initWithCategory:(Category*)category;

- (IBAction)doButtonBack:(id)sender;
- (IBAction)doButtonStore:(id)sender;

@end
