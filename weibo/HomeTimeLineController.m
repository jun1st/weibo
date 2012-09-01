//
//  HomeTimeLineController.m
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "HomeTimeLineController.h"
#import "WBMessageTableCellView.h"
#import "Status+CoreData.h"
#import "User+ProfileImage.h"
#import "ImageDownloader.h"
#import "WBEngine.h"
#import "WBManagedObjectContext.h"

@interface HomeTimeLineController()<WBEngineDelegate, ImageDownloading>

@property(nonatomic, strong) WBEngine *engine;
@property (nonatomic)NSMutableArray *timeline;
@property(strong, readonly, nonatomic) NSDateFormatter *utcDateFormatter;
@property(readonly, nonatomic) NSRegularExpression *userRegularExpression;
@property(readonly, nonatomic) NSRegularExpression *urlRegularExpression;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation HomeTimeLineController

@synthesize timelineTable = _timelineTable;
@synthesize engine = _engine;
@synthesize timeline = _timeline;
@synthesize utcDateFormatter = _utcDateFormatter;
@synthesize userRegularExpression = _userRegularExpression;
@synthesize urlRegularExpression = _urlRegularExpression;

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

-(NSMutableArray *)timeline
{
    if (!_timeline) {
        _timeline = [[NSMutableArray alloc] init];
        [self refreshTimeline];
    }
    
    return _timeline;
}

-(NSTimeZone *)localTimeZone
{
    return [NSTimeZone localTimeZone];
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

-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] init];
        _engine.delegate = self;
    }
    
    return _engine;
}

-(void)refreshTimeline
{
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
        
        [self statusArrayFromDatabase];
        
    }
}

-(void)statusArrayFromDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    request.fetchLimit = 20;
    
    NSError *error;
    [self.timeline removeAllObjects];
    self.timeline = [[[WBManagedObjectContext sharedInstance].managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    [self.timelineTable reloadData];
}

#pragma tableview datasource methods
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.timeline count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    WBMessageTableCellView *result = [tableView makeViewWithIdentifier:@"wbCell" owner:self];
    
    Status *status = (Status *)[self.timeline objectAtIndex:row];
    
    result.authName.stringValue = status.userScreenName;
    
    NSTimeInterval intervalSince1970 = [status.createdAt timeIntervalSince1970];
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
    NSDateFormatter *relativeFormatter = [[NSDateFormatter alloc] init];
    relativeFormatter.timeZone = [self localTimeZone];
    relativeFormatter.dateFormat = @"H:mm";
    
    result.createdTime.stringValue = [relativeFormatter stringFromDate:localDate];
    
    
    if ([status.author profileImage]) {
        result.userProfileImageView.image = [status.author profileImage];
    }else{
        [self startUserProfileImageDownload:status.author forRow:row];
    }
    
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:status.text];
    
    
    [rString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range: NSMakeRange(0, rString.length)];
    
    //match user names
    NSArray *matches = [self.userRegularExpression matchesInString:status.text
                                                           options:0
                                                             range:NSMakeRange(0, [status.text length])];
    for(NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSFont *font = [NSFont userFontOfSize:13];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:13];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    //match urls
    NSArray *urlMatches = [self.urlRegularExpression matchesInString:status.text options:0 range:NSMakeRange(0, status.text.length)];
    for (NSTextCheckingResult  *match in urlMatches) {
        NSRange matchRange = [match range];
        NSString *subString = [status.text substringWithRange:matchRange];
        
        [rString addAttribute:NSLinkAttributeName value:subString range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:matchRange];
        [rString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:matchRange];
    }
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:4.0];
    [rString addAttribute:NSParagraphStyleAttributeName value:myStyle range:NSMakeRange(0, status.text.length)];
    
    
    [result.statusTextView.textStorage setAttributedString:rString];
    
    //    if (row + 1 == [self.timeline count]) {
    //        [self prefetchingData];
    //    }
    
    return result;

}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *text = ((Status *)[self.timeline objectAtIndex:row]).text;
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:text];
    [rString addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range: NSMakeRange(0, rString.length)];
    
    float rows = ceilf(rString.size.width / 360.0f);
    return (rString.size.height + 3 ) * rows + 30 > 68 ? (rString.size.height + 3) * rows + 30 : 68;
}


-(void)startUserProfileImageDownload:(User *)user forRow:(NSInteger)row
{
    ImageDownloader *downloader = [self.imageDownloadsInProgress objectForKey:user.idstr];
    
    if (downloader == nil)
    {
        downloader = [[ImageDownloader alloc] init];
        downloader.user = user;
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];
        //[downloader addCellPathToUpdate:indexPath];
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
            
            WBMessageTableCellView *cellView = [result viewAtColumn:0];
            
            cellView.userProfileImageView.image = user.profileImage;
        }
    }
}

#pragma TimeLineControllerDelegate
-(void)refreshTimeLine
{
    
}

@end
