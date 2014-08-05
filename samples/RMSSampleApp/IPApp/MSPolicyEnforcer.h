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
#import <UIKit/UIKit.h>


@class MSUserPolicy;

enum
{
    MSEnforcementActionDisable = 0,
    MSEnforcementActionDisableEdit,
    MSEnforcementActionDisableCopy
};
typedef NSUInteger MSEnforcementAction;

@interface MSPolicyEnforcer : NSObject

- (id)initWithProtectionPolicy:(MSUserPolicy *)policy;

@property (strong, nonatomic) MSUserPolicy *policy;

- (void)addRuleToControl:(UIView *)control whenNoRight:(NSString *)right doAction:(MSEnforcementAction)action;

- (void)removeAllRulesFromControl:(UIView *)control;

@end
