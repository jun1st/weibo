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
#import "HomeTimelineController.h"
#import "MentionTimelineController.h"
#import "ANSegmentedControl/ANSegmentedControl.h"

@interface MainWindowController : NSWindowController


@property (weak) IBOutlet EQSTRScrollView *homeTimeLineScrollView;
@property (weak) IBOutlet EQSTRScrollView *mentionsTimeLineScrollView;
@property (weak) IBOutlet NSImageView *authorizingUserProfileImage;
@property (weak) IBOutlet NSTabView *timelineTabs;

@property (strong) IBOutlet HomeTimelineController *homeTimeLineController;
@property (strong) IBOutlet MentionTimelineController *mentionTimeLineController;
@property (assign) IBOutlet NSView *titleBar;
@property (assign) IBOutlet ANSegmentedControl *anSegmentedControl;

- (IBAction)showAtMeStatus:(id)sender;
- (IBAction)showHomeTimeLine:(id)sender;

@end
