//
//  MSUserRoles.h
//  sdk-ios
//
//  Created by Vladimir Postel on 6/19/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecureCodableObject.h"

@interface MSUserRoles : MSSecureCodableObject

- (id)initWithUsers:(NSArray/*NSString*/*)users
              roles:(NSArray/*NSString*/*)roles;

@property (strong, readonly) NSArray/*NSString*/ *users;
@property (strong, readonly) NSArray/*NSString*/ *roles;

@end

