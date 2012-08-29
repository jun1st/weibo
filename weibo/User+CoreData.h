//
//  User+CoreData.h
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "User.h"

@interface User (CoreData)

+(User *)userById:(NSString *)id fromContext:(NSManagedObjectContext *)context;

+(User *)saveFromDictionary:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)context;

@end
