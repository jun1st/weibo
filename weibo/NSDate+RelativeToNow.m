//
//  NSDate+RelativeToNow.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+RelativeToNow.h"

@implementation NSDate (ShortFormatToNow)

-(NSString *)relativeTimeToNow
{
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self];
    
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    

    if (delta < MINUTE)
    {
        return [NSString stringWithFormat:@"%ds", (int)delta];
    }
    
    if (delta < HOUR)
    {
        return [NSString stringWithFormat:@"%dm", (int)(delta / MINUTE)];
    }
    
    if (delta < DAY)
    {
        return [NSString stringWithFormat:@"%dh", (int)(delta / HOUR)];
    }
    if (delta < MONTH)
    {
        return [NSString stringWithFormat:@"%dd", (int)(delta / DAY)];
    }
    if (delta < 12 * MONTH)
    {
        return [NSString stringWithFormat:@"%dm", (int)(delta / MONTH)];
    }
    else
    {
        return @"long time ago";
    }
}

@end
