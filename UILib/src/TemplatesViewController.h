/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     TemplatesViewController.h
 *
 *  Abstract: Templates View Controller.
 *  Allows the user to choose which template from the available templates list
 *  he would like to use to protect his content.
 *
 */


#import <UIKit/UIKit.h>

@class MSTemplateDescriptor;
@class TemplatesViewController;

@protocol TemplatesViewControllerDelegate <NSObject>

- (void)didUserSelectTemplate:(MSTemplateDescriptor *)policyInfo isCustom:(BOOL)isCustom controller:(TemplatesViewController *)sender;
- (void)didUserCancelSelectTemplate:(TemplatesViewController *)sender;

@optional

- (void)templatesViewWillLoad:(TemplatesViewController *)sender;
- (void)templatesViewClosed:(TemplatesViewController *)sender;

@end

/*
 TemplatesViewController manages a view which is consisted of a navigation bar and a table view.
 It is atually acts almost like an UITableViewController but except for that its view is not dependent on UINavigationBarController
 And thus can show its view inside a modal popover.
 */
@interface TemplatesViewController : UITableViewController

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;

@property (nonatomic, strong) MSTemplateDescriptor *currentPolicyInfo; // the previously selected policy info (before the policy picker started)
@property (nonatomic, strong) NSArray *templates;
@property (assign) id<TemplatesViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end
