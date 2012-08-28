//
//  Status+CoreData.m
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Status+CoreData.h"
#import "WBFormatter.h"


@implementation Status (CoreData)

+(void)save:(NSDictionary *)statusDict inContext:(NSManagedObjectContext *)context
{
    Status *status = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", [statusDict objectForKey:@"idstr"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if([matches count] == 0){
        status = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
        
        status.id = [statusDict objectForKey:@"idstr"];
        NSDictionary *userInfo = [statusDict objectForKey:@"user"];
        NSString *screen_name = [userInfo objectForKey:@"screen_name"];
        status.userScreenName = screen_name;
        status.userIdStr = [userInfo objectForKey:@"idstr"];
        status.profileImageUrl = [userInfo objectForKey:@"profile_image_url"];
        NSString *createdAt = [statusDict objectForKey:@"created_at"];
        NSDate *createdDate = [[WBFormatter wbUTCDateFormatter] dateFromString:createdAt];
        
        status.createdAt = createdDate;
        
        NSString *text = [statusDict objectForKey:@"text"];
        NSDictionary *retweetStatus = [statusDict objectForKey:@"retweeted_status"];
        if (retweetStatus) {
            NSString *retweetText = [retweetStatus objectForKey:@"text"];
            if (retweetText && retweetText.length > 0) {
                text = [text stringByAppendingFormat:@"%@%@", @"//", retweetText];
            }
        }
        
        
        status.text = text;
        status.source = [statusDict objectForKey:@"source"];
        status.repostsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"reposts_count"] integerValue]];
        status.commentsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"comments_count"] integerValue]];
        status.replyToStatusId = [statusDict objectForKey:@"in_reply_to_status_id"];
        
        [context save:nil];
        
    }

}

@end
