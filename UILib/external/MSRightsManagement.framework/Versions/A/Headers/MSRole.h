//
//  MSRole.h
//  sdk-ios
//
//  Created by Vladimir Postel on 6/19/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//
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

@interface MSRole : MSSecureCodableObject

// User will only be able to view the document. They cannot edit, copy, or print it.
+ (NSString *)viewer;
// User will be able to view and edit the document. They cannot copy or print it.
+ (NSString *)reviewer;
// User will be able to view, edit, copy, and print the document.
+ (NSString *)author;
// User will have all permissions
+ (NSString *)coOwner;

@end
