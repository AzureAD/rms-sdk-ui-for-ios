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

#import <MSRightsManagement/MSRightsManagement.h>

#import "MSPolicyPicker.h"
#import "MSPolicyPickHelper.h"

@interface MSPolicyPicker()

@property (strong) MSPolicyPickHelper *policyPickHelper;

@end

@implementation MSPolicyPicker

- (void)pickTemplateWith:(NSArray *)templates
{
    self.policyPickHelper = [[MSPolicyPickHelper alloc] initWithPolicyPicker:self];
    self.policyPickHelper.pickTemplateDelegate = self;
    [self.policyPickHelper runPickTemplateUI:self.policy.templateDescriptor templates:templates];
}

- (void)didChoosePolicyInfoToBeUsed:(MSTemplateDescriptor *)templateDescriptor isCustom:(BOOL)isCustom error:(NSError *)error
{
    if (error != nil)
    {
        [self finishWithTemplateDescriptor:nil error:error];
    }
    else
    {
        [self finishWithTemplateDescriptor:templateDescriptor error:error];
    }
}

- (void)cancel
{
    NSLog(@"We are in PolicyPicker cancel");
    [self.policyPickHelper cancel];
}

#pragma mark - TemplatesViewControllerDelegate
// These methods are implemented here (non specific logic) and in PolicyPickHelper (UI specific logic)

- (void)didUserSelectTemplate:(MSTemplateDescriptor *)template isCustom:(BOOL)isCustom controller:(MSTemplatesViewController *)sender
{
    [self didChoosePolicyInfoToBeUsed:template isCustom:isCustom error:nil];
}

- (void)didUserCancelSelectTemplate:(MSTemplatesViewController *)sender
{
    NSLog(@"User cancelled Templates View");
    if ([self.delegate respondsToSelector:@selector(didCancelProtection:)]) // optional protocol method
    {
        [self.delegate didCancelProtection:self];
    }
}

- (void)templatesViewWillLoad:(MSTemplatesViewController *)sender
{
    if ([self.delegate respondsToSelector:@selector(willShowPolicyPickerView:)])
    {
        [self.delegate willShowPolicyPickerView:self];
    }
}

- (void)templatesViewClosed:(MSTemplatesViewController *)sender
{
    if ([self.delegate respondsToSelector:@selector(didDismissPolicyPickerView:)])
    {
        [self.delegate didDismissPolicyPickerView:self];
    }
}

- (void)finishWithTemplateDescriptor:(MSTemplateDescriptor *)templateDescriptor error:(NSError *)error
{
    // translates the completion block results into a delegate call
    // each condition is responsible on the appropriate delegate method
    
    if (templateDescriptor != nil)
    {
        [self.delegate didSelectProtection:templateDescriptor picker:self];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(didFailWithError:picker:)]) // optional protocol method
        {
            [self.delegate didFailWithError:error picker:self];
        }
    }
}

@end
