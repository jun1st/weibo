//
//  TimeLineController.h
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeLineController : NSObject

@end


@protocol TimeLineControllerDelegate

@required
-(void)refreshTimeline;

@end