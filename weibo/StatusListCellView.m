//
//  StatusListCellView.m
//  weibo
//
//  Created by feng qijun on 9/7/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "StatusListCellView.h"
#import "INPopoverController.h"
#import "ReplyStatusViewController.h"

@interface StatusListCellView ()

@property (nonatomic, strong) NSTrackingArea *trackingArea;


@end

@implementation StatusListCellView

@synthesize  statusTextView = _statusTextView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createTrackingArea];
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
    
    
    //Draw the border and background
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
    [self.replyButton setHidden:YES];
    [self.repostButton setHidden:YES];
    CGRect oldStatusFrame = NSMakeRect(64.0f, 21.0f, 374.0f, 30.0f);
    [self.statusTextView setFrame:oldStatusFrame];
    
    CGRect oldFrame = self.frame;
    oldFrame.size.height = 82.0f;
//    
    [self setFrame:oldFrame];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    if (self.replyButton.isHidden) {
        [self.replyButton setHidden:NO];
        [self.repostButton setHidden:NO];
        [self setNeedsDisplay:YES];
    }
    
}

-(void)mouseExited:(NSEvent *)theEvent
{
    if (!self.replyButton.isHidden) {
        [self.replyButton setHidden:YES];
        [self.repostButton setHidden:YES];
        [self setNeedsDisplay:YES];
    }

}

- (void) createTrackingArea
{
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation
                              fromView: nil];
    
    if (CGRectContainsPoint([self bounds], mouseLocation))
    {
        [self mouseEntered: nil];
    }
    else
    {
        [self mouseExited: nil];
    }
}

- (void) updateTrackingAreas
{
    [self removeTrackingArea:_trackingArea];
    [self createTrackingArea];
    [super updateTrackingAreas]; // Needed, according to the NSView documentation
}

@end
