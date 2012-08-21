//
//  WBMessageScrollView.m
//  weibo
//
//  Created by feng qijun on 8/21/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBMessageScrollView.h"

@implementation WBMessageScrollView

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
    // Drawing code here.
}

-(void)scrollWheel:(NSEvent *)theEvent
{
    [[self nextResponder] scrollWheel:theEvent];
}

@end
