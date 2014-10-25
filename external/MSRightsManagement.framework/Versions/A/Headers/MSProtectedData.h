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
@protocol MSAuthenticationCallback;
@protocol MSConsentCallback;

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758348(v=vs.85).aspx
 
 */
@interface MSProtectedData : MSSecureCodableObject

+ (MSAsyncControl *)protectedDataWithProtectedFile:(NSString *)path
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                   consentCallback:(id<MSConsentCallback>)consentCallback
                                           options:(MSPolicyAcquisitionOptions)options
                                   completionBlock:(void(^)(MSProtectedData *data, NSError *error))completionBlock;

- (int64_t)length:(NSError **)errorPtr;

- (BOOL)getBytes:(void *)buffer length:(NSUInteger)length error:(NSError **)errorPtr;

- (BOOL)getBytes:(void *)buffer range:(NSRange)range error:(NSError **)errorPtr;

- (NSData *)subdataWithRange:(NSRange)range;

- (NSData *)retrieveData;

@property(strong, readonly) MSUserPolicy *userPolicy;

@property(strong, readonly) NSString *originalFileExtension;

@end
