//
//  MSAuthenticationParameters.h
//  sdk-ios
//
//  Created by Vladimir Postel on 4/3/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSAuthenticationParameters : NSObject

@property (strong, readonly) NSString *authority;
@property (strong, readonly) NSString *resource;
@property (strong, readonly) NSString *scope;
@property (strong, readonly) NSString *userId;

@end
