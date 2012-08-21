//
//  WBMessageTextView.m
//  weibo
//
//  Created by feng qijun on 8/21/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBMessageTextView.h"

@interface WBMessageTextView()

@property(readonly, nonatomic) NSRegularExpression *userRegularExpression;
@property(readonly, nonatomic) NSRegularExpression *urlRegularExpression;

@end

@implementation WBMessageTextView

@synthesize userRegularExpression = _userRegularExpression;
@synthesize urlRegularExpression = _urlRegularExpression;

-(NSRegularExpression *)userRegularExpression
{
    if (!_userRegularExpression) {
        _userRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"@[\\w-]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    }
    
    return _userRegularExpression;
}

-(NSRegularExpression *)urlRegularExpression
{
    if (!_urlRegularExpression) {
        _urlRegularExpression =
        [NSRegularExpression regularExpressionWithPattern:@"(http://|https://)([a-zA-Z0-9]+\\.[a-zA-Z0-9\\-]+|[a-zA-Z0-9\\-]+)\\.[a-zA-Z\\.]{2,6}(/[a-zA-Z0-9\\.\\?=/#%&\\+-]+|/|)"
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
    }
    
    return _urlRegularExpression;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void)setText:(NSString *)text withRetweetText:(NSString *)retweetText
{
    
}

@end
