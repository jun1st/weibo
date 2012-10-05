//
//  HomeTimeLineController.m
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//
#import <Growl/Growl.h>
#import "HomeTimelineController.h"
#import "WBMessageTableCellView.h"
#import "Status+CoreData.h"
#import "User+ProfileImage.h"
#import "WBEngine.h"
#import "WBManagedObjectContext.h"
#import "EQSTRScrollView.h"
#import "WBFormatter.h"
#import "NS(Attributed)String+Geometrics.h"
#import "StatusListCellView.h"
#import "RetweetStatusListCellView.h"
#import "LoadMoreCellView.h"
#import "NSDate+RelativeToNow.h"
#import "StatusDetailViewController.h"
#import "MainWindowController.h"

#define LISTVIEW_CELL_IDENTIFIER		@"StatusListCellView"
#define LISTVIEW_RETWEET_CELL_IDENTIFIER @"RetweetStatusListCellView"
#define LISTVIEW_LOAD_MORE_CELL_IDENTIFIER @"LoadMoreCellView"

@interface HomeTimelineController()<WBEngineDelegate>

@property (nonatomic)NSMutableArray *timeline;
@property (assign) EQSTRScrollView *parentScrollView;
@property (strong) StatusDetailViewController *detailViewConroller;

@end

@implementation HomeTimelineController

@synthesize timeline = _timeline;

-(id)init
{
    self = [super initWithNibName:@"HomeTimelineView" bundle:nil];
    if (self) {
        self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.timelineListView.refreshBlock = ^(EQSTRScrollView *view){
        [self pullToRefreshInScrollView: view];
    };
    
    [self.timelineListView reloadData];
}

-(NSMutableArray *)timeline
{
    if (!_timeline) {
        _timeline = [[NSMutableArray alloc] init];
        [self statusArrayFromDatabase];
    }
    
    return _timeline;
}

-(NSTimeZone *)localTimeZone
{
    return [NSTimeZone localTimeZone];
}

-(void)pullToRefreshInScrollView:(EQSTRScrollView *)scrollView
{
    self.parentScrollView = scrollView;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:50], @"count", @"4116306678", @"source", nil];
    [self.engine loadRequestWithMethodName:@"statuses/home_timeline.json"
                           httpMethod:@"GET"
                               params:parameters
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];
}

-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        NSMutableArray *statusesArray = [dict objectForKey:@"statuses"];
        
        for (int i=0; i < statusesArray.count; i++) {
            NSDictionary *statusDict = [statusesArray objectAtIndex:i];
            
            [Status save:statusDict inContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
        }
        
        [self.parentScrollView stopLoading];
        
        [self statusArrayFromDatabase];
        
        [GrowlApplicationBridge notifyWithTitle:@"Refreshed"
                                    description:@"home timeline refreshed"
                               notificationName:@"weibo_refreshed"
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:@"weibo"];
    }
}

-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self.parentScrollView stopLoading];
}

-(void)statusArrayFromDatabase
{
    NSDate *latestStatusTime = nil;
    if (_timeline && [_timeline count] > 0 ) {
        latestStatusTime = [(Status *)[_timeline objectAtIndex:0] createdAt];
    }
    
    NSArray *status = [Status statusesFromContext:[WBManagedObjectContext sharedInstance].managedObjectContext
                                       createdFrom:latestStatusTime];
    
    //[self.timeline removeAllObjects];
    [self.timeline addObjectsFromArray:status];
    [self.timeline sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]
                                                                  initWithKey:@"createdAt" ascending:NO]]];
    [self.timelineListView reloadData];
    
}

-(NSAttributedString *)attributedStringFromString:(NSString *)text
{
    NSMutableAttributedString *rString = [[NSMutableAttributedString alloc] initWithString:text];
    
    [rString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Lucida Grande" size:13] range: NSMakeRange(0, text.length)];
    
    //match user names
    NSArray *matches = [[WBFormatter userRegularExpression] matchesInString:text
                                                                    options:0
                                                                      range:NSMakeRange(0, [text length])];
    for(NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:13];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:13];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    //match urls
    NSArray *urlMatches = [[WBFormatter urlRegularExpression] matchesInString:text
                                                                      options:0
                                                                        range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult  *match in urlMatches) {
        NSRange matchRange = [match range];
        NSString *subString = [text substringWithRange:matchRange];
        
        [rString addAttribute:NSLinkAttributeName value:subString range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:62 green:152 blue:216 alpha:0]
                        range:matchRange];
        [rString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:matchRange];
    }
    
    //match topics
    matches = [[WBFormatter topicRegularExpression] matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = match.range;        
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:matchRange];
    }
    
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:4.0];
    [rString addAttribute:NSParagraphStyleAttributeName value:myStyle range:NSMakeRange(0, text.length)];
    
    return rString;
}


#pragma PXListViewDelegate

