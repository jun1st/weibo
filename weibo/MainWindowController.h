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
#import "PXListView.h"

@class  TitleBarView;

@interface MainWindowController : NSWindowController

@property (weak) IBOutlet EQSTRScrollView *mentionsTimeLineScrollView;
@property (weak) IBOutlet NSImageView *authorizingUserProfileImage;
@property (weak) IBOutlet NSTabView *timelineTabs;

@property (assign) IBOutlet TitleBarView *titleBar;

@property (strong) IBOutlet MentionTimelineController *mentionTimeLineController;

@property (weak) IBOutlet PXListView *homeTimelineList;

@property (nonatomic, weak) IBOutlet M3NavigationView *homeNavView;

- (IBAction)showMentionTimeline:(id)sender;
- (IBAction)showHomeTimeline:(id)sender;

-(IBAction)showComposeWindow:(id)sender;

-(void)pushViewController:(NSViewController<M3NavigationViewControllerProtocol> *)viewController;

//pop the current view controller out of stack
-(IBAction)popViewController;

@end
