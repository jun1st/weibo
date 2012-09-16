//
//  RoundedNSTextView.m
//  weibo
//
//  Created by feng qijun on 9/14/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "RoundedNSTextView.h"

@implementation RoundedNSTextView

-(void)awakeFromNib
{
    [self setTextContainerInset:NSMakeSize(4, 2)];
}

-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    // black outline
//	NSRect blackOutlineFrame = NSMakeRect(0.0, 0.0, [self bounds].size.width, [self bounds].size.height-1.0);
//	NSGradient *gradient = nil;
//	if ([NSApp isActive]) {
//		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.24 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.374 alpha:1.0]];
//	}
//	else {
//		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.558 alpha:1.0]];
//	}
//	[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:blackOutlineFrame xRadius:3.6 yRadius:3.6] angle:90];
//	
//	
//	// top inner shadow
//	NSRect shadowFrame = NSMakeRect(1, 1, [self bounds].size.width-2.0, 10.0);
//	[[NSColor colorWithCalibratedWhite:0.88 alpha:1.0] set];
//	[[NSBezierPath bezierPathWithRoundedRect:shadowFrame xRadius:2.9 yRadius:2.9] fill];
//	
//	
//	// main white area
//	NSRect whiteFrame = NSMakeRect(1, 2, [self bounds].size.width-2.0, [self bounds].size.height-4.0);
//	[[NSColor whiteColor] set];
//	[[NSBezierPath bezierPathWithRoundedRect:whiteFrame xRadius:2.6 yRadius:2.6] fill];
	
    // I don't like that the point to draw at is hard-coded, but it works for now
    //[self.attributedString drawInRect:NSMakeRect(0.0, 0.0, [self bounds].size.width, [self bounds].size.width)];
    [[NSColor lightGrayColor] set];
    NSBezierPath *bottomBorderPath = [NSBezierPath bezierPath];
    [bottomBorderPath setLineWidth:8.0];
    [bottomBorderPath moveToPoint:CGPointMake(4, 0)];
    [bottomBorderPath lineToPoint:CGPointMake(4, self.bounds.size.height)];
    
    [bottomBorderPath closePath];
    [bottomBorderPath stroke];

    

}

@end
