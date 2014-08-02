/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSPolicyEnforcer.m
 *
 */

#import <MSRightsManagement/MSProtection.h>
#import "MSPolicyEnforcer.h"


#pragma mark - MSPolicyEnforcerRule

@interface MSPolicyEnforcerRule : NSObject

- (id)initWithRight:(NSString *)right action:(MSEnforcementAction)action view:(UIView *)view;

@property (strong) NSString *right;
@property (assign) MSEnforcementAction action;
@property (strong) UIView *view;

@end

@implementation MSPolicyEnforcerRule

- (id)initWithRight:(NSString *)right action:(MSEnforcementAction)action view:(UIView *)view
{
    if (self = [super init])
    {
        _right = right;
        _action = action;
        _view = view;
    }
    
    return self;
}

@end

#pragma mark - MSPolicyEnforcer

@interface MSPolicyEnforcer()

@property (strong) NSMutableDictionary *controlRulesDict;
@property (strong) NSMutableDictionary *controlPreviousStateDict;

@end

@implementation MSPolicyEnforcer

- (id)initWithProtectionPolicy:(MSUserPolicy *)policy
{
    if (self = [super init])
    {
        _controlRulesDict = [[NSMutableDictionary alloc] init];
        _controlPreviousStateDict = [[NSMutableDictionary alloc] init];
        _policy = policy;
    }

    return self;
}

// Adds a policy enforcement rule. based on the Action to be taken when the user does not have the right
- (void)addRuleToControl:(UIView *)view whenNoRight:(NSString *)right doAction:(MSEnforcementAction)action;
{
    NSValue *controlKey = [NSValue valueWithNonretainedObject:view];
    
    if (![self.controlRulesDict objectForKey:controlKey])
    {
        [self.controlRulesDict setObject:[[NSMutableArray alloc] init] forKey:controlKey];
    }
    
    MSPolicyEnforcerRule *enforcerRule = [[MSPolicyEnforcerRule alloc] initWithRight:right action:action view:view];
    
    NSMutableArray *rules = [self.controlRulesDict objectForKey:controlKey];
    [rules addObject:enforcerRule];
    
    [self applyRule:enforcerRule];
}

// Removes policy enforcement rules associated with the specified control
- (void)removeAllRulesFromControl:(UIView *)view
{
    [self cancelActionsOnControl:view];
    
    NSValue *controlKey = [NSValue valueWithNonretainedObject:view];
    
    [self.controlRulesDict removeObjectForKey:controlKey];
    [self.controlPreviousStateDict removeObjectForKey:controlKey];
}

- (void)applyRule:(MSPolicyEnforcerRule *)rule
{
    BOOL hasRight = [self.policy accessCheck:rule.right];
    BOOL previousValue = [self applyOnControl:rule.view action:rule.action enabled:hasRight];
    [self saveControlPreviousState:rule.view forRule:rule previousState:previousValue];
}

- (void)setPolicy:(MSUserPolicy *)policy
{
    _policy = policy;
    
    // Re-evalute all rules based on the new policy
    for (NSValue *controlKey in self.controlRulesDict)
    {
        NSArray *rules = [self.controlRulesDict objectForKey:controlKey];
        for (MSPolicyEnforcerRule *rule in rules)
        {
            [self cancelActionsOnControl:rule.view];
            [self applyRule:rule];
        }
    }
}

#pragma mark - Private Methods

- (void)cancelActionsOnControl:(UIView *)view
{
    NSLog(@"Canceling actions on view: %@", view);
    
    NSValue *controlKey = [NSValue valueWithNonretainedObject:view];
    NSMutableArray *rules = [self.controlRulesDict objectForKey:controlKey];
    
    for (MSPolicyEnforcerRule *rule in rules)
    {
        BOOL previousState = [self loadControlPreviousState:view forRule:rule];
        [self applyOnControl:view action:rule.action enabled:previousState];
    }
    
    NSLog(@"Actions were cancelled successfully on view: %@", view);
}

- (BOOL)applyOnControl:(UIView *)view action:(MSEnforcementAction)action enabled:(BOOL)enabled
{
    switch (action)
    {
        case MSEnforcementActionDisable:
            return [self applyDisableOnControl:view enabled:enabled];
        case MSEnforcementActionDisableEdit:
            return [self applyDisableEditOnControl:view enabled:enabled];
        case MSEnforcementActionDisableCopy:
            return [self applyDisableCopyOnControl:view enabled:enabled];
        default:
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknown action" userInfo:nil];
        }
    }
}

- (BOOL)applyDisableOnControl:(UIView *)view enabled:(BOOL)enabled
{
    BOOL previousValue;
    
    if ([view isKindOfClass:[UIControl class]])
    {
        UIControl *control = (UIControl *)view;
        previousValue = control.enabled;
        control.enabled = enabled;
    }
    else if ([view isKindOfClass:[UIBarItem class]])
    {
        UIBarItem *barItem = (UIBarItem *)view;
        previousValue = barItem.enabled;
        barItem.enabled = enabled;
    }
    else if ([view isKindOfClass:[UITextView class]])
    {
        previousValue = [self applyDisableEditOnControl:view enabled:enabled];
    }
    else
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknown action" userInfo:nil];
    }
    
    return previousValue;
}

- (BOOL)applyDisableEditOnControl:(UIView *)view enabled:(BOOL)enabled
{
    BOOL previousValue = NO;
    
    if ([view isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)view;
        previousValue = textView.editable;
        textView.editable = enabled;
    }
    else if ([view isKindOfClass:[UITextField class]])
    {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Disabling editing on UITextField is currently not supported" userInfo:nil];
    }
    
    return previousValue;
}

- (BOOL)applyDisableCopyOnControl:(UIView *)view enabled:(BOOL)enabled
{
    // Disabling selection copy is currently not supported
    @throw [NSException exceptionWithName:NSGenericException reason:@"Disabling copy is currently not supported" userInfo:nil];
}

- (void)saveControlPreviousState:(UIView *)view forRule:(MSPolicyEnforcerRule *)rule previousState:(BOOL)previousState
{
    NSValue *controlKey = [NSValue valueWithNonretainedObject:view];
    NSValue *ruleKey = [NSValue valueWithNonretainedObject:rule];
    NSNumber *previousStateValue = [NSNumber numberWithBool:previousState];
    
    if (![self.controlPreviousStateDict objectForKey:controlKey])
    {
        [self.controlPreviousStateDict setObject:[[NSMutableDictionary alloc] init] forKey:controlKey];
    }
    
    NSMutableDictionary *rulesDict = [self.controlPreviousStateDict objectForKey:controlKey];
    [rulesDict setObject:previousStateValue forKey:ruleKey];
}

- (BOOL)loadControlPreviousState:(UIView *)view forRule:(MSPolicyEnforcerRule *)rule
{
    NSValue *controlKey = [NSValue valueWithNonretainedObject:view];
    NSValue *ruleKey = [NSValue valueWithNonretainedObject:rule];
    
    NSMutableDictionary *rulesDict = [self.controlPreviousStateDict objectForKey:controlKey];
    NSNumber *previousStateValue = [rulesDict objectForKey:ruleKey];
    
    return [previousStateValue boolValue];
}

@end
