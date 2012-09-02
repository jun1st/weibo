//
//  HomeTimeLineController.h
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineController.h"

@interface HomeTimelineController : TimelineController<NSTableViewDataSource, NSTableViewDelegate, TimeLineControllerDelegate>

-(id)init;

@end