- (NSUInteger)numberOfRowsInListView:(PXListView*)aListView
{
    return [self.timeline count];
}
- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
    Status *status = ((Status *)[self.timeline objectAtIndex:row]);
    
    if (self.timeline.count > row + 1) {
        Status *preStatus = (Status *)[self.timeline objectAtIndex:row + 1];
        
        if ([status.createdAt timeIntervalSinceDate:preStatus.createdAt] > 5 * 60) {
            return 46.0f;
        }
                             
    }
    
    NSAttributedString *textRString = [self attributedStringFromString:status.text];
    status.attributedText = textRString;
    CGFloat height = [textRString heightForWidth:376.0f];
    
    if (status.retweetText) {
        NSAttributedString *retweetAString = [self attributedStringFromString:status.retweetText];
        status.attributedRetweetText = retweetAString;
        CGFloat rHeight = [retweetAString heightForWidth:368.0f];
        
        height = height + rHeight + 8;
    }
    
    return height + 52 > 82 ? height + 52 : 82;

}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row
{
    Status *status = ((Status *)[self.timeline objectAtIndex:row]);
    
    if (self.timeline.count > row + 1) {
        Status *preStatus = (Status *)[self.timeline objectAtIndex:row + 1];
        
        if ([status.createdAt timeIntervalSinceDate:preStatus.createdAt] > 5 * 60) {
            LoadMoreCellView *loadMoreCellView = (LoadMoreCellView *)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_LOAD_MORE_CELL_IDENTIFIER];
            
            if (!loadMoreCellView) {
                loadMoreCellView = [LoadMoreCellView cellLoadedFromNibNamed:@"LoadMoreCellView" reusableIdentifier:LISTVIEW_LOAD_MORE_CELL_IDENTIFIER];
            }
            
            return  loadMoreCellView;
        }
        
    }
    StatusListCellView *cell = nil;
    RetweetStatusListCellView *retweetCell = nil;
    if (!status.retweetText) {
        
        cell = (StatusListCellView*)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        
        if(!cell) {
            cell = [StatusListCellView cellLoadedFromNibNamed:@"StatusListCellView"
                                           reusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
        }
        
        cell.userName.stringValue = status.userScreenName;
        cell.relativeTime.stringValue = [status.createdAt relativeTimeToNow];
        cell.statusId = status.idStr;

        if (status.author.profileImage) {
            cell.userProfileImage.image = status.author.profileImage;
        }else
        {
            [self startUserProfileImageDownload:status.author forRow:row];
        }
        
        CGFloat height = [status.attributedText heightForWidth:376.0f];
        
        NSRect rect;
        if (height >= 31) {
            rect = NSMakeRect(58.0f, 31.0f - (height - 31.0f), 376.0f, height);
        }
        else{
            rect = NSMakeRect(58.0f, 21.0f, 376.0f, 30);
        }
        [cell.statusTextView setFrame:rect];
        
        [cell.statusTextView.textStorage setAttributedString:status.attributedText];
        //NSLog(@"%ld", row);
        return cell;

    }
    else
    {
        retweetCell = (RetweetStatusListCellView*)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_RETWEET_CELL_IDENTIFIER];
        
        if(!retweetCell) {
            retweetCell = [RetweetStatusListCellView cellLoadedFromNibNamed:@"RetweetStatusListCellView"
                                           reusableIdentifier:LISTVIEW_RETWEET_CELL_IDENTIFIER];
        }
        
        retweetCell.userName.stringValue = status.userScreenName;
        retweetCell.relativeTime.stringValue = [status.createdAt relativeTimeToNow];
        retweetCell.statusId = status.idStr;
        if (status.author.profileImage)
        {
            retweetCell.userProfileImage.image = status.author.profileImage;
        }
        else
        {
            [self startUserProfileImageDownload: status.author forRow:row];
        }
        
        CGFloat statusHeight = [status.attributedText heightForWidth:376.0f];
        CGFloat retweetStatusHeight = [status.attributedRetweetText heightForWidth:368.0f];
        
        //CGFloat statusToMoveY = statusHeight - 28;
        
        [retweetCell.retweetTextView setFrame: NSMakeRect(58.0f, 11 - (statusHeight-28) - (retweetStatusHeight-28), 368.0f, retweetStatusHeight+4)];
        [retweetCell.statusTextView setFrame: NSMakeRect(58.0f, 49 -(statusHeight-28), 376.0f, statusHeight)];
        [retweetCell.statusTextView.textStorage setAttributedString:status.attributedText];
        [retweetCell.retweetTextView.textStorage setAttributedString:status.attributedRetweetText];
        return retweetCell;
    }
    
}

-(void)startUserProfileImageDownload:(User *)user forRow:(NSUInteger)row
{
    ImageDownloader *downloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    
    if (downloader == nil)
    {
        downloader = [[ImageDownloader alloc] init];
        downloader.user = user;
        [downloader.rowsToUpdate addObject:[NSNumber numberWithUnsignedInteger:row]];
        downloader.delegate = self;
        [self.imageDownloadsInProgress setObject:downloader forKey:user.idstr];
        [downloader startDownload];
        
    }
    else
    {
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];
        
    }
    
}

-(void)listView:(PXListView *)aListView rowDoubleClicked:(NSUInteger)rowIndex
{
    self.detailViewConroller = [[StatusDetailViewController alloc] init];
    self.detailViewConroller.homeViewController = self;
    [self.rootViewController.homeNavView pushViewController:self.detailViewConroller];
}


#pragma ImageDoneLoading delegate
-(void)doneLoadImageForUser:(User *)user
{
    ImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    if (iconDownloader != nil)
    {
        for (NSNumber *row in iconDownloader.rowsToUpdate) {
            
            id result = [self.timelineListView cellForRowAtIndex:[row unsignedIntegerValue]];
            if ([result isKindOfClass:[StatusListCellView class]]) {
                ((StatusListCellView *)result).userProfileImage.image = user.profileImage;
            }
            else if([result isKindOfClass:[RetweetStatusListCellView class]])
            {
                //result.userProfileImage.image = user.profileImage;
                ((RetweetStatusListCellView *)result).userProfileImage.image = user.profileImage;
            }
            //NSLog(@"%ld", [row integerValue]);
            //[result setNeedsDisplay:YES];
        }
    }
}

@end
