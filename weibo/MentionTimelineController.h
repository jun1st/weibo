//
//  MetionTimeLineController.h
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineController.h"

@interface MentionTimelineController :
                    TimelineController<NSTableViewDataSource, NSTableViewDelegate, TimeLineControllerDelegate>


-(id)init;

@end
