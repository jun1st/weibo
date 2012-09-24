//
//  StatusDetailViewController.h
//  weibo
//
//  Created by feng qijun on 9/24/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "M3NavigationViewControllerProtocol.h"
#import "HomeTimelineController.h"

@interface StatusDetailViewController : NSViewController<M3NavigationViewControllerProtocol>

@property (assign) HomeTimelineController *homeViewController;

- (IBAction)popup:(id)sender;
@end
