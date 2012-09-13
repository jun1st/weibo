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
#import "NSDate+RelativeToNow.h"

#define LISTVIEW_CELL_IDENTIFIER		@"StatusListCellView"

@interface HomeTimelineController()<WBEngineDelegate>

@property (nonatomic)NSMutableArray *timeline;

@property (assign) EQSTRScrollView *parentScrollView;

@end

@implementation HomeTimelineController

@synthesize timeline = _timeline;

-(id)init
{
    self = [super init];
    if (self) {
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
    
    [self.engine loadRequestWithMethodName:@"statuses/home_timeline.json"
                           httpMethod:@"GET"
                               params:nil
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
    NSArray *status = [Status statusesFromContext:[WBManagedObjectContext sharedInstance].managedObjectContext
                                       withOffSet:self.timeline.count];
    
    [self.timeline removeAllObjects];
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
    
    NSAttributedString *textRString = [self attributedStringFromString:status.text];
    status.attributedText = textRString;
    CGFloat height = [textRString heightForWidth:376.0f];
    
    return height + 52 > 82 ? height + 52 : 82;

}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row
{
    StatusListCellView *cell = (StatusListCellView*)[aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];

	if(!cell) {
		cell = [StatusListCellView cellLoadedFromNibNamed:@"StatusListCellView"
                                       reusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
	}
    
    Status *status = ((Status *)[self.timeline objectAtIndex:row]);
    
    cell.userName.stringValue = status.userScreenName;
    cell.relativeTime.stringValue = [status.createdAt stringWithShortFormatToNow];
    
    if (status.author.profileImage) {
        cell.userProfileImage.image = status.author.profileImage;
    }else
    {
        [self startUserProfileImageDownload:status.author forRow:row];
    }
    
    CGFloat height = [status.attributedText heightForWidth:376.0f];

    NSRect rect;
    if (height >= 34) {
        rect = NSMakeRect(58.0f, 31.0f - (height - 31.0f), 376.0f, height);
    }
    else{
        rect = NSMakeRect(58.0f, 21.0f, 376.0f, 30);
    }
    [cell.statusTextView setFrame:rect];
    
    [cell.statusTextView.textStorage setAttributedString:status.attributedText];
    
    return cell;
}

#pragma ImageDoneLoading delegate
-(void)doneLoadImageForUser:(User *)user
{
    ImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    if (iconDownloader != nil)
    {
        for (NSNumber *row in iconDownloader.rowsToUpdate) {
            
            StatusListCellView *result = (StatusListCellView *)[self.timelineListView cellForRowAtIndex:[row unsignedIntegerValue]];
            //if (result.window) {
                result.userProfileImage.image = user.profileImage;
            //}
        }
    }
}

@end
