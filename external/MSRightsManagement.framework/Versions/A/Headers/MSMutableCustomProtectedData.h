/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSMutableCustomProtector.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSMutableProtectedData.h"

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237754(v=vs.85).aspx
 
 */
@interface MSMutableCustomProtectedData : MSMutableProtectedData

+ (void)customProtectorWithUserPolicy:(MSUserPolicy *)userPolicy
                          backingData:(NSMutableData *)backingData
               protectedContentOffset:(NSUInteger)protectedContentOffset
                      completionBlock:(void(^)(MSMutableCustomProtectedData *customProtectedData,
                                                     NSError *error))completionBlock;

@end


