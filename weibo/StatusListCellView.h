//
//  StatusListCellView.h
//  weibo
//
//  Created by feng qijun on 9/7/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"
#import "BasicListViewCell.h"

@interface StatusListCellView : BasicListViewCell
{
    NSTextView *statusTextView;
}
@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSImageView *userProfileImage;
@property (weak) IBOutlet NSTextField *relativeTime;
@property IBOutlet NSTextView *statusTextView;





@end
