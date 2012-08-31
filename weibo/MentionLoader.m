//
//  Mention+Load.m
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MentionLoader.h"
#import "Mention+CoreData.h"
#import "WBManagedObjectContext.h"

#define kWBMetionsUrl @"comments/mentions.json"

@interface MentionLoader()

@property (nonatomic, strong) WBEngine *newEngine;

@end

@implementation MentionLoader

@synthesize newEngine = _newEngine;

-(WBEngine *)newEngine
{
    if (!_newEngine) {
        _newEngine = [[WBEngine alloc] init];
        _newEngine.delegate = self;
    }
    
    return _newEngine;
}

-(void)metionsFromEngine:(WBEngine *)engine inContext:(NSManagedObjectContext *)context
{
    
    engine.delegate = self;
    [engine loadRequestWithMethodName:kWBMetionsUrl
                                httpMethod:@"GET"
                                    params:nil
                              postDataType:kWBRequestPostDataTypeNone
                          httpHeaderFields:nil];
}

-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        NSMutableArray *metionsDict = [dict objectForKey:@"comments"];
        
        for (int i=0; i < metionsDict.count; i++) {
            NSDictionary *metion = [metionsDict objectAtIndex:i];
            [Mention save:metion inContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
        }
    }
}

-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    
}

@end
