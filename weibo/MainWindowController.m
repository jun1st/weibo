//
//  MainWindowController.m
//  weibo
//
//  Created by feng qijun on 8/11/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MainWindowController.h"
#import "EQSTRScrollView.h"
#import "INAppStoreWindow.h"
#import "WBUser.h"
#import "WBUser+ProfileImage.h"
#import "ImageDownloader.h"

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

@interface MainWindowController ()<WBEngineDelegate, ImageDownloading>

@property(strong, readonly, nonatomic) NSDateFormatter *utcDateFormatter;
@property(nonatomic, strong) NSMutableArray *timeline;
@property(readonly, nonatomic) NSRegularExpression *userRegularExpression;
@property(readonly, strong) WBUser *authorizingUser;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

-(void)refreshTimelime;

@end

@implementation MainWindowController

@synthesize timelineTable = _timelineTable;
@synthesize utcDateFormatter = _utcDateFormatter;
@synthesize userRegularExpression = _userRegularExpression;
@synthesize authorizingUser = _authorizingUser;

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

-(NSRegularExpression *)userRegularExpression
{
    if (!_userRegularExpression) {
        _userRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"@[\\w-]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    }
    
    return _userRegularExpression;
}

-(WBEngine *)engine
{
    if (!_engine) {
        _engine = [[WBEngine alloc] initWithAppKey:OAuthConsumerKey appSecret:OAuthConsumerSecret];
        _engine.delegate = self;
    }
    
    return _engine;
}

-(WBUser *)authorizingUser
{
    return [WBUser authorizingUser];
}

-(NSMutableDictionary *)imageDownloadsInProgress
{
    if (!_imageDownloadsInProgress) {
        _imageDownloadsInProgress = [NSMutableDictionary dictionary];
    }
    
    return _imageDownloadsInProgress;
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
    //[((INAppStoreWindow *)self.window) setTitleBarHeight:40.0];
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    
    INAppStoreWindow *aWindow = (INAppStoreWindow*)[self window];
    aWindow.titleBarHeight = 40.0;
	aWindow.trafficLightButtonsLeftMargin = 13.0;
    
    aWindow.title = @"Weibo Timeline";
    
    self.scrollView.refreshBlock = ^(EQSTRScrollView *view){
        [self refreshTimelime];
    };
    [self requestAuthorizingUserProfileImage];
    [self refreshTimelime];
    
}

-(void)requestAuthorizingUserProfileImage
{
    NSString *profileUrl = [self authorizingUser].profileImageUrl;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileUrl]];
    
    NSImage *profileImage = [[NSImage alloc] initWithData:imageData];
    
    self.authorizingUserProfileImage.image = profileImage;
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

- (NSString *)populateText:(NSInteger)row
{
    NSString *text = [[self.timeline objectAtIndex:row] objectForKey:@"text"];
    
    NSDictionary *retweetStatus = [[self.timeline objectAtIndex:row] objectForKey:@"retweeted_status"];
    if (retweetStatus) {
        NSString *retweetText = [retweetStatus objectForKey:@"text"];
        if (retweetText && retweetText.length > 0) {
            text = [text stringByAppendingFormat:@"%@%@", @"//", retweetText];
        }
    }
    return text;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    WBMessageTableCellView *result = [tableView makeViewWithIdentifier:@"wbCell" owner:self];
    
    NSDictionary *userInfo = [[self.timeline objectAtIndex:row] objectForKey:@"user"];
    
    NSString *screen_name = [userInfo objectForKey:@"screen_name"];
    result.authName.stringValue = screen_name;
    
    NSString *createdAt = [[self.timeline objectAtIndex:row] objectForKey:@"created_at"];
    NSDate *createdDate = [self.utcDateFormatter dateFromString:createdAt];
    NSTimeInterval intervalSince1970 = [createdDate timeIntervalSince1970];
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
    NSDateFormatter *relativeFormatter = [[NSDateFormatter alloc] init];
    relativeFormatter.timeZone = [self localTimeZone];
    relativeFormatter.dateFormat = @"H:mm";
    
    result.createdTime.stringValue = [relativeFormatter stringFromDate:localDate];
    
    WBUser *user = [[WBUser alloc] initWithUserId:[userInfo objectForKey:@"idstr"]
                                       accessToken:[WBAuthorize sharedInstance].accessToken];
    user.profileImageUrl = [userInfo objectForKey:@"profile_image_url"];
    if (user.profileImage) {
        result.userProfileImageView.image = user.profileImage;
    }else{
        [self startUserProfileImageDownload:user forRow:row];
    }
    
    NSString *text;
    text = [self populateText:row];

    NSMutableAttributedString *rString =
        [[NSMutableAttributedString alloc] initWithString:text];
    [rString addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range: NSMakeRange(0, rString.length)];
    
    NSArray *matches = [self.userRegularExpression matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0, [text length])];
    for(NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSFont *font = [NSFont userFontOfSize:12];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:12];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    [result.textField setAttributedStringValue:rString];

    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *text = [self populateText:row];
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:text];
    [rString addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range: NSMakeRange(0, rString.length)];
    
    float rows = ceilf(rString.size.width / 360.0f);
    return rString.size.height * rows + 40 > 68 ? rString.size.height * rows + 40 : 68;
}


-(void)startUserProfileImageDownload:(WBUser *)user forRow:(NSInteger)row
{
    ImageDownloader *downloader = [self.imageDownloadsInProgress objectForKey:user.userId];
    
    if (downloader == nil)
    {
        NSLog(@"profile image downloader for user with id: %@ ", user.userId);
        downloader = [[ImageDownloader alloc] init];
        downloader.user = user;
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];
        //[downloader addCellPathToUpdate:indexPath];
        downloader.delegate = self;
        [self.imageDownloadsInProgress setObject:downloader forKey:user.userId];
        [downloader startDownload];
        
    }
    else
    {
        [downloader.rowsToUpdate addObject:[NSNumber numberWithInteger:row]];

    }
    
}

#pragma ImageDoneLoading delegate
-(void)doneLoadImageForUser:(WBUser *)user
{
    ImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:user.userId];
    if (iconDownloader != nil)
    {
        for (NSNumber *row in iconDownloader.rowsToUpdate) {
            
            NSTableRowView *result = [self.timelineTable rowViewAtRow:[row integerValue] makeIfNecessary:NO];
            
            WBMessageTableCellView *cellView = [result viewAtColumn:0];
            
            cellView.userProfileImageView.image = user.profileImage;
        }
    }
}

@end
