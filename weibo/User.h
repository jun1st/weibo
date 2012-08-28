//
//  User.h
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * idstr;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * friendsCount;
@property (nonatomic, retain) NSNumber * statusCount;
@property (nonatomic, retain) NSNumber * favouritesCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * verifiedReason;

@end
