/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyViewer.h
 *
 */

#import <UIKit/UIKit.h>


@class MSUserPolicy;
@class MSPolicyViewer;

@protocol MSPolicyPickerDelegate;

@protocol MSPolicyViewerDelegate <NSObject>

@optional

- (void)willShowPolicyViewer;

- (void)didShowPolicyViewer;

- (void)willDismissPolicyViewer;

- (void)didDismissPolicyViewer;

- (void)editPermissionsTapped;

@end

/*!
 @class
 @abstract
 MSPolicyViewer class allows to view and edit RMS user policy.
 You can call show: method to presented the policy viewer in the screen.
 */
@interface MSPolicyViewer : UIView


/*!
 @method
 @abstract
 Initializes a new policy viewer object with the specified RMS policy and user rights.
 Returns MSPolicyViewer - the new view object.
 @param userPolicy      The RMS user policy for the file. Initializes the policy property.
 @param supportedAppRights    An array of NSString that contains the user rights supported by the app. Initializes the supportedRights property.
 @param userId   user id with which the policy will be used.
 */
+ (MSPolicyViewer *)policyViewerWithUserPolicy:(MSUserPolicy *)userPolicy
                                  supportedAppRights:(NSArray *)supportedAppRights;

+ (NSArray *)sortRightsForDisplay:(NSArray *)supportedRights;

/*!
 @abstract
 Passes contextual information to the logger.
 */

/*!
 @abstract
 Shows and presents a modal popover with the user policy details.
 */
- (void)show;


/*!
 @abstract
 Dismisses the modal popover if it is currently presented.
 */
- (void)dismiss;

/*!
 @abstract
 Gets an array of NSString that contains the user rights supported by the app.
 */
@property (strong, nonatomic, readonly) NSArray/*NSString*/ *supportedRights;

/*!
 @abstract
 Policy viewer delegates the callbacks when the user presented a modal popover with the user policy details.
 */
@property (assign) id<MSPolicyViewerDelegate> delegate;

/*!
 @abstract
 For apps that only allow to view but not to edit the policy (default: YES).
 */
@property (assign, nonatomic) BOOL isPolicyEditingEnabled;

/*!
 @abstract
 Gets the RMS user policy for the file.
 */
@property (strong, nonatomic, readonly) MSUserPolicy *policy;

@property (weak, nonatomic) IBOutlet UIButton *editPermissionsButton;

@end

