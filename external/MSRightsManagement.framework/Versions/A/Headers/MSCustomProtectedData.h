/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSCustomProtectedData.h
 *
 */

#import "MSProtectedData.h"

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758317(v=vs.85).aspx
 
 */
@interface MSCustomProtectedData : MSProtectedData

+ (void)customProtectedDataWithPolicy:(MSUserPolicy *)policy
                        protectedData:(NSData *)protectedData
                 contentStartPosition:(NSUInteger)contentStartPosition
                          contentSize:(NSUInteger)contentSize
                      completionBlock:(void(^)(MSCustomProtectedData *customProtectedData,NSError *error))completionBlock;

+ (NSUInteger)getEncryptedContentLengthWithPolicy:(MSUserPolicy *)policy contentLength:(NSUInteger)contentLength;

@end












