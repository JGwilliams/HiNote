//
//  SSCheckBox.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 26/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSCheckBox.h"

@interface SSCheckBox()
@property (nonatomic, strong) UILabel * tickLabel;
@end


@implementation SSCheckBox

- (void) initialise
{
    // Show a box, so the user knows there's something to interact with
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2.0;
    
    // Calculate the proper size of the tick
    CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height);
    
    // Create the tick label
    self.tickLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.tickLabel.font = [UIFont systemFontOfSize:minDimension];
    self.tickLabel.textAlignment = NSTextAlignmentCenter;
    self.tickLabel.text = @"\u2713";
    
    // Add it, but hide it since the default is unchecked
    [self addSubview:self.tickLabel];
    self.tickLabel.alpha = 0.0;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initialise];
    return self;
}



- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initialise];
    return self;
}



- (void) setFrame:(CGRect)frame
{
    // Calculate the proper size of the tick
    if (self.tickLabel && !CGSizeEqualToSize(frame.size, self.frame.size)) {
        CGFloat minDimension = MIN(self.bounds.size.width, self.bounds.size.height);
        self.tickLabel.font = [UIFont systemFontOfSize:minDimension];
    }
    
    [super setFrame:frame];
}



- (void) setChecked:(BOOL)checked
{
    // Hide or show the tick as necessary
    _checked = checked;
    if (checked) self.tickLabel.alpha = 1.0;
    else self.tickLabel.alpha = 0.0;
}



- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Nice simple touch method to check or uncheck
    self.checked = !self.checked;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}



@end
