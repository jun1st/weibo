//
//  RetweetStatusListCellView.m
//  weibo
//
//  Created by feng qijun on 9/12/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "RetweetStatusListCellView.h"

@implementation RetweetStatusListCellView

- (void)drawRect:(NSRect)dirtyRect
{
    if([self isSelected]) {
        [[NSColor selectedControlColor] set];
	}
	else {
		[[NSColor whiteColor] set];
    }
    
    
    //    //Draw the border and background
	NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:4.0 yRadius:4.0];
	[roundedRect fill];
    
    [[NSColor lightGrayColor] set];
    NSBezierPath *bottomBorderPath = [NSBezierPath bezierPath];
    [bottomBorderPath setLineWidth:2.0];
    [bottomBorderPath moveToPoint:CGPointMake(0, 0)];
    [bottomBorderPath lineToPoint:CGPointMake(self.bounds.size.width, 0)];
    
    [bottomBorderPath closePath];
    [bottomBorderPath stroke];
    
    //[self setWantsLayer:YES];
    
    //NSBezierPath *roundedTextViewRect = [NSBezierPath bezierPathWithRoundedRect:self.frame xRadius:4.0 yRadius:4.0];
    
    //[roundedTextViewRect fill];
    
}


-(void)prepareForReuse
{
    self.userName.stringValue = @"";
    self.userProfileImage.image = nil;
    //[self.statusTextView.textStorage setAttributedString:nil];
    
    CGRect oldStatusFrame = NSMakeRect(64, 49, 376, 30);
    [self.statusTextView setFrame:oldStatusFrame];
    
    CGRect oldRetweetStatusFrame = NSMakeRect(64, 11, 376, 30);
    [self.retweetTextView setFrame:oldRetweetStatusFrame];
    
    CGRect oldFrame = self.frame;
    oldFrame.size.height = 105.0f;
    //
    [self setFrame:oldFrame];
}

@end
