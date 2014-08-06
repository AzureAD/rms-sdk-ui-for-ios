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

#import "MSPolicyPickHelper.h"
#import "MSResourcesUtils.h"
#import "MSModalPopover.h"
#import "MSTemplatesViewController.h"

@interface MSPolicyPickHelper()

@property (strong, nonatomic) MSTemplatesViewController *templatesViewController;
@property (strong, nonatomic) MSModalPopover *modalPopover;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong) MSPolicyPicker *policyPicker;

@end

NSString *const kTemplatesNavigator = @"TemplatesNavigator";

@implementation MSPolicyPickHelper

- (id)initWithPolicyPicker:(MSPolicyPicker *)policyPicker
{
    if (self = [super init])
    {
        _policyPicker = policyPicker;
    }
    
    return self;
}

// Main method - presents the templatesViewController
- (void)runPickTemplateUI:(MSTemplateDescriptor *)currentPolicyInfo templates:(NSArray *)templates
{
    self.navigationController = [[MSResourcesUtils storyboard] instantiateViewControllerWithIdentifier:kTemplatesNavigator];
    self.templatesViewController = (MSTemplatesViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    
    self.templatesViewController.currentPolicyInfo = currentPolicyInfo;
    
    self.templatesViewController.templates = templates;
    self.templatesViewController.delegate = self;
    MSPolicyPickHelper * __block blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

            if ([blockSelf.pickTemplateDelegate respondsToSelector:@selector(templatesViewWillLoad:)])
            {
                [blockSelf.pickTemplateDelegate templatesViewWillLoad:blockSelf.templatesViewController];
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:self.navigationController animated:YES completion:nil];
            }
            else
            {
                blockSelf.modalPopover = [[MSModalPopover alloc] initWithContentView:self.navigationController.view];
                blockSelf.modalPopover.delegate = blockSelf;
                [blockSelf.modalPopover show];
            }
        blockSelf = nil;
        });
}

- (void)dealloc
{
    [_modalPopover setDelegate:nil];
    [_templatesViewController setDelegate:nil];
}

- (void)cancel
{
    NSLog(@"We are in PolicyPickHelper cancel");
    [self didUserCancelSelectTemplate:self.templatesViewController];
}

#pragma mark - TemplatesViewControllerDelegate
// UI Specific logic and then calls the delegate to perform the general logic
- (void)didUserSelectTemplate:(MSTemplateDescriptor *)template isCustom:(BOOL)isCustom controller:(MSTemplatesViewController *)sender
{
    [self.pickTemplateDelegate didUserSelectTemplate:template isCustom:isCustom controller:sender];
    [self dismissTemplatesView];
}

- (void)didUserCancelSelectTemplate:(MSTemplatesViewController *)sender
{
    if (sender == nil)
    {
        sender = self.templatesViewController;
    }
    [self.pickTemplateDelegate didUserCancelSelectTemplate:sender];
    [self dismissTemplatesView];
}

- (void)dismissTemplatesView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        MSPolicyPicker * __block blockPolicyPicker = self.policyPicker;
        MSPolicyPickHelper * __block blockSelf = self;
        [blockSelf.navigationController dismissViewControllerAnimated:YES completion:^(){
            // templatesViewClosed: is an optional protocol method
            if ([blockSelf.pickTemplateDelegate respondsToSelector:@selector(templatesViewClosed:)])
            {
                [blockSelf.pickTemplateDelegate templatesViewClosed:blockSelf.templatesViewController];
            }
            
            blockSelf.navigationController = nil;
            blockSelf.templatesViewController = nil;
            blockSelf = nil;
            blockPolicyPicker = nil;
        }];
    }
    else
    {
        [self.modalPopover dismissAnimated:YES];
        // delegate method templatesViewClosed: will be called from didDismissModalPopover: method
    }
    
    self.templatesViewController = nil;
}

#pragma mark - MSModalPopoverDelegate

- (void)didDismissModalPopover:(MSModalPopover *)view
{
    // templatesViewClosed: is an optional protocol method
    if ([self.pickTemplateDelegate respondsToSelector:@selector(templatesViewClosed:)])
    {
        [self.pickTemplateDelegate templatesViewClosed:self.templatesViewController];
    }
}

- (void)didDismissModalPopoverOnBackgroundTap:(MSModalPopover *)view
{
    // When the user clicks outside the policy picker modal popover,
    // it is necessary to manually implement cancel template selection behavior
    [self.pickTemplateDelegate didUserCancelSelectTemplate:self.templatesViewController];
    
    self.templatesViewController = nil;
}

@end
