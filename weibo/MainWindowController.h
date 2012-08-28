//
//  MainWindowController.h
//  weibo
//
//  Created by feng qijun on 8/11/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WBRequest.h"
#import "WBEngine.h"
#import "WBMessageTableCellView.h"
#import "EQSTRScrollView.h"

@interface MainWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, strong) WBEngine *engine;
@property (weak) IBOutlet NSTableView *timelineTable;
@property (weak) IBOutlet EQSTRScrollView *scrollView;
@property (assign) IBOutlet NSImageView *authorizingUserProfileImage;


@end
