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

//  Abstract: MSDiagnosticsConsentViewer class enables interface for customer experience improvement.
//      The app can make use of this to enable diagnostic logs.

#import <Foundation/Foundation.h>

@interface MSDiagnosticsConsentViewer : NSObject

+ (id)sharedInstance;

- (void)showDiagnosticsConsent;

// This block supplied will be called when the user makes a choice on the consent
- (void)addStateUpdateCompletionBlock:(void (^)(NSInteger buttonIndex))completion;

// This block supplied will be called after the state update block is called
- (void)addCompletionBlock:(void (^)(void))completion;

- (BOOL)alertViewActive;

@end
