//
//  WBMessageTableCellView.h
//  weibo
//
//  Created by derek on 12-8-15.
//  Copyright (c) 2012年 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WBMessageTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *authName;
@property (weak) IBOutlet NSTextField *createdTime;

@end
