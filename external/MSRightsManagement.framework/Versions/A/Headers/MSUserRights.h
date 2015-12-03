/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSUserRights.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn790811(v=vs.85).aspx
 
 */
@interface MSUserRights : MSSecureCodableObject

- (id)initWithUsers:(NSArray *)users
             rights:(NSArray/*NSString*/*)rights;

@property (strong, readonly) NSArray *users;
@property (strong, readonly) NSArray/*NSString*/ *rights;

@end
