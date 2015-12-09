/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyDescriptor.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@class MSLicenseMetadata;
/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn758339(v=vs.85).aspx
 
 */
@interface MSPolicyDescriptor : MSSecureCodableObject

- (id)initWithUserRights:(NSArray/*MSUserRights*/ *)userRights;

- (id)initWithUserRoles:(NSArray/*MSUserRoles*/ *)userRoles;

@property (strong) NSString *policyName;

@property (strong) NSString *policyDescription;

@property (strong, readonly) NSArray/*MSUserRights*/ *userRightsList;

@property (strong, readonly) NSArray/*MSUserRoles*/ *userRolesList;

@property (strong) NSDate *contentValidUntil;

@property (strong) NSURL *referrer;

@property (assign) NSInteger offlineCacheLifetimeInDays;

@property(strong) NSMutableDictionary *encryptedAppData;

@property(strong) NSMutableDictionary *signedAppData;

@property(strong) MSLicenseMetadata *licenseMetadata;

@end
