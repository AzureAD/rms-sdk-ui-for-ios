/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyPicker.h
 *
 */

#import <Foundation/Foundation.h>
#import "PolicyPickHelper.h"

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

@interface MSPolicyPicker : NSObject <TemplatesViewControllerDelegate>

- (void)pickTemplateWith:(NSArray *)templates;
- (void)cancel;

@property (strong, nonatomic) MSUserPolicy *policy;
@property (assign) id<MSPolicyPickerDelegate> delegate;

@end
