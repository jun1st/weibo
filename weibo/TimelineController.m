//
//  TimeLineController.m
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "TimelineController.h"
#import "WBEngine.h"
#import "User.h"
#import "User+ProfileImage.h"
#import "TimelineCellView.h"

@interface TimelineController()

@end

@implementation TimelineController

@synthesize engine = _engine;
@synthesize utcDateFormatter = _utcDateFormatter;
@synthesize userRegularExpression = _userRegularExpression;
@synthesize urlRegularExpression = _urlRegularExpression;

-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] init];
        _engine.delegate = self;
    }
    
    return _engine;
}

-(NSRegularExpression *)userRegularExpression
{
    if (!_userRegularExpression) {
        _userRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"@[\\w-]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    }
    
    return _userRegularExpression;
}

-(NSRegularExpression *)urlRegularExpression
{
    if (!_urlRegularExpression) {
        _urlRegularExpression =
        [NSRegularExpression regularExpressionWithPattern:@"(http://|https://)([a-zA-Z0-9]+\\.[a-zA-Z0-9\\-]+|[a-zA-Z0-9\\-]+)\\.[a-zA-Z\\.]{2,6}(/[a-zA-Z0-9\\.\\?=/#%&\\+-]+|/|)"
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
    }
    
    return _urlRegularExpression;
}


-(void)startUserProfileImageDownload:(User *)user forRow:(NSInteger)row
{
    ImageDownloader *downloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    
    if (downloader == nil)
    {
        downloader = [[ImageDownloader alloc] init];
        downloader.user = user;
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];
        downloader.delegate = self;
        [self.imageDownloadsInProgress setObject:downloader forKey:user.idstr];
        [downloader startDownload];
        
    }
    else
    {
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];
        
    }
    
}

#pragma ImageDoneLoading delegate
-(void)doneLoadImageForUser:(User *)user
{
    ImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    if (iconDownloader != nil)
    {
        for (NSNumber *row in iconDownloader.rowsToUpdate) {
            
            NSTableRowView *result = [self.timelineTable rowViewAtRow:[row integerValue] makeIfNecessary:NO];
            
            TimelineCellView *cellView = [result viewAtColumn:0];
            
            cellView.userProfileImageView.image = user.profileImage;
        }
    }
}

@end
