//
//  WBAuthorize.m
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"
#import "WBUtil.h"
#import "SSKeychain.h"

#define kKeychainServiceName   @"iweb4Mac"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"

#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"

#define kKeychainName @"iweb4mac"
#define kKeychainKind @"OAuthLogin"

@interface WBAuthorize ()

@property(nonatomic, strong) NSString *userId;
@property(nonatomic) NSTimeInterval expireTime;
@property(nonatomic, strong) NSString *serviceName;

-(void)saveAuthorizationDataToKeychain;
-(void)readAuthorizationDataFromKeychain;
-(void)deleteAuthorizationDataFromKeychain;

@end

@implementation WBAuthorize

@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize redirectURL = _redirectURL;
@synthesize request = _request;
@synthesize delegate = _delegate;
@synthesize serviceName = _serviceName;

#pragma mark - WBAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret redirectURL:(NSString *)redirectURL
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        self.redirectURL = redirectURL;
        
        [self readAuthorizationDataFromKeychain];
    }
    
    return self;
}

-(NSString *)serviceName
{
    if (_serviceName) {
        _serviceName = @"iweb4mac";
    }
    
    return _serviceName;
}

-(NSString *)accessToken
{
    if(!_accessToken)
    {
        [self readAuthorizationDataFromKeychain];
    }
    
    return _accessToken;
}

#pragma mark - WBAuthorize Private Methods

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.appKey, @"client_id",
                                                                      self.appSecret, @"client_secret",
                                                                      @"authorization_code", @"grant_type",
                                                                      self.redirectURL, @"redirect_uri",
                                                                      code, @"code", nil];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                   httpMethod:@"POST"
                                       params:params
                                 postDataType:kWBRequestPostDataTypeNormal
                             httpHeaderFields:nil 
                                     delegate:self];
    
    [self.request connect];
}

-(NSURLRequest *)getAuthorizeUrl
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.appKey, @"client_id",
                            @"code", @"response_type",
                            self.redirectURL, @"redirect_uri",
                            @"mobile", @"display", nil];
    
    NSURL *parsedURL = [NSURL URLWithString:kWBAuthorizeURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    
	NSString *query = [self stringFromDictionary:params];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", parsedURL, queryPrefix, query];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60.0];
    
    return req;
}

-(void)saveAuthorizationDataToKeychain
{
    
    [SSKeychain setPassword:self.accessToken forService:kKeychainServiceName account:kWBKeychainAccessToken];
    [SSKeychain setPassword:self.userId forService:kKeychainServiceName account:kWBKeychainUserID];
    [SSKeychain setPassword:[NSString stringWithFormat:@"%f", self.expireTime] forService:kKeychainServiceName account:kWBKeychainExpireTime];

}

-(void)readAuthorizationDataFromKeychain
{
    self.userId = [SSKeychain passwordForService:kKeychainServiceName account:kWBKeychainUserID];
    
    self.accessToken = [SSKeychain passwordForService:kKeychainServiceName account:kWBKeychainAccessToken];
    self.expireTime = [[SSKeychain passwordForService:kKeychainServiceName account:kWBKeychainExpireTime] doubleValue];
}

-(void)deleteAuthorizationDataFromKeychain
{
    self.accessToken = nil;
    self.userId = nil;
    self.expireTime = 0;
    
    [SSKeychain deletePasswordForService:kKeychainServiceName account:kWBKeychainAccessToken];
    [SSKeychain deletePasswordForService:kKeychainServiceName account:kWBKeychainUserID];
    [SSKeychain deletePasswordForService:kKeychainServiceName account:kWBKeychainExpireTime];
    
}

-(void)logout
{
    [self deleteAuthorizationDataFromKeychain];
}

-(BOOL)isLoggedIn
{
    return self.accessToken && self.userId && (self.expireTime > 0);
}

-(BOOL)isAuthorizationExpired
{
    if (![[NSDate date] timeIntervalSince1970] > self.expireTime) {
        [self deleteAuthorizationDataFromKeychain];
        return YES;
    }
    return NO;
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        self.accessToken = [dict objectForKey:@"access_token"];
        self.userId = [dict objectForKey:@"uid"];
        NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
        
        self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
        
        success = self.accessToken && self.userId;
        
        if (success) {
            [self saveAuthorizationDataToKeychain];
            
            if ([self.delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)]) {
                [self.delegate authorize:self didSucceedWithAccessToken:self.accessToken userID:self.userId expiresIn:seconds];
            }
        }
        
    }
    
    // should not be possible
    if (!success && [self.delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kWBSDKErrorDomain 
                                             code:kWBErrorCodeSDK 
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kWBSDKErrorCodeAuthorizeError] 
                                                                              forKey:kWBSDKErrorCodeKey]];
        [self.delegate authorize:self didFailWithError:error];
    }
}

- (void)request:(WBRequest *)theReqest didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [self.delegate authorize:self didFailWithError:error];
    }
}

-(NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

@end
