//
//  MentionTableCellView.h
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MentionTableCellView : NSTableCellView
{
    IBOutlet NSTextView *statusTextView;
}

@property (weak) IBOutlet NSTextField *authName;
@property (weak) IBOutlet NSTextField *createdTime;
@property (weak) IBOutlet NSImageView *userProfileImageView;

@property NSTextView *statusTextView;

@end
