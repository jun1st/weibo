//
//  Status.h
//  weibo
//
//  Created by feng qijun on 8/30/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Status : NSManagedObject

@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * replyToStatusId;
@property (nonatomic, retain) NSNumber * repostsCount;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * userIdStr;
@property (nonatomic, retain) NSString * userScreenName;
@property (nonatomic, retain) NSString * replyToUserId;
@property (nonatomic, retain) User *author;

@end
