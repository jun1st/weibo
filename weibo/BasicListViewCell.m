//
//  BasicListViewCell.m
//  weibo
//
//  Created by feng qijun on 10/5/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "BasicListViewCell.h"
#import "INPopoverController.h"
#import "ReplyStatusViewController.h"
#import "RepostStatusViewController.h"

@interface BasicListViewCell ()

@property (strong) INPopoverController *popoverController;

@end

@implementation BasicListViewCell


- (IBAction)showReplyDialog:(id)sender
{
    if (self.popoverController && self.popoverController.popoverIsVisible) {
        [self.popoverController closePopover:nil];
    }
    else
    {
        ReplyStatusViewController *replyStatusViewController = [[ReplyStatusViewController alloc] init];
        
        self.popoverController = [[INPopoverController alloc] initWithContentViewController:replyStatusViewController];
        
        replyStatusViewController.statusId = self.statusId;
        replyStatusViewController.parentPopoverController = self.popoverController;
        
        //[self.composeWindowController showWindow:self];
        self.popoverController.closesWhenPopoverResignsKey = NO;
        [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
    }
    
}

- (IBAction)repostWithComment:(id)sender
{
    if (self.popoverController && self.popoverController.popoverIsVisible) {
        [self.popoverController closePopover:nil];
    }
    else
    {
        RepostStatusViewController *repostStatusViewController = [[RepostStatusViewController alloc] init];
        self.popoverController = [[INPopoverController alloc] initWithContentViewController:repostStatusViewController];
        
        repostStatusViewController.statusIdStr = self.statusId;
        repostStatusViewController.parentPopoverController = self.popoverController;
        
        self.popoverController.closesWhenPopoverResignsKey = NO;
        [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
        
    }
}

#pragma NSTextViewDelegate

-(BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
    // sometimes aLink will not be an nsstring.  This is a quick hack to get around that:
    
    if (![link isKindOfClass:[NSString class]]) {
        link = [link description];
    }
    
    if ([link hasPrefix:@"hashtag://"]) {
        NSRange range = [link rangeOfString:link];
        NSString *name = [[link substringFromIndex:NSMaxRange(range)]
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDetailNotification" object:name];
        return YES;
    }
    else if ([link hasPrefix:@"username://"]) {
        NSRange range = [link rangeOfString:link];
        NSString *name = [[link substringFromIndex:NSMaxRange(range)]
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDetailNotification" object:name];

        return YES;
    }
    
    return NO; // let appkit take care of the link
}

@end
