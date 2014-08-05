/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSProtectedData.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSUserPolicy.h"
#import "MSSecureCodableObject.h"

@class MSAsyncControl;
@class MSAuthenticationCallback;
/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237800(v=vs.85).aspx
 
 */
@interface MSProtectedData : MSSecureCodableObject

+ (MSAsyncControl *)protectedDataWithProtectedFile:(NSString *)path
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                           options:(MSPolicyAcquisitionOptions)options
                                   completionBlock:(void(^)(MSProtectedData *data, NSError *error))completionBlock;

- (NSUInteger)length:(NSError **)errorPtr;

- (BOOL)getBytes:(void *)buffer length:(NSUInteger)length error:(NSError **)errorPtr;

- (BOOL)getBytes:(void *)buffer range:(NSRange)range error:(NSError **)errorPtr;

- (NSData *)subdataWithRange:(NSRange)range;

- (NSData *)retrieveData;

@property(strong, readonly) MSUserPolicy *userPolicy;

@property(strong, readonly) NSString *originalFileExtension;

@end
