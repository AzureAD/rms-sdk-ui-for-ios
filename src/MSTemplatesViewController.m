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

#import <MSRightsManagement/MSTemplateDescriptor.h>
#import "MSTemplatesViewController.h"
#import "MSPolicyTemplateCell.h"
#import "MSResourcesUtils.h"
#import "MSModalPopover.h"

#define INFINITE_HEIGHT 20000.0f

@interface MSTemplatesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MSTemplateDescriptor *selectedPolicyInfo;

@end

static NSString *const kDisplayCellID   = @"TemplateCell";
static const int32_t kCellTagStartingRange = 1000;

@implementation MSTemplatesViewController

#pragma mark - UIViewController methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // this prevents the table view from appearing behind the navigation bar
    [self selectCurrentTemplateInTableView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];

    // since the width of the cells might change after orientation change
    // invalidate and update the constraints after the orientation change ends
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView setNeedsUpdateConstraints];
        [self.tableView setNeedsLayout];
    });
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Table view data source

- (int32_t)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int32_t)tableView:(UITableView *)tableView numberOfRowsInSection:(int32_t)section
{
    return [self.templates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPolicyTemplateCell *cell = (MSPolicyTemplateCell *)[tableView dequeueReusableCellWithIdentifier:kDisplayCellID forIndexPath:indexPath];

    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    cell.policyTitle.highlightedTextColor = [UIColor blackColor];
    cell.policyDescription.highlightedTextColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPolicyTemplateCell *policyCell = (MSPolicyTemplateCell *)cell;
    
    [self updateCellForDisplay:policyCell atIndexPath:indexPath];
}

- (IBAction)onCancel:(id)sender
{
    [self.delegate didUserCancelSelectTemplate:self];
}

- (IBAction)onDone:(id)sender
{
    //Since we do not support ad-hoc UI yet, we will always pass 'NO' for isCustom.
    [self.delegate didUserSelectTemplate:self.selectedPolicyInfo isCustom:NO controller:self];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPolicyTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCellID];
    
    MSTemplateDescriptor *template = [self.templates objectAtIndex:indexPath.row];
    
    CGSize labelPolicyTitleConstraint = CGSizeMake(self.tableView.frame.size.width - (POLICY_TITLE_PADDING * 2), INFINITE_HEIGHT);
    CGSize labelNameSize = [template.name sizeWithFont:cell.policyTitle.font constrainedToSize:labelPolicyTitleConstraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat selectedRowHeight = labelNameSize.height + CELL_CONTENT_MARGIN;
    
    if (template == self.selectedPolicyInfo)
    {
        CGSize labelDescriptionConstraint = CGSizeMake(self.tableView.frame.size.width - (POLICY_DESCRIPTION_PADDING * 2), INFINITE_HEIGHT);
        CGSize labelDescriptionSize = [template.description sizeWithFont:cell.policyDescription.font constrainedToSize:labelDescriptionConstraint lineBreakMode:NSLineBreakByWordWrapping];
        
        selectedRowHeight += labelDescriptionSize.height;
    }
    
    return selectedRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectedTemplateRowAtIndexPath:indexPath];
    
    if (indexPath != nil)
    {
        // disable UITableView animations for iOS 7 since there are currently memory leaks in their code
        // this is temporary until Apple releases a fix for this
        [UIView setAnimationsEnabled:NO];
        
        // the following two lines force the selected row to expand itself
        [self.tableView beginUpdates];
        [self.tableView endUpdates];

        // enable back the UITableView animations for iOS 7
        [UIView setAnimationsEnabled:YES];
    }
    
    // update the cell for display to show the details label since the cell is now selected
    MSPolicyTemplateCell *policyCell = (MSPolicyTemplateCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self updateCellForDisplay:policyCell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // update the cell for display to hide the details label since the cell is no longer selected
    MSPolicyTemplateCell *policyCell = (MSPolicyTemplateCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self updateCellForDisplay:policyCell atIndexPath:indexPath];
}

#pragma mark - Private methods

- (void)updateSelectedTemplateRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPolicyInfo = [self.templates objectAtIndex:indexPath.row];
    
    // "Apply" button should be enabled only if the selected template is
    // different than the previously chosen template
    self.doneButton.enabled = ((self.selectedPolicyInfo != self.currentPolicyInfo)
                               && (self.selectedPolicyInfo != nil));
    
    // "Cancel" should be always enabled,
    // though this line could be written in the storyboard, this fix a strange bug
    // that happened on Xcode 5.0 where the button's text was missing in runtime.
    self.cancelButton.enabled = YES;
}

- (void)selectCurrentTemplateInTableView
{
    // select the previously chosen template in the table view
    if (self.currentPolicyInfo != nil)
    {
        NSUInteger templateIndexInTableView = [self.templates indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[(MSTemplateDescriptor *)obj name] isEqualToString:self.currentPolicyInfo.name];
        }];
        
        if (templateIndexInTableView != NSNotFound)
        {
            NSIndexPath *selectedTemplateIndexPath = [NSIndexPath indexPathForRow:templateIndexInTableView inSection:0];
            [self updateSelectedTemplateRowAtIndexPath:selectedTemplateIndexPath];
            
            [self.tableView selectRowAtIndexPath:selectedTemplateIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            [self tableView:self.tableView didSelectRowAtIndexPath:selectedTemplateIndexPath];
        }
    }
}

- (void)updateCellForDisplay:(MSPolicyTemplateCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MSTemplateDescriptor *template = [self.templates objectAtIndex:indexPath.row];
    
    cell.policyTitle.text = template.name;
    cell.policyTitle.enabled = YES;
    cell.policyDescription.text = template.description;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // show the template description only when the cell is selected
    cell.policyDescription.hidden = !((template == self.selectedPolicyInfo) && cell.selected);
    
    // when the policy description is displayed remove the constraint that is in charge of locating the policy title
    // in the middle of the cell and add it back when the description is hidden.
    if (cell.policyDescription.hidden != YES && [cell.constraints containsObject:cell.centerLabelConstraint])
    {
        [cell removeConstraint:cell.centerLabelConstraint];
    }
    else if (cell.policyDescription.hidden == YES && ![cell.constraints containsObject:cell.centerLabelConstraint])
    {
        [cell addConstraint:cell.centerLabelConstraint];
    }
    
    [cell setNeedsUpdateConstraints];
    
    cell.policyTitle.tag = kCellTagStartingRange + indexPath.row; // for UI automation
}

@end

