//
//  WBUser.m
//  weibo
//
//  Created by feng qijun on 8/18/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBUser.h"
#import "WBRequest.h"
#define kWBUserInfoURL @"https://api.weibo.com/2/users/show.json"

#define kUName @"name"
#define kUScreenName @"screenName"
#define kUId @"uid"
#define kUDescription @"description"
#define kUProfileImageUrl @"profileImageUrl"
#define kULargeProfileImageUrl @"largeProfileImageUrl"
#define kULocation @"location"

#define kUFavoritesCount @"favoritesCount"
#define kUFollowersCount @"followersCount"
#define kUStatusesCount @"statusesCount"
#define kUFriendCount @"friendsCount"

@interface WBUser()<WBRequestDelegate>

@property(strong)NSString *accessToken;

@end

@implementation WBUser

-(id)initWithUserId:(NSString *)uid accessToken:(NSString *)accessToken
{
    self = [super init];
    if (self) {
        self.userId = uid;
        self.accessToken = accessToken;
    }
    
    return self;
}

-(void)requestAuthorizingUser
{
    if (self.userId && self.accessToken) {
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.userId, @"uid",
                                self.accessToken, @"access_token", nil];
        
        WBRequest *request = [WBRequest requestWithURL:kWBUserInfoURL
                                      httpMethod:@"GET"
                                          params:params
                                    postDataType:kWBRequestPostDataTypeNormal
                                httpHeaderFields:nil
                                        delegate:self];
        
        [request connect];

    }
}

+(WBUser *)authorizingUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [defaults objectForKey:kUId];
    if (!uid) {
        return nil;
    }
    WBUser *user = [[WBUser alloc] init];
    user.userId = uid;
    user.name = [defaults objectForKey: kUName];
    user.screenName = [defaults objectForKey: kUScreenName];
    user.location = [defaults objectForKey: kULocation];
    user.description = [defaults objectForKey: kUDescription];
    user.profileImageUrl = [defaults objectForKey: kUProfileImageUrl];
    user.largeProfileImageUrl = [defaults objectForKey:kULargeProfileImageUrl];
    user.favoritesCount = [defaults objectForKey: kUFavoritesCount];
    user.followersCount = [defaults objectForKey: kUFollowersCount];
    user.friendsCount = [defaults objectForKey: kUFriendCount];
    user.statusesCount = [defaults objectForKey: kUStatusesCount];
    
    return user;
}

-(void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{

    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        self.name = [dict objectForKey:@"name"];
        self.screenName = [dict objectForKey:@"screen_name"];
        self.location = [dict objectForKey:@"location"];
        self.description = [dict objectForKey:@"description"];
        self.profileImageUrl = [dict objectForKey:@"profile_image_url"];
        self.largeProfileImageUrl = [dict objectForKey:@"avatar_large"];
        self.favoritesCount = [NSNumber numberWithInt:[[dict objectForKey:@"favorites_count"] intValue]];
        self.followersCount = [NSNumber numberWithInt:[[dict objectForKey:@"followers_count"] intValue]];
        self.statusesCount = [NSNumber numberWithInt:[[dict objectForKey:@"statuses_count"] intValue]];
        self.friendsCount = [NSNumber numberWithInt:[[dict objectForKey:@"friends_count"] intValue]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userId forKey:kUId];
        [defaults setObject:self.name forKey:kUName];
        [defaults setObject:self.screenName forKey:kUScreenName];
        [defaults setObject:self.location forKey:kULocation];
        [defaults setObject:self.description forKey:kUDescription];
        [defaults setObject:self.profileImageUrl forKey:kUProfileImageUrl];
        [defaults setObject:self.favoritesCount forKey:kUFavoritesCount];
        [defaults setObject:self.followersCount forKey:kUFollowersCount];
        [defaults setObject:self.statusesCount forKey:kUStatusesCount];
        [defaults setObject:self.friendsCount forKey:kUFriendCount];
        
        [defaults synchronize];
    }
}

@end
