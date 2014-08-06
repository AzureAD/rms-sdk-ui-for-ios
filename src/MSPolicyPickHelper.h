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

//Abstract: PolicyPickHelper encapsulates the UI specific logic and seperates it from the Policy Pick Flow class
//It also implements the TemplatesViewControllerDelegate.


#import "MSTemplatesViewController.h"
#import "MSModalPopover.h"

@class MSPolicyPicker;
@class MSTemplateDescriptor;

@interface MSPolicyPickHelper : NSObject <MSTemplatesViewControllerDelegate, MSModalPopoverDelegate>

- (void)runPickTemplateUI:(MSTemplateDescriptor *)chosenPolicyInfo templates:(NSArray *)templates;

- (id)initWithPolicyPicker:(MSPolicyPicker *)policyPicker;

- (void)cancel;

@property (assign) id<MSTemplatesViewControllerDelegate> pickTemplateDelegate;

@end
