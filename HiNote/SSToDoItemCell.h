//
//  SSToDoItemCell.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMToDoItem;
@interface SSToDoItemCell : UITableViewCell <UITextViewDelegate>
@property (nonatomic, strong) OMToDoItem * toDoItem;
- (CGFloat) desiredHeight;
@end
