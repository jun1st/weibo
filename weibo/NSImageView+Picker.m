//
//  NSImageView+Picker.m
//  weibo
//
//  Created by feng qijun on 9/12/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "NSImageView+Picker.h"

@implementation NSImageView (Picker)

-(void)mouseUp:(NSEvent *)theEvent
{
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSImage imageFileTypes]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:panel.URL];
            
            self.image = image;
        }
        
        panel = nil;
    }];
}

@end
