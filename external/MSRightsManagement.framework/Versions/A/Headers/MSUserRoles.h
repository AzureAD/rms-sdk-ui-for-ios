/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSUserRoles.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn790814(v=vs.85).aspx
 
 */
@interface MSUserRoles : MSSecureCodableObject

- (id)initWithUsers:(NSArray/*NSString*/*)users
              roles:(NSArray/*NSString*/*)roles;

@property (strong, readonly) NSArray/*NSString*/ *users;
@property (strong, readonly) NSArray/*NSString*/ *roles;

@end

