/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSErrorViewer.m
 *
 */

#import "MSErrorViewer.h"

@implementation MSErrorViewer

const NSUInteger AUTH_CANCELED = 5001;

+ (id)sharedInstance
{
    static MSErrorViewer *singleton;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        singleton = [[MSErrorViewer alloc] init];
    });
    
    return singleton;
}

- (void)showError:(NSError *)error
{
    if (error.code != AUTH_CANCELED)
    {
        NSAssert([[NSThread currentThread] isMainThread], @"must be called on the main thread!");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RMS sample app"
                                                            message:[@"Microsoft Protection SDK v4.0 Error: " stringByAppendingString:error.localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
