//
//  WBMessageTextView.h
//  weibo
//
//  Created by feng qijun on 8/21/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WBMessageTextView : NSTextView

-(void)setText:(NSString *)text withRetweetText:(NSString *)retweetText;

@end
