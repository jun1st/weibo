//
//  RepostStatusViewController.m
//  weibo
//
//  Created by feng qijun on 10/5/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "RepostStatusViewController.h"
#import "WBEngine.h"
#import <Growl/Growl.h>

@interface RepostStatusViewController ()<WBEngineDelegate>

@property(strong, readonly)WBEngine *engine;

@end

@implementation RepostStatusViewController
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
    self = [self initWithNibName:@"RepostStatusViewController" bundle:nil];
    
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

- (IBAction)cancel:(id)sender {
    [self.parentPopoverController closePopover:nil];
}

- (IBAction)sendRepost:(id)sender {
    [self.engine repostStatusWithId:self.statusIdStr withComment:self.repostCommentTextView.string];
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
                                description:@"Repost succeeded"
                           notificationName:@"weibo_sent"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"weibo"];
}

@end
