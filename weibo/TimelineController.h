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

@class EQSTRScrollView;

@protocol TimeLineControllerDelegate

@required
-(void)pullToRefreshInScrollView:(EQSTRScrollView *)scrollView;

@end



@interface TimelineController : NSObject<WBEngineDelegate,ImageDownloading>
{

}

@property (nonatomic, weak) IBOutlet NSTableView *timelineTable;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) WBEngine *engine;

-(void)startUserProfileImageDownload:(User *)user forRow:(NSInteger)row;

@end
