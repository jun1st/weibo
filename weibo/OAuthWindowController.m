//
//  OAuthWindowController.m
//  weibo
//
//  Created by feng qijun on 8/8/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#define OAuthConsumerKey @"4116306678"
#define OAuthConsumerSecret @"630c48733d7f6c717ad6dec31bf50895"

#define kWBRedirectURL @"http://"

#define kWBURLSchemePrefix              @"WB_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"


#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"

#import "OAuthWindowController.h"
#import "MainWindowController.h"
#import "WBUtil.h"
#import "WBAuthorize.h"

@interface OAuthWindowController ()<WBAuthorizeDelegate>

@property NSTimeInterval expireTime;
@property (nonatomic, strong)WBAuthorize *wbAuthorize;

-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource;

@end

@implementation OAuthWindowController

@synthesize oauthView = _oauthView;
@synthesize expireTime = _expireTime;
@synthesize wbAuthorize = _wbAuthorize;

-(id)init{
    self = [super initWithWindowNibName:@"OAuthWindow"];
    if (self) {
        
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSURLRequest *request = [self.wbAuthorize getAuthorizeUrl];
    [self.oauthView setResourceLoadDelegate:self];
    [self.oauthView setFrameLoadDelegate:self];
    [self.oauthView.mainFrame loadRequest:request];
    
}

-(BOOL)isAuthorized
{
    if (self.wbAuthorize.isLoggedIn && !self.wbAuthorize.isAuthorizationExpired) {
        return YES;
    }
    
    return NO;
}

-(WBAuthorize *)wbAuthorize
{
    if (!_wbAuthorize) {
        _wbAuthorize = [[WBAuthorize alloc] initWithAppKey:OAuthConsumerKey appSecret:OAuthConsumerSecret redirectURL:kWBRedirectURL];
        _wbAuthorize.delegate = self;
    }
    
    return _wbAuthorize;
}

#pragma webView resource load delegate method

-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{

    NSRange range = [request.URL.absoluteString rangeOfString:@"http://localhost/?code="];
    if (range.location != NSNotFound ) {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        NSLog(@"%@", code);
        
        //user cancel
        if (![code isEqualToString:@"21330"]) {
            [self.wbAuthorize requestAccessTokenWithAuthorizeCode:code];
        }
        else{
            [self close];
        }
    }
    
    return request;
}

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kWBURLSchemePrefix, OAuthConsumerKey];
}

#pragma WBAuthorizeDelegate methods

-(void)authorize:(WBAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds
{
    [self close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"authorized" object:self];
}

-(void)authorize:(WBAuthorize *)authorize didFailWithError:(NSError *)error
{
    
}

@end
