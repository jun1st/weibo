//
//  UserDetailViewController.h
//  weibo
//
//  Created by feng qijun on 10/7/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "M3NavigationViewControllerProtocol.h"

@class HomeTimelineController;

@interface UserDetailViewController : NSViewController<M3NavigationViewControllerProtocol>

@property (assign) HomeTimelineController *homeViewController;

@end
