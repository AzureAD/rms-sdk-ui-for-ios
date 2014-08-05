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

#import <Foundation/Foundation.h>
#import "MSTemplatesViewController.h"

@class MSUserPolicy;
@class MSPolicyPicker;

@protocol MSPolicyPickerDelegate <NSObject>

@required

- (void)didSelectProtection:(MSTemplateDescriptor *)templateDescriptor picker:(MSPolicyPicker *)sender;

@optional

- (void)didCancelProtection:(MSPolicyPicker *)sender;

- (void)didFailWithError:(NSError *)error picker:(MSPolicyPicker *)sender;

- (void)willShowPolicyPickerView:(MSPolicyPicker *)sender;

- (void)didDismissPolicyPickerView:(MSPolicyPicker *)sender;

@end

@interface MSPolicyPicker : NSObject <MSTemplatesViewControllerDelegate>

- (void)pickTemplateWith:(NSArray *)templates;
- (void)cancel;

@property (strong, nonatomic) MSUserPolicy *policy;
@property (assign) id<MSPolicyPickerDelegate> delegate;

@end
