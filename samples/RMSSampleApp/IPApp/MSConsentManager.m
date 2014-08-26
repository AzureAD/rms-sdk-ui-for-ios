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

#import "MSConsentManager.h"
#import "MSMainViewController.h"

#import <MSRightsManagementUI/MSResourcesUtils.h>
#import <MSRightsManagementUI/MSConsentsViewDelegate.h>
#import <MSRightsManagementUI/MSConsentsViewController.h>

const static NSUInteger NULL_INDEX = -1;

@interface MSConsentManager() <MSConsentsViewDelegate>

@property (atomic) BOOL currentlyWaitingOnConsents;
@property (strong, nonatomic) NSArray *currentConsents;
@property (copy, nonatomic) void (^currentConsentsCompletionBlock)(NSArray *);

@property (weak, nonatomic) MSMainViewController *mainVC;
@property (strong, nonatomic) MSConsentsViewController *consentsVC;

@end

@implementation MSConsentManager

- (id)initWithMainVC:(id)mainVC
{
    NSLog(@"Initializing MSConsentManager");
    if (self = [super init])
    {
        _mainVC = mainVC;
        _currentlyWaitingOnConsents = NO;
        _consentsVC = [[MSResourcesUtils storyboard] instantiateViewControllerWithIdentifier:@"MSConsentsViewController"];
        _consentsVC.delegate = self;
    }

    return self;
}

// MSConsentCallback method (called by the RMS SDK)
- (void)consents:(NSArray *)consents consentsCompletionBlock:(void (^)(NSArray *))consentsCompletionBlock
{    
    /* arguments: (NSArray (of *MSConsent))consents
     (void(^)(NSArray (of *MSConsent)consentsResult))consentsCompletionBlock;*/
    
    NSLog(@"MSConsentManager ConsentCallback called");

    NSAssert(self.currentlyWaitingOnConsents != YES, @"Something wrong.. we already have a set of consents we are working on..");
    
    self.currentConsents = consents;
    self.currentConsentsCompletionBlock = consentsCompletionBlock;
    
    BOOL documentTrackingConsentPresent = NO;
    BOOL serviceURLConsentPresent = NO;
    NSMutableArray *serviceURLsFromAllConsents = [[NSMutableArray alloc] init];
    
    for (MSConsent *thisConsent in consents)
    {
        if (thisConsent.type == DocumentTrackingConsent)
        {
            documentTrackingConsentPresent = YES;
        }
        else if (thisConsent.type == ServiceURLConsent)
        {
            serviceURLConsentPresent = YES;
            [serviceURLsFromAllConsents addObjectsFromArray:((MSServiceURLConsent *)thisConsent).urls];
        }
        else
        {
            NSLog(@"Unknown consent type: %d", thisConsent.type);
        }
    }
    
    if (documentTrackingConsentPresent == NO && serviceURLConsentPresent == NO)
    {
        NSLog(@"No known consent types present. Nothing to show consent view for");
    }
    else if (documentTrackingConsentPresent == YES && serviceURLConsentPresent == NO)
    {
        NSLog(@"Will show MSDocumentTrackingConsentView");
        [self showConsentViewType:MSDocumentTrackingConsentView
                             urls:nil];
    }
    else if (documentTrackingConsentPresent == NO && serviceURLConsentPresent == YES)
    {
        NSLog(@"Will show MSServiceURLConsentView");
        [self showConsentViewType:MSServiceURLConsentView
                             urls:serviceURLsFromAllConsents];
    }
    else if (documentTrackingConsentPresent == YES && serviceURLConsentPresent == YES)
    {
        NSLog(@"Will show MSDocumentTrackingAndServiceURLConsentView");
        [self showConsentViewType:MSDocumentTrackingAndServiceURLConsentView
                             urls:serviceURLsFromAllConsents];
    }
}

#pragma - UI methods

- (void)showConsentViewType:(NSUInteger)viewType urls:(NSArray *)serviceUrls
{
    [self.consentsVC setupConsentViewFor:(MSConsentViewType)viewType withUrls:serviceUrls];
    [self.mainVC.navigationController pushViewController:self.consentsVC animated:YES];
}

// Hide the consent view shown on screen
- (void)hideConsentView
{
    [self.mainVC.navigationController popViewControllerAnimated:YES];
}

#pragma - MSConsentDelegate

- (void)onConsentActionTapped:(BOOL)consentAccepted showAgain:(BOOL)consentShowAgain
{
    NSLog(@"onConsentActionTapped called with consentAccepted: %d, consentShowAgain: %d",
          consentAccepted, consentShowAgain);
    
    [self hideConsentView];
    
    for (MSConsent *thisConsent in self.currentConsents)
    {
        thisConsent.consentResult.accepted = consentAccepted;
        thisConsent.consentResult.showAgain = consentShowAgain;
    }
    
    self.currentConsentsCompletionBlock(self.currentConsents);
    self.currentlyWaitingOnConsents = NO;}

@end
