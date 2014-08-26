//
//  MSConsentCallback.h
//  sdk-ios
//
//  Created by Vladimir Postel on 06/08/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//
// The consent callback used transfer the user the all consents that should be approved for a given operation.

#import <Foundation/Foundation.h>

@protocol MSConsentCallback <NSObject>

@required

- (void)consents:(NSArray */*MSConsent*/)consents consentsCompletionBlock:(void(^)(NSArray */*MSConsent*/consentsResult))consentsCompletionBlock;

@end