/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSAuthenticationCallback.h
 *
 */

#import <Foundation/Foundation.h>
@class MSAuthenticationParameters;

/*!
 
 @protocol
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn758312(v=vs.85).aspx
 
 */
@protocol MSAuthenticationCallback <NSObject>

@required

- (void)accessTokenWithAuthenticationParameters:(MSAuthenticationParameters *)authenticationParameters completionBlock:(void(^)(NSString *accessToken, NSError *error))completionBlock;

@end
