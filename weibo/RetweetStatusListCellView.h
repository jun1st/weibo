//
//  RetweetStatusListCellView.h
//  weibo
//
//  Created by feng qijun on 9/12/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "PXListViewCell.h"
#import "RoundedNSTextView.h"
#import "BasicListViewCell.h"

@interface RetweetStatusListCellView : BasicListViewCell
{
    NSTextView *statusTextView;
    RoundedNSTextView *retweetTextView;
}
@property (weak) IBOutlet NSImageView *userProfileImage;
@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSTextField *relativeTime;
@property IBOutlet NSTextView *statusTextView;
@property IBOutlet RoundedNSTextView *retweetTextView;

@end
