//
//  StatusListCellView.h
//  weibo
//
//  Created by feng qijun on 9/7/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"

@interface StatusListCellView : PXListViewCell
{
    NSTextView *statusTextView;
}
@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSImageView *userProfileImage;

@property IBOutlet NSTextView *statusTextView;

@end
