//
//  SSToDoItemCell.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSToDoItemCellDelegate;

@class OMToDoItem;
@interface SSToDoItemCell : UITableViewCell <UITextViewDelegate>
@property (nonatomic, assign) id <SSToDoItemCellDelegate> delegate;
@property (nonatomic, strong) OMToDoItem * toDoItem;
- (void) resignFirstResponder;
@end

@protocol SSToDoItemCellDelegate <NSObject>
- (void) cellDidInvalidateHeight:(SSToDoItemCell *)cell;
- (void) cellDidBeginEditing:(SSToDoItemCell *)cell;
- (void) cellDidFinishEditing:(SSToDoItemCell *)cell;
@end