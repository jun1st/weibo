//
//  WBUser+ProfileImage.m
//  weibo
//
//  Created by feng qijun on 8/19/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBUser+ProfileImage.h"

#define kFPProfileImageDirectory @"UserProfileImages"

@implementation WBUser (ProfileImage)

+(NSURL *)profileImageDirectory
{
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *availableURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    NSURL *profileImagesDirectory = nil;
    
    if (availableURLs.count > 0) {
        appSupportDir = [availableURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *appBundleId = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleId];
    }
    if (appDirectory) {
        profileImagesDirectory = [appDirectory URLByAppendingPathComponent:kFPProfileImageDirectory];
        
        if (![sharedFM fileExistsAtPath:profileImagesDirectory.absoluteString]) {
            NSError *error;
            [sharedFM createDirectoryAtPath:profileImagesDirectory.absoluteString
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error];
        }
    }
    
    return profileImagesDirectory;
}

-(NSImage *)profileImage
{
    NSURL *profileImageURL = [[WBUser profileImageDirectory] URLByAppendingPathComponent:self.userId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:profileImageURL.absoluteString]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:profileImageURL.absoluteString];
        return image;
    }
    
    return nil;
}

@end
