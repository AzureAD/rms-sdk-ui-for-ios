//
//  MSTemplateDescriptor.h
//  sdk-ios
//
//  Created by Vladimir Postel on 4/6/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@class MSAsyncControl;
@protocol MSAuthenticationCallback;

@interface MSTemplateDescriptor : MSSecureCodableObject

+ (MSAsyncControl *)templateListWithUserId:(NSString *)userId
                    authenticationCallback:(id<MSAuthenticationCallback>)authenticationCallback
                           completionBlock:(void(^)(NSArray/*MSTemplateDescriptor*/ *templates, NSError *error))completionBlock;

@property (strong, readonly) NSString *templateName;
@property (strong, readonly) NSString *templateDescription;
@property (strong, readonly) NSString *templateId;

@end
