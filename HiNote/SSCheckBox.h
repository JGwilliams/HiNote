//
//  SSCheckBox.h
//  HiNote
//
//  Created by Jonathan Gwilliams on 26/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 For speed, a nice simple control that shows only a bounding box
 and an optional check mark, and inverts its checked status when
 tapped.
 */

@interface SSCheckBox : UIControl

@property (nonatomic, assign) BOOL checked;

@end
