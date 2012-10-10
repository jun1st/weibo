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
#import "TitleBarView.h"

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

#define POPUP_VIEW_CONTROLLER_NOTIFICATION @"PopupViewControllerNotification"

@interface MainWindowController ()

@property(readonly, strong) WBUser *authorizingUser;
@property(strong) INPopoverController *popoverController;
@property(strong, readonly) HomeTimelineController *homeViewController;

@end

@implementation MainWindowController

@synthesize authorizingUser = _authorizingUser;
@synthesize homeViewController = _homeViewController;

-(HomeTimelineController *)homeViewController
{
    if (!_homeViewController) {
        _homeViewController = [[HomeTimelineController alloc] init];
        _homeViewController.rootViewController = self;
    }
    
    return _homeViewController;
}

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popViewController)
                                                     name:POPUP_VIEW_CONTROLLER_NOTIFICATION object:nil];
        
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

-(void)awakeFromNib
{
    INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
    aWindow.titleBarHeight = 40.0;
	aWindow.trafficLightButtonsLeftMargin = 13.0;
    
    [aWindow.titleBarView addSubview:self.titleBar];
    
    self.titleBar.hostWindowController = self;
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    [self.homeNavView setViewController:self.homeViewController];
    
    if ([self.homeNavView.viewStack count] <= 1) {
        [self.titleBar setBackButtonHidden:YES];
    }
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

-(void)pushViewController:(NSViewController<M3NavigationViewControllerProtocol> *)viewController
{
    [self.homeNavView pushViewController:viewController];
    if ([self.homeNavView.viewStack count] > 1) {
        [self.titleBar setBackButtonHidden:NO];
    }
}

-(void)popViewController
{
    [self.homeNavView popViewController];
    if ([self.homeNavView.viewStack count] <= 1) {
        [self.titleBar setBackButtonHidden:YES];
    }
}

@end
