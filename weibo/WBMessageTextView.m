//
//  WBMessageTextView.m
//  weibo
//
//  Created by feng qijun on 10/6/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBMessageTextView.h"

@implementation WBMessageTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
    NSLog(@"clicked at %ld", charIndex);
    NSLog(@"%@", link);
    
    return YES;
}
@end
