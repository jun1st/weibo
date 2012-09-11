//
//  ComposeStatusViewController.h
//  weibo
//
//  Created by feng qijun on 9/10/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INPopoverController.h"

@interface ComposeStatusViewController : NSViewController
{
    NSTextView *statusTextView;
}

@property (assign) INPopoverController *parentPopoverController;
@property IBOutlet NSTextView *statusTextView;

-(IBAction)cancelComposing:(id)sender;
-(IBAction)postNewStatus:(NSButton *)button;

@end
