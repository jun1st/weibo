//
//  AttributedStringCodeHelper.h
//  weibo
//
//  Created by feng qijun on 9/4/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "FontUtility.h"

@interface AttributedStringCoderHelper : NSObject {
    
}

+(void)encodeAttributedStringAttributes:(NSDictionary*)attributes withKeyedArchiver:(NSKeyedArchiver*)archiver;
+(NSDictionary*)decodeAttributedStringAttriubtes:(NSKeyedUnarchiver*)decoder;
+(NSData*)encodeAttributedString:(NSAttributedString*)attributedString;
+(NSAttributedString*)decodeAttributedStringFromData:(NSData*)data;

@end
