//
//  ComposeStatusViewController.m
//  weibo
//
//  Created by feng qijun on 9/10/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//
#import "INPopoverController.h"
#import "ComposeStatusViewController.h"
#import "WBEngine.h"
#import "NSImageView+Picker.h"
#import <Growl/Growl.h>

@interface ComposeStatusViewController ()<WBEngineDelegate>

@property(strong, readonly)WBEngine *engine;

@end

@implementation ComposeStatusViewController
@synthesize statusTextView;
@synthesize imageView;
@synthesize engine = _engine;

-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] init];
        _engine.delegate = self;
    }
    
    return _engine;
}

-(id)init
{
    self = [super init];
    if (self) {
        self = [self initWithNibName:@"ComposeStatusViewController" bundle:nil];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }

    return self;
}

-(void)awakeFromNib
{
    [self.statusTextView setTextContainerInset:NSMakeSize(4, 8)];
}

-(IBAction)cancelComposing:(id)sender
{
    [self.parentPopoverController closePopover:nil];
}

-(IBAction)postNewStatus:(NSButton *)button
{
    [self.engine sendWeiBoWithText:self.statusTextView.string image:self.imageView.image];
}


#pragma WBEngine delegate methods
-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [self.parentPopoverController closePopover:nil];
    NSLog(@"%@", error);
}
-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    [self.parentPopoverController closePopover:nil];
    [GrowlApplicationBridge notifyWithTitle:@"Weibo Sent"
                                description:@"Your weibo has been sent"
                           notificationName:@"weibo_sent"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"weibo"];
}

@end
