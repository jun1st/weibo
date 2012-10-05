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
#import "M3NavigationViewControllerProtocol.h"
#import "M3NavigationView.h"

@interface HomeTimelineController : TimelineController<PXListViewDelegate, TimeLineControllerDelegate,
    ImageDownloading, M3NavigationViewControllerProtocol>

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;


-(id)init;
-(void)startUserProfileImageDownload:(User *)user forRow:(NSUInteger)row;

@end
