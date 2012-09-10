//
//  StatusListCellView.m
//  weibo
//
//  Created by feng qijun on 9/7/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "StatusListCellView.h"

@implementation StatusListCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

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
    
}


-(void)prepareForReuse
{
    self.userName.stringValue = @"";
    self.userProfileImage.image = nil;
    //[self.statusTextView.textStorage setAttributedString:nil];
    
    CGRect oldFrame = self.frame;
    oldFrame.size.height = 82.0f;
//    
    [self setFrame:oldFrame];
}

@end
