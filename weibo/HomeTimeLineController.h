//
//  HomeTimeLineController.h
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeLineController.h"

@interface HomeTimeLineController : NSObject<NSTableViewDataSource, NSTableViewDelegate, TimeLineControllerDelegate>

-(id)init;

@property (weak) IBOutlet NSTableView *timelineTable;

@end
