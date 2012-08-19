//
//  NSRoundedImageView.m
//  weibo
//
//  Created by feng qijun on 8/19/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "NSRoundedImageView.h"

@implementation NSRoundedImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    CALayer *roundedLayer = [self layer];
    [self setWantsLayer:YES];
    
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 5.0;
    roundedLayer.borderWidth = 1.0;
    roundedLayer.borderColor = [[NSColor grayColor] CGColor];
    
}

@end
