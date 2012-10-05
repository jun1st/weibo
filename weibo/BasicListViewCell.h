//
//  BasicListViewCell.h
//  weibo
//
//  Created by feng qijun on 10/5/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "PXListViewCell.h"

@interface BasicListViewCell : PXListViewCell

@property (strong)NSString *statusId;
@property (weak) IBOutlet NSButton *replyButton;
@property (weak) IBOutlet NSButton *repostButton;

- (IBAction)showReplyDialog:(id)sender;
- (IBAction)repostWithComment:(id)sender;
@end
