/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSConsent.h
 *
 */
// The consent supplies a mechanism to get variouse confirmation needed from the user
// Currently two consents are supported one is used for connecting to server URL and the other is for document tracking.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSConsentType) {
    DocumentTrackingConsent = 0,
    ServiceURLConsent = 1
};

@interface MSConsentResult : NSObject

@property (assign) BOOL accepted;
@property (assign) BOOL showAgain;
@property (strong) NSString *userId;

@end

@interface MSConsent : NSObject

@property (readonly) MSConsentType type;
@property (strong, readonly) MSConsentResult *consentResult;

@end

@interface MSServiceURLConsent : MSConsent

@property (strong, readonly) NSArray */*NSURL*/urls;

@end

