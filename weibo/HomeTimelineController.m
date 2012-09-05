//
//  HomeTimeLineController.m
//  weibo
//
//  Created by feng qijun on 9/1/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "HomeTimelineController.h"
#import "WBMessageTableCellView.h"
#import "Status+CoreData.h"
#import "User+ProfileImage.h"
#import "WBEngine.h"
#import "WBManagedObjectContext.h"
#import "EQSTRScrollView.h"
#import "WBFormatter.h"
#import "NS(Attributed)String+Geometrics.h"

@interface HomeTimelineController()<WBEngineDelegate>

@property (nonatomic)NSMutableArray *timeline;

@property (assign) EQSTRScrollView *parentScrollView;

@end

@implementation HomeTimelineController

@synthesize timelineTable = _timelineTable;
@synthesize timeline = _timeline;

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
        
        [self statusArrayFromDatabase];
        
        [self.parentScrollView stopLoading];
    }
}

-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self.parentScrollView stopLoading];
}

-(void)statusArrayFromDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    request.fetchLimit = 20;
    
    NSError *error;
    
    [self.timeline addObjectsFromArray:[[WBManagedObjectContext sharedInstance].managedObjectContext executeFetchRequest:request error:&error]];
    [self.timeline sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]
                                                                  initWithKey:@"createdAt" ascending:NO]]];
    
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
    
    if (status.retweetText) {
        NSLog(@"%ld", row);
        result.retweetTextView.string = status.retweetText;
    }
    else{
        [result.retweetTextView setHidden:YES];
//        CGPoint origin = result.retweetTextView.frame.origin;
//        NSRect rect = NSMakeRect(origin.x, origin.y, 355.0f, 0.0f);
//        [result.retweetTextView setFrame:rect];
    }
        
    [result.statusTextView.textStorage setAttributedString:status.attributedText];
    
    //    if (row + 1 == [self.timeline count]) {
    //        [self prefetchingData];
    //    }
    
    return result;

}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    Status *status = ((Status *)[self.timeline objectAtIndex:row]);
    
    NSAttributedString *textRString = [self attributedStringFromString:status.text];
    status.attributedText = textRString;
    CGFloat height = [textRString heightForWidth:380.0f];
//    NSLog(@"%f", height);
//    if (height <= 30) {
//        height = 30;
//    }
//    NSAttributedString *retweetTextRString = nil;
//    if (status.retweetText) {
//        
//        retweetTextRString = [self attributedStringFromString:status.retweetText];
//        status.attributedRetweetText = retweetTextRString;
//        CGFloat retweetHeight = [retweetTextRString heightForWidth:355.0f];
//        NSLog(@"%f", retweetHeight);
//        height += retweetHeight;
//    }
    //NSLog(@"%f", height);
    return height + 30 > 68 ? height + 30 : 68;
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
        NSFont *font = [NSFont userFontOfSize:13];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:13];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    //match urls
    NSArray *urlMatches = [[WBFormatter urlRegularExpression] matchesInString:text options:0 range:NSMakeRange(0, text.length)];
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


@end
