//
//  OMToDoItem.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "OMToDoItem.h"


@implementation OMToDoItem

@dynamic title;
@dynamic status;
@dynamic updated;
@dynamic created;
@dynamic synopsis;


// Allow the item to keep track of its own creation and last updated dates.

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    NSDate * current = [NSDate date];
    [self setPrimitiveValue:current forKey:@"created"];
    [self setPrimitiveValue:current forKey:@"updated"];
}



- (void) willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updated"];
}



@end
