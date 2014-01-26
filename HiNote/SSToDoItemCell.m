//
//  SSToDoItemCell.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSToDoItemCell.h"
#import "SSCheckBox.h"
#import "OMToDoItem.h"

@interface SSToDoItemCell ()

// Nib Objects
@property (nonatomic, assign) IBOutlet UILabel * createdLabel;
@property (nonatomic, assign) IBOutlet UILabel * updatedLabel;
@property (nonatomic, assign) IBOutlet UITextView * titleView;
@property (nonatomic, assign) IBOutlet UITextView * synopsisView;
@property (nonatomic, assign) IBOutlet SSCheckBox * checkBox;

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

- (IBAction)checkButtonTouched:(id)sender;

@end


@implementation SSToDoItemCell

- (void) initialise
{
    // We use the date formatter a lot, so best not to recreate it every time.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
}



- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initialise];
    return self;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) [self initialise];
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



- (void) setToDoItem:(OMToDoItem *)toDoItem
{
    // Set ToDo item
    _toDoItem = toDoItem;
    self.titleView.text = toDoItem.title;
    self.synopsisView.text = toDoItem.synopsis;
    
    // Set dates
    NSString * created = [self.dateFormatter stringFromDate:toDoItem.created];
    NSString * updated = [self.dateFormatter stringFromDate:toDoItem.updated];
    self.createdLabel.text = [NSString stringWithFormat:@"Created: %@", created];
    self.updatedLabel.text = [NSString stringWithFormat:@"Updated: %@", updated];
    
    // Check or uncheck the box
    self.checkBox.checked = [toDoItem.status boolValue];
    
    // Autolayout will take care of resizing the cell
}



- (IBAction)checkButtonTouched:(SSCheckBox *)sender
{
    // Update the todo item's status and inform the delegate of the change.
    self.toDoItem.status = [NSNumber numberWithBool:sender.checked];
    if (self.delegate) [self.delegate cellDidFinishEditing:self];
}



#pragma mark - Text View Delegate

- (void) textViewDidChange:(UITextView *)textView
{
    // Update the appropriate managed object property
    if (textView == self.titleView) {
        self.toDoItem.title = textView.text;
    } else if (textView == self.synopsisView) {
        self.toDoItem.synopsis = textView.text;
    }
    
    // Ensure that the cell is resized appropriately
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    if (self.delegate) [self.delegate cellDidInvalidateHeight:self];
    
    // TODO: it would be nice to optimise this method so that it is
    // only executed when a change of height is required.
}



- (void) textViewDidEndEditing:(UITextView *)textView
{
    // Forward the responsibility to a delegate object
    if (self.delegate) [self.delegate cellDidFinishEditing:self];
}



- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Act like a text view; exit upon hitting the return key.
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



@end
