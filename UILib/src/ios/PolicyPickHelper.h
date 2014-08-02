/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     PolicyPickHelper.h
 *
 * Abstract: PolicyPickHelper encapsulates the UI specific logic and seperates it from the Policy Pick Flow class
 * It also implements the TemplatesViewControllerDelegate.
 *
 */


#import "TemplatesViewController.h"
#import "MSModalPopover.h"
#import "MSPolicyPicker.h"

@class PolicyPickHelper;
@class MSPolicyPicker;
@class MSTemplateDescriptor;


@interface PolicyPickHelper : NSObject <TemplatesViewControllerDelegate, MSModalPopoverDelegate>

- (void)runPickTemplateUI:(MSTemplateDescriptor *)chosenPolicyInfo templates:(NSArray *)templates;

- (id)initWithPolicyPicker:(MSPolicyPicker *)policyPicker;

- (void)cancel;

@property (assign) id<TemplatesViewControllerDelegate> pickTemplateDelegate;

@end
