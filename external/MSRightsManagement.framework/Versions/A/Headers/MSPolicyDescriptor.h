/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyDescriptor.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@interface MSPolicyDescriptor : MSSecureCodableObject

- (id)initWithUserRights:(NSArray/*MSUserRights*/ *)userRights;

- (id)initWithUserRoles:(NSArray/*MSUserRoles*/ *)userRoles;

// Policy name
@property (strong) NSString *name;
// Policy description
@property (strong) NSString *description;
// Rights granted to users
@property (strong, readonly) NSArray/*MSUserRights*/ *userRightsList;
// Roles granted to users
@property (strong, readonly) NSArray/*MSUserRoles*/ *userRolesList;
// Validity time
@property (strong) NSDate *contentValidUntil;
// Referral info
@property (strong) NSURL *referrer;
// Interval time (Apps can use constants from OfflineCacheLifetimeConstants object).
@property (assign) NSInteger offlineCacheLifetimeInDays;
// App specific data, encrypted
@property(strong) NSMutableDictionary *encryptedAppData;
// App specific data, signed
@property(strong) NSMutableDictionary *signedAppData;

@end
