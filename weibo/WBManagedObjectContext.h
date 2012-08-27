//
//  WBManagedObjectContext.h
//  weibo
//
//  Created by feng qijun on 8/27/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBManagedObjectContext : NSObject

@property(strong, readonly)NSManagedObjectContext *managedObjectContext;

+(WBManagedObjectContext *)sharedInstance;

@end
