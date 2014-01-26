//
//  SSTextView.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 26/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSTextView.h"

@implementation SSTextView

- (void) layoutSubviews
{
    // Invalidate intrinsic size automatically if it has changed.
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.intrinsicContentSize, self.bounds.size))
        [self invalidateIntrinsicContentSize];
}


- (CGSize) intrinsicContentSize
{
    // Since Apple do not implement this method, override it.
    CGSize intrinsic = self.contentSize;
    intrinsic.width += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0f;
    intrinsic.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0f;
    return intrinsic;
}



@end
