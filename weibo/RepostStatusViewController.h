//
//  RepostStatusViewController.h
//  weibo
//
//  Created by feng qijun on 10/5/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INPopoverController.h"

@interface RepostStatusViewController : NSViewController
{
    NSTextView * _repostCommentTextView;
}

@property (assign) INPopoverController *parentPopoverController;
@property IBOutlet NSTextView *repostCommentTextView;
@property (copy) NSString *statusIdStr;

- (IBAction)cancel:(id)sender;
- (IBAction)sendRepost:(id)sender;


@end
