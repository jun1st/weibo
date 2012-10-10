//
//  TimeLineController.h
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBEngine.h"
#import "ImageDownloader.h"
#import "PXListView.h"

@class EQSTRScrollView;
@class MainWindowController;

#pragma TimeLineController needs to responds to scroll view pull down
@protocol TimeLineControllerDelegate

@required
-(void)pullToRefreshInScrollView:(EQSTRScrollView *)scrollView;

@end



@interface TimelineController : NSViewController<WBEngineDelegate>
{

}

@property (nonatomic, assign) MainWindowController *rootViewController;
@property (nonatomic, weak) IBOutlet PXListView* timelineListView;

@property (nonatomic, strong) WBEngine *engine;

@property (strong, readonly, nonatomic) NSDateFormatter *utcDateFormatter;
@property (strong, readonly, nonatomic) NSRegularExpression *userRegularExpression;
@property (strong, readonly, nonatomic) NSRegularExpression *urlRegularExpression;



@end
