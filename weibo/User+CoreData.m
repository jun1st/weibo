//
//  User+CoreData.m
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "User+CoreData.h"
#import "WBFormatter.h"

@implementation User (CoreData)

+(User *)userById:(NSString *)id fromContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"idstr = %@", id];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(matches != nil && matches.count > 0)
    {
        user = [matches lastObject];
    }
    
    return user;

}

+(void)saveFromDictionary:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)context
{
    User *user = [User userById:[userInfo objectForKey:@"idstr"] fromContext:context];
    
    if (user == nil) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        
        user.idstr = [userInfo objectForKey:@"idstr"];
        user.screenName = [userInfo objectForKey:@"screen_name"];
        user.name = [userInfo objectForKey:@"name"];
        user.location = [userInfo objectForKey:@"location"];
        user.profileImageUrl = [userInfo objectForKey:@"profile_image_url"];
        user.followersCount = [NSNumber numberWithInteger:[[userInfo objectForKey:@"followers_count"] integerValue]];
        user.friendsCount = [NSNumber numberWithInteger:[[userInfo objectForKey:@"friends_count"] integerValue]];
        user.statusCount = [NSNumber numberWithInteger:[[userInfo objectForKey:@"statuses_count"] integerValue]];
        user.favouritesCount = [NSNumber numberWithInteger:[[userInfo objectForKey:@"favourites_count"] integerValue]];
        user.bio = [userInfo objectForKey:@"description"];
        user.createdAt = [[WBFormatter wbUTCDateFormatter] dateFromString:[userInfo objectForKey:@"created_at"]];
        user.url = [userInfo objectForKey:@"url"];
        user.verifiedReason = [userInfo objectForKey:@"verified_reason"];
        
        [context save:nil];
        
    }
}

@end
