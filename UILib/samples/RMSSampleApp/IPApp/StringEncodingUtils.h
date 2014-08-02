/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     StringEncodingUtils.h
 *
 */

#import <Foundation/Foundation.h>

@interface StringEncodingUtils : NSObject

// Gets the string encoding of the data, based on its BOM
+ (NSStringEncoding)getStringEncoding:(NSData *)data;

@end
