//
//  OAuthWindowController.h
//  weibo
//
//  Created by feng qijun on 8/8/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "WBRequest.h"

@class MainWindowController;

@interface OAuthWindowController : NSWindowController

@property (weak) IBOutlet WebView *oauthView;
@property (strong) MainWindowController *mainWindow;

-(BOOL)isAuthorized;

@end
