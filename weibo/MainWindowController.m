//
//  MainWindowController.m
//  weibo
//
//  Created by feng qijun on 8/11/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MainWindowController.h"
#import "EQSTRScrollView.h"
#import "INAppStoreWindow.h"
#import "ImageDownloader.h"
#import "WBUser.h"
#import "User+ProfileImage.h"
#import "WBManagedObjectContext.h"
#import "TimeLineController.h"
#import "ComposeStatusViewController.h"
#import "INPopoverController.h"

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

@interface MainWindowController ()

@property(readonly, strong) WBUser *authorizingUser;
@property(strong) INPopoverController *popoverController;

@end

@implementation MainWindowController

@synthesize authorizingUser = _authorizingUser;

-(WBUser *)authorizingUser
{
    return [WBUser authorizingUser];
}


-(id)init
{
    self = [super initWithWindowNibName:@"MainWindowController"];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(userAuthorized)
                                                     name:@"authorized" object:nil];
        
    }
    
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)windowWillLoad{
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    
    INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
    aWindow.titleBarHeight = 40.0;
	aWindow.trafficLightButtonsLeftMargin = 13.0;
    
    [aWindow.titleBarView addSubview:self.titleBar];
    
}

-(void)requestAuthorizingUserProfileImage
{
    NSString *profileUrl = [self authorizingUser].profileImageUrl;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileUrl]];
    
    NSImage *profileImage = [[NSImage alloc] initWithData:imageData];
    
    self.authorizingUserProfileImage.image = profileImage;
}

-(void)userAuthorized
{
    [[self window] makeKeyAndOrderFront:self];
}


- (IBAction)showMentionTimeline:(id)sender {
    [self.timelineTabs selectTabViewItemAtIndex:1];
}

- (IBAction)showHomeTimeline:(id)sender {
    [self.timelineTabs selectTabViewItemAtIndex:0];
}

-(IBAction)showComposeWindow:(id)sender
{
    if (self.popoverController && self.popoverController.popoverIsVisible) {
        [self.popoverController closePopover:nil];
    }
    else{
        ComposeStatusViewController *composeViewController = [[ComposeStatusViewController alloc] init];
    
        self.popoverController = [[INPopoverController alloc] initWithContentViewController:composeViewController];
        
        composeViewController.parentPopoverController = self.popoverController;
        
        //[self.composeWindowController showWindow:self];
        self.popoverController.closesWhenPopoverResignsKey = NO;
        [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
    }
}

@end
