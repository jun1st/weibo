//
//  Mention.h
//  weibo
//
//  Created by feng qijun on 8/30/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status, User;

@interface Mention : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * idstr;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Status *metionStatus;
@property (nonatomic, retain) User *user;

@end
