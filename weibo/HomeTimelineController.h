//
//  HomeTimeLineController.h
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineController.h"
#import "PXListView.h"

@interface HomeTimelineController : TimelineController<PXListViewDelegate, TimeLineControllerDelegate, ImageDownloading>

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

-(id)init;
-(void)startUserProfileImageDownload:(User *)user forRow:(NSUInteger)row;

@end
