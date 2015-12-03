/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSMutableProtectedData.h
 *
 */

#import "MSProtectedData.h"

@class MSUserPolicy;

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758325(v=vs.85).aspx
 
 */
@interface MSMutableProtectedData : MSProtectedData

+ (void)protectedDataWithPolicy:(MSUserPolicy *)userPolicy
          originalFileExtension:(NSString *)originalFileExtension
                           path:(NSString *)path
                completionBlock:(void(^)(MSMutableProtectedData *data, NSError *error))completionBlock;

- (BOOL)appendBytes:(const void *)bytes length:(NSUInteger)length error:(NSError **)errorPtr;

- (BOOL)appendData:(NSData *)other error:(NSError **)errorPtr;

- (BOOL)updateData:(NSData *)data error:(NSError **)errorPtr;

- (void)synchronizeFile;

- (BOOL)close:(NSError **)errorPtr;

@end

/*!
 
 @category
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237829(v=vs.85).aspx
 
 */
@interface NSData (MSMutableProtectedData)

- (void)protectedDataInFile:(NSString *)path
      originalFileExtension:(NSString *)originalFileExtension
             withUserPolicy:(MSUserPolicy *)userPolicy
            completionBlock:(void(^)(MSMutableProtectedData *data, NSError *error))completionBlock;

@end
