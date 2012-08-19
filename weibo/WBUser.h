//
//  WBUser.h
//  weibo
//
//  Created by feng qijun on 8/18/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSNumber *followersCount;
@property (nonatomic, strong) NSNumber *friendsCount;
@property (nonatomic, strong) NSNumber *statusesCount;
@property (nonatomic, strong) NSNumber *favoritesCount;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *largeProfileImageUrl;

-(id)initWithUserId:(NSString *)uid accessToken:(NSString *)accessToken;

-(void)requestAuthorizingUser;

+(WBUser *)authorizingUser;

@end
