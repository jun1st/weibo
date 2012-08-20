//
//  WBMessageTableCellView.m
//  weibo
//
//  Created by derek on 12-8-15.
//  Copyright (c) 2012年 feng qijun. All rights reserved.
//

#import "WBMessageTableCellView.h"

@interface WBMessageTableCellView()

@end;

@implementation WBMessageTableCellView

-(void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    // Only take effect for double clicks; remove to allow for single clicks
    if (theEvent.clickCount == 1) {
        NSLog(@"clicked");
        [self.window makeFirstResponder:self.textField];
    }
    
    
}

@end
