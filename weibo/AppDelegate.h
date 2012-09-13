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
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>


@property (strong) MainWindowController *mainController;
@property (strong) OAuthWindowController *oauthController;

@end
