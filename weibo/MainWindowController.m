//
//  MainWindowController.m
//  weibo
//
//  Created by feng qijun on 8/11/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MainWindowController.h"
#import "EQSTRScrollView.h"

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

@interface MainWindowController ()<WBEngineDelegate>

@property(strong, readonly, nonatomic) NSDateFormatter *utcDateFormatter;
@property(nonatomic, strong) NSMutableArray *timeline;
-(void)refreshTimelime;

@end

@implementation MainWindowController

@synthesize timelineTable = _timelineTable;
@synthesize utcDateFormatter = _utcDateFormatter;

-(NSDateFormatter *)utcDateFormatter
{
    if (_utcDateFormatter == nil) {
        _utcDateFormatter = [[NSDateFormatter alloc] init];
        _utcDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _utcDateFormatter.dateFormat = @"EEE MMM d HH:mm:ss ZZZ yyyy";
    }
    
    return _utcDateFormatter;
}

-(NSTimeZone *)localTimeZone
{
    return [NSTimeZone localTimeZone];
}



-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] initWithAppKey:OAuthConsumerKey appSecret:OAuthConsumerSecret];
        _engine.delegate = self;
    }
    
    return _engine;
}


-(id)init
{
    self = [super initWithWindowNibName:@"MainWindowController"];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(userAuthorized)
                                                     name:@"authorized" object:nil];
        
        _timeline = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)windowWillLoad{
    
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    
    self.scrollView.refreshBlock = ^(EQSTRScrollView *view){
        [self refreshTimelime];
    };
    
    [self refreshTimelime];
    
}

-(void)userAuthorized
{
    [[self window] makeKeyAndOrderFront:self];
}

-(void)refreshTimelime
{
    [self.timeline removeAllObjects];
    [self.engine loadRequestWithMethodName:@"statuses/home_timeline.json"
                           httpMethod:@"GET"
                               params:nil
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];}

-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        [self.timeline addObjectsFromArray:[dict objectForKey:@"statuses"]];
        [self.timelineTable reloadData];
        
        [self.scrollView stopLoading];
    }
}

#pragma NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.timeline count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    WBMessageTableCellView *result = [tableView makeViewWithIdentifier:@"wbCell" owner:self];
    
    NSDictionary *userInfo = [[self.timeline objectAtIndex:row] objectForKey:@"user"];
    
    NSString *screen_name = [userInfo objectForKey:@"screen_name"];
    result.authName.stringValue = screen_name;
    
    NSString *createdAt = [[self.timeline objectAtIndex:row] objectForKey:@"created_at"];
    
    NSDate *createdDate = [self.utcDateFormatter dateFromString:createdAt];
    NSLog(@"%@", createdAt);
    NSLog(@"%@", createdDate);
    NSTimeInterval intervalSince1970 = [createdDate timeIntervalSince1970];
    
    NSString *message = [[self.timeline objectAtIndex:row] objectForKey:@"text"];
    
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
    NSDateFormatter *relativeFormatter = [[NSDateFormatter alloc] init];
    relativeFormatter.timeZone = [self localTimeZone];
    relativeFormatter.dateFormat = @"H:mm";
    
    result.createdTime.stringValue = [relativeFormatter stringFromDate:localDate];
    
    //NSLog(@"%@", result.createdTime.stringValue);
//    NSRect rect = result.textField.frame;
//    NSTextStorage *textStorage = [[NSTextStorage alloc]
//                                   initWithString:message];
//    NSTextContainer *textContainer = [[NSTextContainer alloc]
//                                       initWithContainerSize: NSMakeSize(400, 1000.0)];
//    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//    
//    [layoutManager addTextContainer:textContainer];
//    [textStorage addLayoutManager:layoutManager];
//    
//    [textStorage addAttribute:NSFontAttributeName
//                        value:[NSFont userFontOfSize:13]
//                        range:NSMakeRange(0, [textStorage length])];
//    [textContainer setLineFragmentPadding:0.0];
//    
//    (void) [layoutManager glyphRangeForTextContainer:textContainer];
//    NSRect rct = [layoutManager usedRectForTextContainer:textContainer];

    NSMutableAttributedString *rString =
        [[NSMutableAttributedString alloc] initWithString:message];
    
    [result.textField setAttributedStringValue:rString];
    //[result.textField setStringValue:message];
    //result.textField.frame = CGRectMake(rect.origin.x, rect.origin.y, rct.size.width, rct.size.height);
    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *message = [[self.timeline objectAtIndex:row] objectForKey:@"text"];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc]
                                  initWithString:message];
    NSTextContainer *textContainer = [[NSTextContainer alloc]
                                      initWithContainerSize: NSMakeSize(360, 1000.0)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    [textStorage addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    (void) [layoutManager glyphRangeForTextContainer:textContainer];
    NSRect rct = [layoutManager usedRectForTextContainer:textContainer];
    
    return rct.size.height + 60 > 68 ? rct.size.height + 60 : 68;
}

@end
