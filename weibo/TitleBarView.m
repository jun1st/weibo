//
//  TitleBarView.m
//  weibo
//
//  Created by derek on 9/3/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "TitleBarView.h"

@implementation TitleBarView

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
    
}

- (IBAction)showComposeDialog:(id)sender {
    [self.hostWindowController showComposeWindow:sender];
}

- (IBAction)back:(id)sender {
    [self.hostWindowController popViewController];
}

-(void)setBackButtonHidden:(BOOL)hidden
{
    [self.backButton setHidden:hidden];
}

@end
