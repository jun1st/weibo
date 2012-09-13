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
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    self.mainController = [[MainWindowController alloc] init];
    
    self.oauthController = [[OAuthWindowController alloc] init];
    if (!self.oauthController.isAuthorized) {
        
        //[self.mainController.window orderOut:nil];
        
        [self.oauthController showWindow:nil];
    }else{
        [self.mainController showWindow:nil];
    }
}

-(NSDictionary *)registrationDictionaryForGrowl{
    NSArray *notifications;
    notifications = [NSArray arrayWithObjects: @"weibo_sent", @"weibo_refreshed", nil];
    
    NSDictionary *dict;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            notifications, GROWL_NOTIFICATIONS_ALL,
            notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    
    return (dict);
}

@end
