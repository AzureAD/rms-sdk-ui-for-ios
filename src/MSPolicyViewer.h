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

//MSPolicyViewer class allows to view and edit RMS user policy.
//You can call show: method to presented the policy viewer in the screen.

#import <UIKit/UIKit.h>


@class MSUserPolicy;
@class MSPolicyViewer;

@protocol MSPolicyViewerDelegate <NSObject>

@optional

- (void)willShowPolicyViewer;

- (void)didShowPolicyViewer;

- (void)willDismissPolicyViewer;

- (void)didDismissPolicyViewer;

- (void)editPermissionsTapped;

@end

@interface MSPolicyViewer : UIView

// Initializes a new policy viewer object with the specified RMS policy and user rights.
// Returns MSPolicyViewer - the new view object.

+ (MSPolicyViewer *)policyViewerWithUserPolicy:(MSUserPolicy *)userPolicy
                                  supportedAppRights:(NSArray *)supportedAppRights;

+ (NSArray *)sortRightsForDisplay:(NSArray *)supportedRights;

// Shows and presents a modal popover with the user policy details.

- (void)show;

// Dismisses the modal popover if it is currently presented.

- (void)dismiss;

// Gets an array of NSString that contains the user rights supported by the app.

@property (strong, nonatomic, readonly) NSArray/*NSString*/ *supportedRights;

// Policy viewer delegates the callbacks when the user presented a modal popover with the user policy details.

@property (assign) id<MSPolicyViewerDelegate> delegate;

// For apps that only allow to view but not to edit the policy (default: YES).
 
@property (assign, nonatomic) BOOL isPolicyEditingEnabled;

// Gets the RMS user policy for the file.

@property (strong, nonatomic, readonly) MSUserPolicy *policy;

@property (weak, nonatomic) IBOutlet UIButton *editPermissionsButton;

@end

