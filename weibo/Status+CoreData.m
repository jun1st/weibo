//
//  Status+CoreData.m
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Status+CoreData.h"
#import "WBFormatter.h"
#import  "User+CoreData.h"


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
        if ([text isEqualToString:@"转发微博"]) {
            text = @"";
        }
        NSDictionary *retweetStatus = [statusDict objectForKey:@"retweeted_status"];
        if (retweetStatus) {
            NSString *retweetText = [retweetStatus objectForKey:@"text"];
            status.retweetText = retweetText;
        }
        
        status.text = text;
        //status.attributedText = [Status attributedTextFromString:text];
        status.source = [statusDict objectForKey:@"source"];
        status.repostsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"reposts_count"] integerValue]];
        status.commentsCount = [NSNumber numberWithInteger:[[statusDict objectForKey:@"comments_count"] integerValue]];
        status.replyToStatusId = [statusDict objectForKey:@"in_reply_to_status_id"];
        status.author = [User saveFromDictionary:[statusDict objectForKey:@"user"] inContext:context];
        
        [context save:nil];
        
    }

}

+(NSArray *)statusesAtUser:(NSString *)idstr inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.predicate = [NSPredicate predicateWithFormat:@"replyToUserId = %@", idstr];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.fetchLimit = 20;
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!error) {
        return matches;
    }
    
    return nil;
}

+(Status *)statusById:(NSString *)idstr fromContext:(NSManagedObjectContext *)context
{
    Status *status = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", idstr];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!error) {
        status = [matches lastObject];
    }
    
    return status;
}

+(NSArray *)statusesFromContext:(NSManagedObjectContext *)context withOffSet:(NSUInteger)offset
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    request.fetchLimit = 30;
    request.fetchOffset = offset;
    
    NSError *error;
    NSArray *statuses = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return statuses;
}

+(NSAttributedString *)attributedTextFromString:(NSString *)text
{
    NSMutableAttributedString *rString = [[NSMutableAttributedString alloc] initWithString:text];
    
    [rString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range: NSMakeRange(0, rString.length)];
    
    //match user names
    NSArray *matches = [[WBFormatter userRegularExpression] matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0, [text length])];
    for(NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSFont *font = [NSFont userFontOfSize:13];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:13];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    //match urls
    NSArray *urlMatches = [[WBFormatter urlRegularExpression] matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult  *match in urlMatches) {
        NSRange matchRange = [match range];
        NSString *subString = [text substringWithRange:matchRange];
        
        [rString addAttribute:NSLinkAttributeName value:subString range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:matchRange];
        [rString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:matchRange];
    }
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:4.0];
    [rString addAttribute:NSParagraphStyleAttributeName value:myStyle range:NSMakeRange(0, text.length)];
    
    return rString;
}

@end
