//
//  FontUtility.h
//  weibo
//
//  Created by feng qijun on 9/4/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

CTFontDescriptorRef CreateFontDescriptorFromName(CFStringRef iPostScriptName, CGFloat iSize);
CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits(CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize);
CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize);
CTFontRef CreateBoldFont(CTFontRef iFont, Boolean iMakeBold);
CFDataRef CreateFlattenedFontData(CTFontRef iFont);
CTFontRef CreateFontFromFlattenedFontData(CFDataRef iData);