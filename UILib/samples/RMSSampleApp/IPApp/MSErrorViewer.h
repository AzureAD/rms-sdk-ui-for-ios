/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSErrorViewer.h
 *
 */
//  A simple error viewer that conveys errors to users.

#import <Foundation/Foundation.h>

@interface MSErrorViewer : NSObject

extern const NSUInteger AUTH_CANCELED;

+ (id)sharedInstance;

- (void)showError:(NSError *)error;

@end