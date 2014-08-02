//
//  MSAuthenticationCallback.h
//  sdk-ios
//
//  Created by Vladimir Postel on 4/2/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSAuthenticationParameters;

/*!
 @class
 @abstract
 MSAuthenticationCallback holds the necessary information to retrieve an access token.
 */
@protocol MSAuthenticationCallback <NSObject>

@required

- (void)accessTokenWithAuthenticationParameters:(MSAuthenticationParameters *)authenticationParameters completionBlock:(void(^)(NSString *accessToken, NSError *error))completionBlock;

@end
