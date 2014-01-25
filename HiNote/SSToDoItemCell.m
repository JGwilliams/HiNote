//
//  SSToDoItemCell.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSToDoItemCell.h"
#import "OMToDoItem.h"

@interface SSToDoItemCell ()

// Nib Objects
@property (nonatomic, assign) IBOutlet UILabel * titleLabel;
@property (nonatomic, assign) IBOutlet UILabel * createdLabel;
@property (nonatomic, assign) IBOutlet UILabel * updatedLabel;
@property (nonatomic, assign) IBOutlet UILabel * synopsisLabel;
@property (nonatomic, assign) IBOutlet UITextView * titleView;
@property (nonatomic, assign) IBOutlet UITextView * synopsisView;

// Autolayout Constraints
@property (nonatomic, assign) IBOutlet NSLayoutConstraint * titleLabelHeight;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint * titleViewHeight;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint * synopsisLabelHeight;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint * synopsisViewHeight;

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end


@implementation SSToDoItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // We use the date formatter a lot, so best not to recreate it every time.
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



- (void) setToDoItem:(OMToDoItem *)toDoItem
{
    _toDoItem = toDoItem;
    self.titleLabel.text = self.titleView.text = toDoItem.title;
    self.synopsisLabel.text = self.synopsisView.text = toDoItem.synopsis;
    
    NSString * created = [self.dateFormatter stringFromDate:toDoItem.created];
    NSString * updated = [self.dateFormatter stringFromDate:toDoItem.updated];
    
    self.createdLabel.text = [NSString stringWithFormat:@"Created: %@", created];
    self.updatedLabel.text = [NSString stringWithFormat:@"Updated: %@", updated];
    
    CGSize titleSize = [self.titleLabel sizeThatFits:self.titleLabel.frame.size];
    CGSize synopsisSize = [self.synopsisLabel sizeThatFits:self.synopsisLabel.frame.size];
    self.titleLabelHeight.constant = titleSize.height;
    self.synopsisLabelHeight.constant = synopsisSize.height;
    [self layoutIfNeeded];
}



- (CGFloat) desiredHeight
{
    if (self.synopsisLabel.text.length == 0)
        return CGRectGetMaxY(self.updatedLabel.frame) + 5.0;
    return CGRectGetMaxY(self.synopsisLabel.frame) + 5.0;
}



@end
