/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSAuthenticationParameters.h
 *
 */


#import <Foundation/Foundation.h>

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn758313(v=vs.85).aspx
 
 */
@interface MSAuthenticationParameters : NSObject

@property (strong, readonly) NSString *authority;
@property (strong, readonly) NSString *resource;
@property (strong, readonly) NSString *scope;
@property (strong, readonly) NSString *userId;

@end
