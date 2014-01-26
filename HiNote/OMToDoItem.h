//
//  OMToDoItem.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const kToDoCreated;
extern NSString * const kToDoUpdated;

@interface OMToDoItem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * synopsis;

@end
