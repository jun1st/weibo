//
//  ReplyStatusViewController.h
//  weibo
//
//  Created by feng qijun on 10/4/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INPopoverController.h"

@interface ReplyStatusViewController : NSViewController
{
    NSTextView *_commentTextView;
}

- (IBAction)cancelComment:(id)sender;
- (IBAction)postComment:(id)sender;

@property (assign) INPopoverController *parentPopoverController;
@property IBOutlet NSTextView *commentTextView;
@property NSString *statusId;

@end
