//
//  Status+CoreData.h
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Status.h"

@interface Status (CoreData)

+(void)save:(NSDictionary *)status inContext:(NSManagedObjectContext *)context;
+(NSArray *)statusesAtUser:(NSString *)idstr inContext:(NSManagedObjectContext *)context;

+(Status *)statusById:(NSString *)idstr fromContext:(NSManagedObjectContext *)context;
+(NSArray *)statusesFromContext:(NSManagedObjectContext *)context withOffSet:(NSUInteger)offset;

@end
