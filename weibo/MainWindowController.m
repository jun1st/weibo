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
#import "WBMessageTextView.h"
#import "Status.h"

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

@interface MainWindowController ()<WBEngineDelegate, ImageDownloading>

@property(strong, readonly, nonatomic) NSDateFormatter *utcDateFormatter;
@property(nonatomic, strong) NSMutableArray *timeline;
@property(readonly, nonatomic) NSRegularExpression *userRegularExpression;
@property(readonly, nonatomic) NSRegularExpression *urlRegularExpression;
@property(readonly, strong) WBUser *authorizingUser;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@property(strong, readonly) NSManagedObjectModel *managedObjectModel;
@property(strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)refreshTimelime;

@end

@implementation MainWindowController

@synthesize timelineTable = _timelineTable;
@synthesize utcDateFormatter = _utcDateFormatter;
@synthesize userRegularExpression = _userRegularExpression;
@synthesize urlRegularExpression = _urlRegularExpression;
@synthesize authorizingUser = _authorizingUser;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
//    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
//                                               stringByAppendingPathComponent: @"Core_Data.sqlite"]];
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *availableURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    
    if (availableURLs.count > 0) {
        appSupportDir = [availableURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *appBundleId = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleId];
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [appDirectory.absoluteString
                                            stringByAppendingPathComponent: @"wbmessages.sqlite"]];
    
    if (![sharedFM fileExistsAtPath:storeUrl.absoluteString]) {
        NSError *error;
        [sharedFM createDirectoryAtPath:storeUrl.absoluteString
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should
         not use this function in a shipping application, although it may be useful during
         development. If it is not possible to recover from the error, display an alert panel that
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
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
    
    //[self statusArrayFromDatabase];
    
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

//complete load data from Sina
-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        NSMutableArray *statusesArray = [dict objectForKey:@"statuses"];
        
        for (int i=0; i < statusesArray.count; i++) {
            NSDictionary *statusDict = [statusesArray objectAtIndex:i];
            Status *status = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
            
            status.id = [statusDict objectForKey:@"idstr"];
            NSDictionary *userInfo = [statusDict objectForKey:@"user"];
            NSString *screen_name = [userInfo objectForKey:@"screen_name"];
            status.userScreenName = screen_name;
            status.userIdStr = [userInfo objectForKey:@"idstr"];
            status.profileImageUrl = [userInfo objectForKey:@"profile_image_url"];
            NSString *createdAt = [statusDict objectForKey:@"created_at"];
            NSDate *createdDate = [self.utcDateFormatter dateFromString:createdAt];
            
            status.createdAt = createdDate;
            
            NSString *text = [statusDict objectForKey:@"text"];            
            NSDictionary *retweetStatus = [statusDict objectForKey:@"retweeted_status"];
            if (retweetStatus) {
                NSString *retweetText = [retweetStatus objectForKey:@"text"];
                if (retweetText && retweetText.length > 0) {
                    text = [text stringByAppendingFormat:@"%@%@", @"//", retweetText];
                }
            }

            
            status.text = text;
            status.source = [statusDict objectForKey:@"source"];
            status.repostsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"reposts_count"] integerValue]];
            status.commentsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"comments_count"] integerValue]];
            status.replyToStatusId = [statusDict objectForKey:@"in_reply_to_status_id"];
            
            [self.managedObjectContext save:nil];
            
        }
        
        [self statusArrayFromDatabase];
        
        [self.scrollView stopLoading];
    }
}

-(void)statusArrayFromDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                          initWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    self.timeline = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    [self.timelineTable reloadData];
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
    
    Status *status = (Status *)[self.timeline objectAtIndex:row];
    
    //NSDictionary *userInfo = [[self.timeline objectAtIndex:row] objectForKey:@"user"];
    
    //NSString *screen_name = [userInfo objectForKey:@"screen_name"];
    result.authName.stringValue = status.userScreenName;
    
    //NSString *createdAt = [[self.timeline objectAtIndex:row] objectForKey:@"created_at"];
    //NSDate *createdDate = [self.utcDateFormatter dateFromString:createdAt];
    NSTimeInterval intervalSince1970 = [status.createdAt timeIntervalSince1970];
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
    NSDateFormatter *relativeFormatter = [[NSDateFormatter alloc] init];
    relativeFormatter.timeZone = [self localTimeZone];
    relativeFormatter.dateFormat = @"H:mm";
    
    result.createdTime.stringValue = [relativeFormatter stringFromDate:localDate];
    
    //Status *status = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    //status.id = [userInfo objectForKey:@"idstr"];
    //status.text = [self populateText:row];
    //status.createdAt = createdDate;
    
    //NSError *error;
    //[self.managedObjectContext save:&error];
    
    WBUser *user = [[WBUser alloc] initWithUserId: status.userIdStr
                                       accessToken:[WBAuthorize sharedInstance].accessToken];
    user.profileImageUrl = status.profileImageUrl;
    if (user.profileImage) {
        result.userProfileImageView.image = user.profileImage;
    }else{
        [self startUserProfileImageDownload:user forRow:row];
    }
    
//    NSString *text = [self populateText:row];//[[self.timeline objectAtIndex:row] objectForKey:@"text"];
//    NSString *retweetText = nil;
//    NSDictionary *retweetStatus = [[self.timeline objectAtIndex:row] objectForKey:@"retweeted_status"];
//    if (retweetStatus) {
//         retweetText = [retweetStatus objectForKey:@"text"];
//    }
    
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
        
        //NSURL* url = [NSURL URLWithString: subString];
        [rString addAttribute:NSLinkAttributeName value:subString range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:matchRange];
        [rString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:matchRange];
    }
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:4.0];
    [rString addAttribute:NSParagraphStyleAttributeName value:myStyle range:NSMakeRange(0, status.text.length)];
    
    
    [result.statusTextView.textStorage setAttributedString:rString];

    
    //[((WBMessageTextView *)result.statusTextView) setText:text withRetweetText:retweetText];
    
    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *text = ((Status *)[self.timeline objectAtIndex:row]).text;
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:text];
    [rString addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range: NSMakeRange(0, rString.length)];
    
    float rows = ceilf(rString.size.width / 360.0f);
    return (rString.size.height + 3 ) * rows + 30 > 68 ? (rString.size.height + 3) * rows + 30 : 68;
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
