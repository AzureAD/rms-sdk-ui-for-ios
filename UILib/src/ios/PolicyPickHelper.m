/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     PolicyPickHelper.m
 *
 */

#import "PolicyPickHelper.h"

#import "ResourcesUtils.h"
#import "MSModalPopover.h"

@interface PolicyPickHelper()

@property (strong, nonatomic) TemplatesViewController *templatesViewController;
@property (strong, nonatomic) MSModalPopover *modalPopover;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong) MSPolicyPicker *policyPicker;

@end

NSString *const kTemplatesNavigator = @"TemplatesNavigator";

@implementation PolicyPickHelper

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
    self.navigationController = [[ResourcesUtilsUI storyboard] instantiateViewControllerWithIdentifier:kTemplatesNavigator];
    self.templatesViewController = (TemplatesViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    
    self.templatesViewController.currentPolicyInfo = currentPolicyInfo;
    
    self.templatesViewController.templates = templates;
    self.templatesViewController.delegate = self;
    PolicyPickHelper * __block blockSelf = self;
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
- (void)didUserSelectTemplate:(MSTemplateDescriptor *)template isCustom:(BOOL)isCustom controller:(TemplatesViewController *)sender
{
    [self.pickTemplateDelegate didUserSelectTemplate:template isCustom:isCustom controller:sender];
    [self dismissTemplatesView];
}

- (void)didUserCancelSelectTemplate:(TemplatesViewController *)sender
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
        PolicyPickHelper * __block blockSelf = self;
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
