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

// MSConsentManager is a class that implements the MSConsentCallback protocol.
// This class also shows the consent UI and conveys the decision back to the SDK

#import <MSRightsManagement/MSConsent.h>
#import <MSRightsManagement/MSConsentCallback.h>
#import <Foundation/Foundation.h>

@interface MSConsentManager : NSObject <MSConsentCallback>

- (id)initWithMainVC:(id)mainVC;
- (void)consents:(NSArray *)consents consentsCompletionBlock:(void (^)(NSArray *))consentsCompletionBlock;

@end
