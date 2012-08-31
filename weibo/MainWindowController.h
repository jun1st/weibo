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
#import "MetionTimeLineController.h"

@interface MainWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, strong) WBEngine *engine;
@property (weak) IBOutlet NSTableView *timelineTable;
@property (weak) IBOutlet EQSTRScrollView *scrollView;
@property (weak) IBOutlet NSImageView *authorizingUserProfileImage;
@property (weak) IBOutlet NSTabView *timelineTabs;

@property (strong) IBOutlet MetionTimeLineController *mentionTimeLineController;
- (IBAction)showAtMeStatus:(id)sender;
- (IBAction)showHomeTimeLine:(id)sender;

@end
