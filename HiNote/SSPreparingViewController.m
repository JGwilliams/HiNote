//
//  SSPreparingViewController.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 27/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSPreparingViewController.h"

@interface SSPreparingViewController ()
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView * activity;
@end

@implementation SSPreparingViewController

- (void) viewDidAppear:(BOOL)animated
{
    [self.activity startAnimating];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.activity stopAnimating];
}

@end
