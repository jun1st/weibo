//
//  ReplyStatusViewController.m
//  weibo
//
//  Created by feng qijun on 10/4/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "ReplyStatusViewController.h"
#import "WBEngine.h"
#import <Growl/Growl.h>

@interface ReplyStatusViewController ()<WBEngineDelegate>
    @property(strong, readonly)WBEngine *engine;
@end

@implementation ReplyStatusViewController

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
        self = [self initWithNibName:@"ReplyStatusViewController" bundle:nil];
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

- (IBAction)cancelComment:(id)sender
{
    [self.parentPopoverController closePopover:nil];
}

- (IBAction)postComment:(id)sender
{
    [self.engine postComment:self.commentTextView.string toStatusWithId:self.statusId];
}

#pragma WBEngine delegate methods
-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [self.parentPopoverController closePopover:nil];
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
