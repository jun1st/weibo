//
//  AppDelegate.h
//  weibo
//
//  Created by feng qijun on 8/8/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "OAuthWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (strong) MainWindowController *mainController;
@property (strong) OAuthWindowController *oauthController;

@end
