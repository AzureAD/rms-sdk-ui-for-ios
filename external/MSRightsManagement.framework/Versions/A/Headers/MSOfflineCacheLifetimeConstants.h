//
//  MSOfflineCacheLifetimeConstants.h
//  sdk-ios
//
//  Created by Vladimir Postel on 4/6/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSOfflineCacheLifetimeConstants : NSObject

+ (NSInteger)NoCache;              // The content shoudn't be accessed offline at all
+ (NSInteger)CacheNeverExpires;    // The offline cache for the content shouldn't expire

@end
