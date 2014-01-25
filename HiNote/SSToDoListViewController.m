//
//  SSToDoListViewController.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSToDoListViewController.h"
#import "OMToDoItem.h"

// Keep properties private unless there is a need to expose them
@interface SSToDoListViewController ()

// No need to retain this as it will be retained by the view
@property (nonatomic, assign) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSFetchedResultsController * fetchController;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@end

NSString * const toDoItemName = @"ToDoItem";
NSString * const toDoCellIdentifier = @"todo_cell";
NSString * const newItemCellIdentifier = @"new_item_cell";
NSString * const fetchControllerCache = @"todo_list_cache";

@implementation SSToDoListViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // We use the date formatter a lot, so best not to recreate it every time.
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        // TODO: listen out for keyboard notifications so we can adjust the table view
    }
    return self;
}



#pragma mark - Fetched Results Delegate

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}



- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    // TODO: this method will require optimising as it could occur many times in succession
    // We should consider caching changes until the process ends and performing them all at once.
    // This method will suffice for testing purposes.
    
    switch (type) {
        case NSFetchedResultsChangeDelete :
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeInsert :
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove :
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate :
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        default : break;
    }
}



- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
            atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    // TODO: this method will require optimising as it could occur many times in succession
    // We should consider caching changes until the process ends and performing them all at once.
    // This method will suffice for testing purposes.
    
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeDelete :
            [self.tableView deleteSections:indexSet
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeInsert :
            [self.tableView insertSections:indexSet
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        default: // Other change types do not occur for sections
            break;
    }
}



#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> info = [self.fetchController.sections objectAtIndex:indexPath.section];
    
    // If this is the 'New Item' row, add a new item
    if (indexPath.row >= [info numberOfObjects]) {
        OMToDoItem * newItem = [NSEntityDescription insertNewObjectForEntityForName:toDoItemName inManagedObjectContext:self.context];
        newItem.title = @"New Item";
        NSError * error = nil;
        if (![self.context save:&error])
            NSLog(@"Error saving context: %@", error.localizedDescription);
        return;
    }
}



#pragma mark - Table View Datasource

// N.B. the majority of the data source is handled by our NSFetchedResultsController
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = [self.fetchController sections].count;
    return MAX(sectionCount, 1);
}



- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchController sectionIndexTitles];
}



- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchController sectionForSectionIndexTitle:title atIndex:index];
}



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= [self.fetchController.sections count]) return 1;
    id <NSFetchedResultsSectionInfo> info = [self.fetchController.sections objectAtIndex:section];
    return [info numberOfObjects] + 1;
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The last cell is always the 'add new item' cell.
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:toDoCellIdentifier];
        if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toDoCellIdentifier];
        cell.textLabel.text = @"Tap to add a new item.";
        return cell;
    }
    
    // Populate the cell with information from the managed object
    // TODO: replace this standard cell with a custom cell stored in a registered class or nib
    OMToDoItem * item = [self.fetchController objectAtIndexPath:indexPath];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:toDoCellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:toDoCellIdentifier];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:item.created];
    return cell;
}



#pragma mark - Getters and Setters

- (void) setContext:(NSManagedObjectContext *)context
{
    // Update local variables
    _context = context;
    if (!context) {
        self.fetchController = nil;
        return;
    }
    
    // Prepare a suitable fetch request
    NSSortDescriptor * dateSort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:toDoItemName];
    request.sortDescriptors = @[dateSort];
    
    // Allocate the fetch controller
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context
                                                                 sectionNameKeyPath:nil cacheName:fetchControllerCache];
    self.fetchController.delegate = self;
    NSError * error = nil;
    if (![self.fetchController performFetch:&error])
        NSLog(@"Error creating fetched results controller: %@", error.localizedDescription);
    [self.tableView reloadData];
}



@end
