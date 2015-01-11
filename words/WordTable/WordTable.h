//
//  WordTableViewController.h
//  word
//
//  Created by marius on 8/5/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

// #define TABLE_SIZE  11
#define TABLE_SIZE  6


@class WordTable;

@protocol WordTableDelegate <NSObject>

- (void)wordTable:(WordTable*)wordTable changedTmpWord:(NSString*)word;
- (void)wordTable:(WordTable*)wordTable foundWord:(NSString*)word;
- (void)wordTableCompletedGame:(WordTable*)wordTable;

@end

@interface WordTable : NSObject

@property (nonatomic, retain) UIView *view;

- (id)initWithView:(UIView*)view words:(NSArray*)words delegate:(id<WordTableDelegate>)delegate;
- (void)viewDidLoad;
- (void)viewDidLayoutSubviews;


- (bool)canRemoveUnnecessaryChars:(int)charsCount;
- (void)doRemoveUnnecessaryChars:(int)charsCount;
- (void)doWordStartCharHint;
- (void)doResolveGame;

- (void)touchesBegan:(CGPoint)point;
- (void)touchesCancelled:(CGPoint)point;
- (void)touchesEnded:(CGPoint)point;
- (void)touchesMoved:(CGPoint)point;

@end
