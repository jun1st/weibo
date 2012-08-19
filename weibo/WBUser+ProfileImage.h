//
//  WBUser+ProfileImage.h
//  weibo
//
//  Created by feng qijun on 8/19/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBUser.h"

@interface WBUser (ProfileImage)

+(NSURL *)profileImageDirectory;
-(NSImage *)profileImage;

@end
