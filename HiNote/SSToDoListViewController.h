//
//  SSToDoListViewController.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSToDoListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

// For adaptability, we pass in the managed object context rather than attempting
// to read it directly from the app delegate.
@property (nonatomic, strong) NSManagedObjectContext * context;

@end
