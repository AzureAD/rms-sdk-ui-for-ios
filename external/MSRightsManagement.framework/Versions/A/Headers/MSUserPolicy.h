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
@protocol MSAuthenticationCallback;
@protocol MSConsentCallback;

// Offline flag
typedef enum MSPolicyAcquisitionOptions : NSUInteger {
    Default = 0x0,
    OfflineOnly = 0x1
} MSPolicyAcquisitionOptions;

typedef enum MSUserPolicyCreationOptions : NSUInteger {
    None = 0x0,
    AllowAuditedExtraction = 0x1, // specifies whether the content can be opened in a non-RMS aware app or not
    PreferDeprecatedAlgorithms = 0x2 //specifies whether the deprecated algorithms (ECB) is preferred or not
    
} MSUserPolicyCreationOptions;

// UserPolicy type (template or adhoc)
typedef NS_ENUM(NSUInteger, MSUserPolicyType) {
    TemplateBased = 0,
    Custom = 1
};

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237816(v=vs.85).aspx
 
 */
@interface MSUserPolicy : MSSecureCodableObject

/*!
 
 @abstract
 @method
 
 This method creates a user policy based on the supplied serializedLicense parameter.
 The following method should be invoked from the main thread.
 
 @param serializedPolicy                The PL to be consumed
 
 @param userId                          The email address of the user that is trying to consume the protected content. This email address will be used to determine which policy
 object to use from the offline cache. If a policy object for this user is not found in the offline cache then this API will go online
 (if allowed) to get the policy object. If null is passed and OfflineOnly flag is passed, the first policy object found in the offline cache will be used.
 This parameter is also used as a hint for userId for user authentication, i.e., it will be passed to the IAuthenticationCallback.GetTokenAsync()
 in the AuthenticationParameters structure.
 
 @param authenticationCallback          authentication callback to be used for auth
 
 @param options                         offline flag
 
 @return userPolicy                     The created user policy.
 
 */
+ (MSAsyncControl *)userPolicyWithSerializedPolicy:(NSData *)serializedPolicy
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                   consentCallback:(id<MSConsentCallback>)consentCallback
                                           options:(MSPolicyAcquisitionOptions)options
                                   completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;
/*!
 
 @abstract
 @method
 
 This method creates a custom user policy based on the supplied templateDescriptor parameter.
 The following method should be invoked from the main thread.
 
 @param templateDescriptor              The template using which the policy is being created
 
 @param userId                          The email address of the user for whom the templates are being retrieved. This email address will be used to discover the RMS service instance
 (either ADRMS server or Azure RMS) that the user's organization is using.
 This parameter is also used as a hint for userId for user authentication, i.e., it will be passed to the IAuthenticationCallback.GetTokenAsync()
 in the AuthenticationParameters structure.
 
 @param authenticationCallback          authentication callback to be used for auth
 
 @param options                         options for creating user policy object (see MSUserPolicyCreationOptions enum)
 
 @return userPolicy                     The created user policy.
 
 */
+ (MSAsyncControl *)userPolicyWithTemplateDescriptor:(MSTemplateDescriptor *)templateDescriptor
                                              userId:(NSString *)userId
                                       signedAppData:(NSDictionary *)signedAppData
                              authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                             options:(MSUserPolicyCreationOptions)options
                                     completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;

/*!
 
 @abstract
 @method
 
 This method creates a user policy based on the supplied policyDescriptor parameter.
 The following method should be invoked from the main thread.
 
 @param policyDescriptor                The object which defines the policy
 
 @param userId                          The email address of the user for whom the templates are being retrieved. This email address will be used to discover the RMS service instance
 (either ADRMS server or Azure RMS) that the user's organization is using.
 This parameter is also used as a hint for userId for user authentication, i.e., it will be passed to the IAuthenticationCallback.GetTokenAsync()
 in the AuthenticationParameters structure.
 
 @param authenticationCallback          authentication callback to be used for auth
 
 @param options                         options for creating user policy object (see MSUserPolicyCreationOptions enum)
 
 @return userPolicy               The created user policy.
 
 */
+ (MSAsyncControl *)userPolicyWithPolicyDescriptor:(MSPolicyDescriptor *)policyDescriptor
                                            userId:(NSString *)userId
                            authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                                           options:(MSUserPolicyCreationOptions)options
                                   completionBlock:(void(^)(MSUserPolicy *userPolicy, NSError *error))completionBlock;

// Checking the rights
- (BOOL)accessCheck:(NSString *)right;

// Deprecated algorithms flag
@property (readonly) BOOL doesUseDeprecatedAlgorithm;

// The PL
@property (strong, readonly) NSData *serializedPolicy;

// Policy type (template or adhoc)
@property (readonly) MSUserPolicyType type;

// The name the policy
@property (strong, readonly) NSString *policyName;

// The description the policy
@property (strong, readonly) NSString *policyDescription;

// The template used to publish the content. Note: this property will be null for custom policies.
@property (strong, readonly) MSTemplateDescriptor *templateDescriptor;

// The policy descriptor. Note: this property will be null for template based policies.
@property (strong, readonly) MSPolicyDescriptor *policyDescriptor;

// The owner
@property(strong, readonly) NSString *owner;

// The user associated with the user policy
@property(strong, readonly) NSString *issuedTo;

// Is the current user the owner?
@property (readonly) BOOL isIssuedToOwner;

// Content Id
@property(strong, readonly) NSString *contentId;

// App specific data, encrypted
@property(strong, readonly) NSDictionary *encryptedAppData;

// App specific data, signed
@property(strong, readonly) NSDictionary *signedAppData;

// Referral info
@property (strong, readonly) NSURL *referrer;

// Validity time
@property(strong, readonly) NSDate *contentValidUntil;

// Checks if the user can audited extract the policy
@property(readonly) BOOL allowAuditedExtract;

@end
