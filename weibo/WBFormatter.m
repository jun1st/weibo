//
//  WBFormatter.m
//  weibo
//
//  Created by feng qijun on 8/28/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBFormatter.h"

@implementation WBFormatter

+(NSDateFormatter *)wbUTCDateFormatter
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"EEE MMM d HH:mm:ss ZZZ yyyy";
    }
    
    return dateFormatter;
}

@end
