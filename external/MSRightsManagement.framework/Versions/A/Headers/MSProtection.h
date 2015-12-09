/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSProtection.h
 *
 * This class is used for a common operations in the SDK, for instance: reset state that clears all cache
 *
 */

#import <Foundation/Foundation.h>


@interface MSProtection : NSObject

+ (void)resetStateWithCompletionBlock:(void(^)())completionBlock;

@end