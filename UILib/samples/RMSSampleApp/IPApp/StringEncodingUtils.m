/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     StringEncodingUtils.m
 *
 */

#import "StringEncodingUtils.h"

@implementation StringEncodingUtils

// Gets the string encoding of the data, based on its BOM
+ (NSStringEncoding)getStringEncoding:(NSData *)data
{
    static Byte utf8HeaderBytes[]    = { 0xEF, 0xBB, 0xBF };
    static Byte utf16leHeaderBytes[] = { 0xFF, 0xFE };
    static Byte utf16beHeaderBytes[] = { 0xFE, 0xFF };
    static Byte utf32leHeaderBytes[] = { 0xFF, 0xFE, 0x00, 0x00 };
    static Byte utf32beHeaderBytes[] = { 0x00, 0x00, 0xFE, 0xFF };
    
    NSData *utf8Header    = [NSData dataWithBytes:utf8HeaderBytes length:sizeof(utf8HeaderBytes)];
    NSData *utf16leHeader = [NSData dataWithBytes:utf16leHeaderBytes length:sizeof(utf16leHeaderBytes)];
    NSData *utf16beHeader = [NSData dataWithBytes:utf16beHeaderBytes length:sizeof(utf16beHeaderBytes)];
    NSData *utf32leHeader = [NSData dataWithBytes:utf32leHeaderBytes length:sizeof(utf32leHeaderBytes)];
    NSData *utf32beHeader = [NSData dataWithBytes:utf32beHeaderBytes length:sizeof(utf32beHeaderBytes)];
    
    if ([self doesData:data startWithHeader:utf32leHeader])
    {
        return NSUTF32LittleEndianStringEncoding;
    }
    else if ([self doesData:data startWithHeader:utf32beHeader])
    {
        return NSUTF32BigEndianStringEncoding;
    }
    else if ([self doesData:data startWithHeader:utf8Header])
    {
        return NSUTF8StringEncoding;
    }
    else if ([self doesData:data startWithHeader:utf16leHeader])
    {
        return NSUTF16LittleEndianStringEncoding;
    }
    else if ([self doesData:data startWithHeader:utf16beHeader])
    {
        return NSUTF16BigEndianStringEncoding;
    }
    return NSUTF8StringEncoding;
}

+ (BOOL)doesData:(NSData *)data startWithHeader:(NSData *)header
{
    if (data.length < header.length)
    {
        return NO;
    }
    NSData *firstBytes = [data subdataWithRange:NSMakeRange(0, header.length)];
    return [firstBytes isEqualToData:header];
}



@end
