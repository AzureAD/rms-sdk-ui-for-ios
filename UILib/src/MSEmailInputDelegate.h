/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSEmailInputDelegate.m
 *
 */

//  Abstract: Protocol to react to user entering a valid email address.
//      The email address is cached within the app's sandbox once authenticated.

#import <Foundation/Foundation.h>

@protocol MSEmailInputDelegate <NSObject>

@required

- (void)onEmailInputTappedWithEmail:(NSString *)email completionBlock:(void(^)(BOOL completed))completionBlock;

@end
