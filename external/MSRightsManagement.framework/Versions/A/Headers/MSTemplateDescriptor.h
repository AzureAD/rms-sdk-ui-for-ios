/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSTemplateDescriptor.h
 *
 */

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@class MSAsyncControl;
@protocol MSAuthenticationCallback;

/*!
 
 @class
 @see documentation at - http://msdn.microsoft.com/en-us/library/dn790785(v=vs.85).aspx
 
 */
@interface MSTemplateDescriptor : MSSecureCodableObject

+ (MSAsyncControl *)templateListWithUserId:(NSString *)userId
                    authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                           completionBlock:(void(^)(NSArray/*MSTemplateDescriptor*/ *templates, NSError *error))completionBlock;

@property (strong, readonly) NSString *templateName;
@property (strong, readonly) NSString *templateDescription;
@property (strong, readonly) NSString *templateId;

@end
