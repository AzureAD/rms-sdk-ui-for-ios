/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSRole.h
 *
 */
//  Abstract: This class is used to define the roles in the SDK.
//  Roles can be used for creating a custom policy instead the rights
//  The following roles are supported : viewer, reviewer, author and coOwner
//  Each role mapped to the rights as follows : viewer    -->  view
//                                              reviewer  -->  view, edit
//                                              author    -->  view, edit, copy, print
//                                              coOwner   -->  all permissions
//

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn790778(v=vs.85).aspx
 
 */
@interface MSRole : MSSecureCodableObject


+ (NSString *)viewer;
+ (NSString *)reviewer;
+ (NSString *)author;
+ (NSString *)coOwner;

@end
