//
//  SSToDoListViewController.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSToDoListViewController.h"
#import "SSToDoItemCell.h"
#import "OMToDoItem.h"

// Keep properties private unless there is a need to expose them
@interface SSToDoListViewController () <SSToDoItemCellDelegate>

// No need to retain this as it will be retained by the view
@property (nonatomic, assign) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSFetchedResultsController * fetchController;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@property (nonatomic, strong) SSToDoItemCell * sizingCell;
@end


NSString * const toDoItemName = @"ToDoItem";
NSString * const toDoCellIdentifier = @"todo_cell";
NSString * const toDoCellNibName = @"SSToDoItemCell";
NSString * const newItemCellIdentifier = @"new_item_cell";
NSString * const fetchControllerCache = @"todo_list_cache";

@implementation SSToDoListViewController

- (void) viewDidLoad
{
    UINib * cellNib = [UINib nibWithNibName:toDoCellNibName bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:toDoCellIdentifier];
    self.sizingCell = [[cellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForICloudNotification:)
     name: NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
}



- (void) updateForICloudNotification:(NSNotification *)notification
{
    NSLog(@"Update for iCloud");
    NSError * error = nil;
    if (![[self fetchController] performFetch:&error]) {
        NSLog(@"Fetch error: %@", error.localizedDescription);
    }
}



- (void) keyboardChanged:(NSNotification *)notification
{
    CGRect newFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect localFrame = [[[UIApplication sharedApplication] keyWindow] convertRect:newFrame toView:self.view];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.tableView.frame.origin.y - localFrame.origin.y, 0.0);
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
            // Do nothing - if we update the cell, it loses first responder status
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
        newItem.synopsis = @"Synopsis";
        newItem.created = [NSDate date];
        newItem.lastUpdated = [NSDate date];
        
        NSError * error = nil;
        if (![self.context save:&error])
            NSLog(@"Error saving context: %@", error.localizedDescription);
        return;
    }
    
    // TODO: reinstate cell enlargement by some other means
    // TODO: scroll to a suitable position to keep the cell visible
}



- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> info = [self.fetchController.sections objectAtIndex:indexPath.section];
    return (indexPath.row < [info numberOfObjects]);
}



- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OMToDoItem * item = [self.fetchController objectAtIndexPath:indexPath];
        if (item) {
            [self.context deleteObject:item];
            NSError * error = nil;
            if (![self.context save:&error])
                NSLog(@"Error saving context: %@", error.localizedDescription);
        }
    }
}



#pragma mark - Cell Delegate

- (void) cellDidInvalidateHeight:(SSToDoItemCell *)cell
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}



- (void) cellDidFinishEditing:(SSToDoItemCell *)cell
{
    cell.toDoItem.lastUpdated = [NSDate date];
    
    // The cell has finished editing, so save the context
    if ([self.context hasChanges]) {
        NSError * error = nil;
        if (![self.context save:&error]) {
            NSLog(@"Error saving context: %@", error.localizedDescription);
        }
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
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:newItemCellIdentifier];
        if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newItemCellIdentifier];
        cell.textLabel.text = @"Tap to add a new item.";
        return cell;
    }
    
    // Populate the cell with information from the managed object
    SSToDoItemCell * cell = (SSToDoItemCell *)[tableView dequeueReusableCellWithIdentifier:toDoCellIdentifier forIndexPath:indexPath];
    cell.toDoItem = [self.fetchController objectAtIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) return 48.0;
    
    // Update the contents and force a refresh
    self.sizingCell.toDoItem = [self.fetchController objectAtIndexPath:indexPath];
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];

    // Return the desired height
    CGSize desired = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return desired.height;
}



- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0;
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
