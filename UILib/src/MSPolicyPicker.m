/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyPicker.m
 *
 */

#import <MSRightsManagement/MSProtection.h>

#import "MSPolicyPicker.h"


@interface MSPolicyPicker()

@property (strong) MSAsyncControl *context;
@property (strong) PolicyPickHelper *policyPickHelper;

@end

@implementation MSPolicyPicker

- (void)pickTemplateWith:(NSArray *)templates
{
    self.policyPickHelper = [[PolicyPickHelper alloc] initWithPolicyPicker:self];
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

- (void)didUserSelectTemplate:(MSTemplateDescriptor *)template isCustom:(BOOL)isCustom controller:(TemplatesViewController *)sender
{
    [self didChoosePolicyInfoToBeUsed:template isCustom:isCustom error:nil];
}

- (void)didUserCancelSelectTemplate:(TemplatesViewController *)sender
{
    NSLog(@"User cancelled Templates View");
    if ([self.delegate respondsToSelector:@selector(didCancelProtection:)]) // optional protocol method
    {
        [self.delegate didCancelProtection:self];
    }
}

- (void)templatesViewWillLoad:(TemplatesViewController *)sender
{
    if ([self.delegate respondsToSelector:@selector(willShowPolicyPickerView:)])
    {
        [self.delegate willShowPolicyPickerView:self];
    }
}

- (void)templatesViewClosed:(TemplatesViewController *)sender
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
