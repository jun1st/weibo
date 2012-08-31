//
//  Mention+CoreData.m
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Mention+CoreData.h"
#import "WBFormatter.h"
#import "User+CoreData.h"
#import "Status+CoreData.h"

@implementation Mention (CoreData)

+(void)save:(NSDictionary *)mentionDict inContext:(NSManagedObjectContext *)context
{
    Mention *mention = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mention"];
    request.predicate = [NSPredicate predicateWithFormat:@"idstr = %@", [mentionDict objectForKey:@"idstr"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if([matches count] == 0){
        mention = [NSEntityDescription insertNewObjectForEntityForName:@"Mention" inManagedObjectContext:context];
        
        mention.createdAt = [[WBFormatter wbUTCDateFormatter] dateFromString:[mentionDict objectForKey:@"created_at"]];
        mention.idstr = [mentionDict objectForKey:@"idstr"];
        mention.text = [mentionDict objectForKey:@"text"];
        [User saveFromDictionary:[mentionDict objectForKey:@"user"] inContext:context];
        mention.user = [User userById:[(NSDictionary *)[mentionDict objectForKey:@"user"] objectForKey:@"idstr"]
                          fromContext:context];
        
        [Status save:[mentionDict objectForKey:@"status"] inContext:context];
        mention.metionStatus = [Status statusById:[(NSDictionary *)[mentionDict objectForKey:@"status"] objectForKey:@"idstr"]
                                  fromContext:context];
        
        [context save:nil];
    }
}

+(NSArray *)metionsFromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mention"];
    //request.predicate = [NSPredicate predicateWithFormat:@"idstr = %@", [mentionDict objectForKey:@"idstr"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!error) {
        return matches;
    }
    
    return nil;
}

@end
