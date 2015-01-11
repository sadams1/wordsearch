//
//  StorePackagesViewController.h
//  flows
//
//  Created by Marius Rott on 10/23/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StorePackageCell;

@interface StorePackagesViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *viewBackground;
@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet StorePackageCell *cellPackage;
@property (nonatomic, retain) UINib *cellLoaderPackage;

- (IBAction)doButtonClose:(id)sender;

@end
