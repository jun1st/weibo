//
//  Mention+CoreData.h
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Mention.h"

@interface Mention (CoreData)

+(void)save:(NSDictionary *)metion inContext:(NSManagedObjectContext *)context;
+(NSArray *)metionsFromContext:(NSManagedObjectContext *)context;

@end
