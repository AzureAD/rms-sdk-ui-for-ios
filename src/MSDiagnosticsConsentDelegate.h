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

//  Abstract: Protocol to react to user accepting or rejecting a consent request on behalf of the SDK
//      to upload diagnostics logs. The decision is cached within the app's sandbox.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSDiagnosticsConsentAction) {
    MSDiagnosticsConsentActionYes = 0,
    MSDiagnosticsConsentActionNo = 1,
    MSDiagnosticsConsentActionLearnMore = 2, // point the user to a help/documentation page
};

@protocol MSDiagnosticsConsentDelegate <NSObject>

@required

- (void)onDiagnosticsConsentActionTapped:(MSDiagnosticsConsentAction)diagnosticsConsentAction;

@end
