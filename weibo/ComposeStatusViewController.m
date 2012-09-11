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

@interface ComposeStatusViewController ()

@property(nonatomic, strong, readonly)WBEngine *engine;

@end

@implementation ComposeStatusViewController
@synthesize statusTextView;
@synthesize engine = _engine;

-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] init];
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

-(IBAction)cancelComposing:(id)sender
{
    [self.parentPopoverController closePopover:nil];
}

-(IBAction)postNewStatus:(NSButton *)button
{
    [self.engine sendWeiBoWithText:self.statusTextView.string image:nil];
}

@end
