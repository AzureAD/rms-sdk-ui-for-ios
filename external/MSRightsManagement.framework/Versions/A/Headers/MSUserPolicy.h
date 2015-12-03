/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSUserPolicy.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@class MSRight;
@class MSAsyncControl;
@class MSPolicyDescriptor;
@class MSTemplateDescriptor;
@class MSLicenseMetadata;
@protocol MSAuthenticationCallback;
@protocol MSConsentCallback;

/*!
 
 @enum
 @see documentation at http://msdn.microsoft.com/en-us/library/dn758332(v=vs.85).aspx
 
 */
typedef enum MSPolicyAcquisitionOptions : NSUInteger {
    Default = 0x0,
    OfflineOnly = 0x1
} MSPolicyAcquisitionOptions;

/*!
 
 @enum
 @see documentation at http://msdn.microsoft.com/en-us/library/dn790774(v=vs.85).aspx
 
 */
typedef enum MSUserPolicyCreationOptions : NSUInteger {
    None = 0x0,
    AllowAuditedExtraction = 0x1,
    PreferDeprecatedAlgorithms = 0x2
    
} MSUserPolicyCreationOptions;

/*!
 
 @enum
 @see documentation at http://msdn.microsoft.com/en-us/library/dn790775(v=vs.85).aspx
 
 */
typedef NS_ENUM(NSUInteger, MSUserPolicyType) {
    TemplateBased = 0,
    Custom = 1
};

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/dn790796(v=vs.85).aspx
 
 */
@interface MSUserPolicy : MSSecureCodableObject


+ (MSAsyncControl *)userPolicyWithSerializedPolicy:(NSData *)serializedPolicy
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                   consentCallback:(id<MSConsentCallback>)consentCallback
                                           options:(MSPolicyAcquisitionOptions)options
                                   completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;

+ (MSAsyncControl *)userPolicyWithTemplateDescriptor:(MSTemplateDescriptor *)templateDescriptor
                                              userId:(NSString *)userId
                                       signedAppData:(NSDictionary *)signedAppData
                                     licenseMetadata:(MSLicenseMetadata *)licenseMetadata
                              authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                             options:(MSUserPolicyCreationOptions)options
                                     completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;

+ (MSAsyncControl *)userPolicyWithPolicyDescriptor:(MSPolicyDescriptor *)policyDescriptor
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                           options:(MSUserPolicyCreationOptions)options
                                   completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;

- (MSAsyncControl *)registerForDocTracking:(BOOL)sendRegistrationNotificationMail
                                    userId:(NSString *)userId
                    authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                           completionBlock:(void(^)(BOOL success, NSError *error))completionBlock;

- (BOOL)accessCheck:(NSString *)right;

@property (readonly) BOOL doesUseDeprecatedAlgorithm;

@property (strong, readonly) NSData *serializedPolicy;

@property (readonly) MSUserPolicyType type;

@property (strong, readonly) NSString *policyName;

@property (strong, readonly) NSString *policyDescription;

@property (strong, readonly) MSTemplateDescriptor *templateDescriptor;

@property (strong, readonly) MSPolicyDescriptor *policyDescriptor;

@property(strong, readonly) NSString *owner;

@property(strong, readonly) NSString *issuedTo;

@property (readonly) BOOL isIssuedToOwner;

@property(strong, readonly) NSString *contentId;

@property(strong, readonly) NSDictionary *encryptedAppData;

@property(strong, readonly) NSDictionary *signedAppData;

@property (strong, readonly) NSURL *referrer;

@property(strong, readonly) NSDate *contentValidUntil;

@property(readonly) BOOL allowAuditedExtract;

@end
