/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSOfflineCacheLifetimeConstants.h
 *
 */

#import <Foundation/Foundation.h>

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn758330(v=vs.85).aspx
 
 */
@interface MSOfflineCacheLifetimeConstants : NSObject

+ (NSInteger)NoCache;
+ (NSInteger)CacheNeverExpires;    

@end
