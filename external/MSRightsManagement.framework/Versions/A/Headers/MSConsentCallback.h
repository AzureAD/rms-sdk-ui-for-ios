/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSConsentCallback.h
 *
 */
// The consent callback used transfer the user the all consents that should be approved for a given operation.

#import <Foundation/Foundation.h>

@protocol MSConsentCallback <NSObject>

@required

- (void)consents:(NSArray */*MSConsent*/)consents consentsCompletionBlock:(void(^)(NSArray */*MSConsent*/consentsResult))consentsCompletionBlock;

@end