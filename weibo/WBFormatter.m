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

+(NSRegularExpression *)urlRegularExpression
{
    static NSRegularExpression *_urlRegularExpression;
    if (!_urlRegularExpression) {
        _urlRegularExpression =
        [NSRegularExpression regularExpressionWithPattern:@"(http://|https://)([a-zA-Z0-9]+\\.[a-zA-Z0-9\\-]+|[a-zA-Z0-9\\-]+)\\.[a-zA-Z\\.]{2,6}(/[a-zA-Z0-9\\.\\?=/#%&\\+-]+|/|)"
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
    }
    
    return _urlRegularExpression;
}

+(NSRegularExpression *)userRegularExpression
{
    static NSRegularExpression *_userRegularExpression;
    
    if (!_userRegularExpression) {
        _userRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"@[\\w-]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    }
    
    return _userRegularExpression;

}

+(NSRegularExpression *)topicRegularExpression
{
    static NSRegularExpression *_topicRegularExpression;
    
    if (!_topicRegularExpression) {
        _topicRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"#\\S+#" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return _topicRegularExpression;
}

@end
