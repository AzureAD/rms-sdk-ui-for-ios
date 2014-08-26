/**
 * Copyright © Microsoft Corporation, All Rights Reserved
 *
 * Licensed under MICROSOFT SOFTWARE LICENSE TERMS,
 * MICROSOFT RIGHTS MANAGEMENT SERVICE SDK UI LIBRARIES;
 * You may not use this file except in compliance with the License.
 * See the license for specific language governing permissions and limitations.
 * You may obtain a copy of the license (RMS SDK UI libraries - EULA.DOCX) at the
 * root directory of this project.
 *
 * THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 * ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
 * PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
 */

#import "MSErrorViewer.h"

@implementation MSErrorViewer

const NSUInteger AUTH_CANCELED = 5001;
const NSInteger USER_CANCELED = -14;

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
    if (error.code != AUTH_CANCELED && error.code != USER_CANCELED)
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
