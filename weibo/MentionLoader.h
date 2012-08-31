//
//  Mention+Load.h
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "Mention.h"
#import "WBEngine.h"

@interface MentionLoader : NSObject<WBEngineDelegate>

-(void)metionsFromEngine:(WBEngine *)engine inContext:(NSManagedObjectContext *)context;

@end
