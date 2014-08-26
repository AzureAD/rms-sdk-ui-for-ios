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
@property (copy, nonatomic) void(^ completion)();
@property (copy, nonatomic) void(^ stateUpdateCompletion)();

@end

@implementation MSDiagnosticsConsentViewer

const static float DELAY_CONSENT_VIEWER_COMPLETION_IN_SECS = 1.0f;

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

- (void)addStateUpdateCompletionBlock:(void (^)(NSInteger buttonIndex))completion
{
    NSLog(@"Adding state update completion block to Diagnostics Consent alert view");
    self.stateUpdateCompletion = completion;
}

- (void)addCompletionBlock:(void (^)(void))completion
{
    NSLog(@"Adding completion block to Diagnostics Consent alert view");
    self.completion = completion;
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

- (void)callCompletionDelayed
{
    if (self.completion != nil)
    {
        // this delay fixes a bizzare issue that the root view controller is nil while
        // the alert view is shown, therefore we use this short delay to make sure
        // that the app and its root view controller is in a consistent state after
        // the error viewer is dismissed. (in iOS 7 the delay should be longer ~1.0sec
        // otherwise the root view controller is _UIModalItemViewController.
        double delayInSeconds = DELAY_CONSENT_VIEWER_COMPLETION_IN_SECS;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.completion();
            self.completion = nil;
        });
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"User tapped button index %d", buttonIndex);
    self.stateUpdateCompletion(buttonIndex); // notify the caller of the button tapped
    [self callCompletionDelayed]; // proceed to do execute the callback
}

@end
