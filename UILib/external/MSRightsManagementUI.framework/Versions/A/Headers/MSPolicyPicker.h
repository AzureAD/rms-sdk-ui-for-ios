/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyPicker.h
 *
 */

#import <Foundation/Foundation.h>
#import "PolicyPickHelper.h"

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237816(v=vs.85).aspx
 
 */
@class MSUserPolicy;

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237785(v=vs.85).aspx
 
 */
@class MSPolicyPicker;

@class MSCustomPolicySettings;

/*!
 
 @protocol
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237782(v=vs.85).aspx
 
 */
@protocol MSPolicyPickerDelegate <NSObject>

@required

- (void)didSelectProtection:(MSTemplateDescriptor *)templateDescriptor picker:(MSPolicyPicker *)sender;

@optional

- (void)didCancelProtection:(MSPolicyPicker *)sender;

- (void)didFailWithError:(NSError *)error picker:(MSPolicyPicker *)sender;

- (void)willShowPolicyPickerView:(MSPolicyPicker *)sender;

- (void)didDismissPolicyPickerView:(MSPolicyPicker *)sender;

@end

/*!
 
 @class
 @see documentation at http://msdn.microsoft.com/en-us/library/windows/desktop/dn237785(v=vs.85).aspx
 
 */
@interface MSPolicyPicker : NSObject <TemplatesViewControllerDelegate>

- (void)pickTemplateWith:(NSArray *)templates;
- (void)cancel;

@property (strong, nonatomic) MSUserPolicy *policy;
@property (assign) id<MSPolicyPickerDelegate> delegate;

@end
