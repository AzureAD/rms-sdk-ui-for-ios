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

#import <UIKit/UIKit.h>

#import "MSDiagnosticsConsentViewer.h"
#import "MSResourcesUtils.h"

@interface MSDiagnosticsConsentViewer() <UIAlertViewDelegate>

@property (strong) UIAlertView *alertView;

@end

@implementation MSDiagnosticsConsentViewer

+ (id)sharedInstance
{
    static MSDiagnosticsConsentViewer *singleton;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSLog(@"MSDiagnosticsConsentViewer first init");
        singleton = [[MSDiagnosticsConsentViewer alloc] init];
    });
    
    return singleton;
}

- (void)showDiagnosticsConsent
{
    NSLog(@"Showing Diagnostics Consent alert view");
    
    self.alertView = [[UIAlertView alloc]
                        initWithTitle:LocalizeString(@"DiagnosticsConsentTitle", @"Improve RMS")
                        message:LocalizeString(@"DiagnosticsConsentText", @"Description of the alert")
                        delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:LocalizeString(@"DiagnosticsConsentYesButton", @"Yes"),
                            LocalizeString(@"DiagnosticsConsentNoButton", @"No thanks"),
                            LocalizeString(@"DiagnosticsConsentLearnButton", @"Learn More"), nil];
    
    self.alertView.cancelButtonIndex = -1; // disable the cancel button
    [self.alertView show];
}

- (BOOL)alertViewActive
{
    return self.alertView.visible;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"User tapped button index %ld", (long)buttonIndex);
    if (self.delegate != nil)
    {
        NSLog(@"Will call delegate's onDiagnosticsConsentActionTapped");
        [self.delegate onDiagnosticsConsentActionTapped:buttonIndex];
    }
}

@end
