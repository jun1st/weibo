//
//  NSAttributedStringToNSDataValueTransformer.m
//  weibo
//
//  Created by feng qijun on 9/4/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "NSAttributedStringToNSDataValueTransformer.h"
#import "AttributedStringCodeHelper.h" 

@implementation NSAttributedStringToNSDataValueTransformer

+(void)initialize
{
    [NSValueTransformer setValueTransformer:[[self alloc] init] forName:@"NSAttributedStringValueTransformer"];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(NSAttributedString*)value
{
    return [AttributedStringCoderHelper encodeAttributedString:value];
}

-(id)reverseTransformedValue:(NSData*)value
{
    return [AttributedStringCoderHelper decodeAttributedStringFromData:value];
}

@end