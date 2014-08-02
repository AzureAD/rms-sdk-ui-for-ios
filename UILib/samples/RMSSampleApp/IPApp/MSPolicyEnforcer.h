/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyEnforcer.h
 *
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
