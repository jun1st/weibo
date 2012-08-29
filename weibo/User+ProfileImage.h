//
//  User+ProfileImage.h
//  weibo
//
//  Created by feng qijun on 8/30/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "User.h"

@interface User (ProfileImage)

+(NSURL *)profileImageDirectory;
-(NSImage *)profileImage;

@end
