//
//  AppDelegate.m
//  weibo
//
//  Created by feng qijun on 8/8/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "AppDelegate.h"
#import "NSAttributedStringToNSDataValueTransformer.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSAttributedStringToNSDataValueTransformer class];
    
    self.mainController = [[MainWindowController alloc] init];
    
    self.oauthController = [[OAuthWindowController alloc] init];
    if (!self.oauthController.isAuthorized) {
        
        //[self.mainController.window orderOut:nil];
        
        [self.oauthController showWindow:nil];
    }else{
        [self.mainController showWindow:nil];
    }
}

@end
