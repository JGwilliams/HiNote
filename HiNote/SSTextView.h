//
//  SSTextView.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 26/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 Since the default implementation of UITextView does not have an intrinsicSize,
 it will not work properly with AutoLayout. This class exists primarily to enable
 this feature so that we can resize table view cells when the contents update.
 */

@interface SSTextView : UITextView

@end
