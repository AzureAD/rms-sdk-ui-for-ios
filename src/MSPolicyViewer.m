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

#import <QuartzCore/QuartzCore.h>
#import <MSRightsManagement/MSProtection.h>

#import "MSModalPopover.h"
#import "MSPolicyViewer.h"
#import "MSResourcesUtils.h"


#define LEADING_SPACE 12.0f
#define INFINITE_WIDTH 20000.0f
#define POLICY_VIEWER_ARBITRARY_WIDTH 50
#define POLICY_VIEWER_ARBITRARY_HEIGHT 50
#define POLICY_VIEWER_PERMISSION_ROW_HEIGHT 20
#define POLICY_VIEWER_ALPHA 0.7

@interface MSPolicyViewer () <UITableViewDelegate, UITableViewDataSource, MSModalPopoverDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPermissionsTableViewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grantedByTableViewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPermissionButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPermissionsButtonWidth;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *policyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *policyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *grantedByLabel;

@property (weak, nonatomic) IBOutlet UITableView *permissionsTableView;

- (IBAction)editPermissionsTapped:(id)sender;

@property (strong, nonatomic) NSArray *supportedRights;
@property (strong, nonatomic) NSArray *sortedSupportedRights;
@property (strong, nonatomic) MSUserPolicy *policy;
@property (strong, nonatomic) MSModalPopover *popover;

@end

static NSString *const kPolicyNavigator = @"PolicyNavigator";
static NSString *const kDisplayCellID   = @"PermissionCell";

static NSString *const kPermittedImageAsset = @"permitted";
static NSString *const kRestrictedImageAsset = @"restricted";
static NSString *const kPNG = @"png";

static const int32_t kPermissionsTable = 1109;
static const int32_t kPolicyNameTag = 1101;
static const int32_t kGrantedByTag = 1102;
static const int32_t kEditPermissionsTag = 1103;
static const int32_t kFirstRightTag = 1110;


@implementation MSPolicyViewer

#pragma mark - Public Methods

+ (MSPolicyViewer *)policyViewerWithUserPolicy:(MSUserPolicy *)userPolicy
                                supportedAppRights:(NSArray *)supportedAppRights;
{
    if ([supportedAppRights count] < 1)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"supportedAppRights cannot be empty or nil"
                                     userInfo:nil];
    }
    else if (userPolicy == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"userPolicy cannot be empty or nil"
                                     userInfo:nil];
        
    }

    UIViewController *policyViewController = [[MSResourcesUtils storyboard] instantiateViewControllerWithIdentifier:kPolicyNavigator];
    MSPolicyViewer *policyViewer = (MSPolicyViewer *)policyViewController.view;
    policyViewController = nil;
    
    if (policyViewer != nil)
    {
        policyViewer.policy = userPolicy;
        policyViewer.supportedRights = supportedAppRights;
        
        policyViewer.isPolicyEditingEnabled = YES; // default
        
        policyViewer.permissionsTableView.delegate = policyViewer;
        policyViewer.permissionsTableView.dataSource = policyViewer;
    }
    
    return policyViewer;
}

+ (NSArray *)sortRightsForDisplay:(NSArray *)supportedRights
{
    NSMutableArray *rights = [supportedRights mutableCopy];
    
    // "Full Control" rights should be never displayed
    if ([rights containsObject:[MSCommonRights owner]])
    {
        [rights removeObject:[MSCommonRights owner]];
    }
    
    // Sorts the rights for display in the following order:
    // 1. View
    // 2. Edit
    // 3. Copy (== Extract)
    // 4. Print
    // > 5. All the other rights
    NSArray *sortedArray;
    sortedArray = [rights sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                   {
                       NSString *first = (NSString *)a;
                       NSString *second = (NSString *)b;
                       if ([first isEqual:[MSCommonRights view]])
                       {
                           return NSOrderedAscending;
                       }
                       else if ([[second lowercaseString] isEqualToString:[[MSCommonRights view] lowercaseString]])
                       {
                           return NSOrderedDescending;
                       }
                       else if ([[first lowercaseString] isEqualToString:[[MSEditableDocumentRights edit] lowercaseString]])
                       {
                           return NSOrderedAscending;
                       }
                       else if ([[second lowercaseString] isEqualToString:[[MSEditableDocumentRights edit] lowercaseString]])
                       {
                           return NSOrderedDescending;
                       }
                       else if ([[first lowercaseString] isEqualToString:[[MSEditableDocumentRights extract] lowercaseString]])
                       {
                           return NSOrderedAscending;
                       }
                       else if ([[second lowercaseString] isEqualToString:[[MSEditableDocumentRights extract] lowercaseString]])
                       {
                           return NSOrderedDescending;
                       }
                       else if ([[first lowercaseString] isEqualToString:[[MSEditableDocumentRights print] lowercaseString]])
                       {
                           return NSOrderedAscending;
                       }
                       else if ([[second lowercaseString] isEqualToString:[[MSEditableDocumentRights print] lowercaseString]])
                       {
                           return NSOrderedDescending;
                       }
                       else
                       {
                           return NSOrderedAscending;
                       }
                   }];
    return sortedArray;
}

- (void)show
{
    if (self.popover == nil)
    {
        self.popover = [[MSModalPopover alloc] initWithContentView:self];
        self.popover.delegate = self;
    }
    
    [self.popover show];
}

- (void)dismiss
{
    [self.popover dismissAnimated:YES];
}

- (void)dismissWithCompletion:(void(^)())completion
{
    [self.popover dismissAnimated:YES completion:completion];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedSupportedRights.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return POLICY_VIEWER_PERMISSION_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UIImage *permittedImage = nil;
    static UIImage *restrictedImage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        permittedImage = [[UIImage alloc] initWithContentsOfFile:[[MSResourcesUtils frameworkBundle] pathForResource:kPermittedImageAsset ofType:kPNG]];
        restrictedImage = [[UIImage alloc] initWithContentsOfFile:[[MSResourcesUtils frameworkBundle] pathForResource:kRestrictedImageAsset ofType:kPNG]];
    });

    
    NSString *rightForRow = [self.sortedSupportedRights objectAtIndex:indexPath.row];
    BOOL doesUserHaveRight = [self.policy accessCheck:rightForRow];
    
    UITableViewCell *cell = [self.permissionsTableView dequeueReusableCellWithIdentifier:kDisplayCellID];
    cell.textLabel.text = LocalizeString(rightForRow, @"rights label");
    cell.textLabel.textColor = self.policyNameLabel.textColor;
    cell.textLabel.font = self.policyNameLabel.font;
    cell.textLabel.enabled = doesUserHaveRight;
    cell.tag = kFirstRightTag + indexPath.row;
    cell.imageView.image = doesUserHaveRight ? permittedImage : restrictedImage;   
    
    cell.backgroundView =  [[UIView alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - MSModalPopoverDelegate delegate

- (void)willPresentModalPopover:(MSModalPopover *)view
{
    if ([self.delegate respondsToSelector:@selector(willShowPolicyViewer)]) {
        [self.delegate willShowPolicyViewer];
    }
    
    [self configureSubViews];
}

- (void)didPresentModalPopover:(MSModalPopover *)view
{
    if ([self.delegate respondsToSelector:@selector(didShowPolicyViewer)]) {
        [self.delegate didShowPolicyViewer];
    }
}

- (void)willDismissModalPopover:(MSModalPopover *)view
{
    if ([self.delegate respondsToSelector:@selector(willDismissPolicyViewer)]) {
        [self.delegate willDismissPolicyViewer];
    }
}

- (void)didDismissModalPopover:(MSModalPopover *)view
{
    if ([self.delegate respondsToSelector:@selector(didDismissPolicyViewer)]) {
        [self.delegate didDismissPolicyViewer];
    }
}

- (void)didChangeOrienation:(MSModalPopover *)view
{
    [self configureSubViews];
}

#pragma mark - Private Methods

- (void)dealloc
{
    [_popover setDelegate:nil];
    [_permissionsTableView setDelegate:nil];
}

- (void)configureSubViews
{
    [self updateUserPolicyDisplay];
    
    BOOL isOwner = self.policy.isIssuedToOwner;
         
    self.titleLabel.text = isOwner ?
    LocalizeString(@"OwnerContent", @"The title for the policy viewer for owner user") :
    LocalizeString(@"NonOwnerContent", @"The title for the policy viewer for non-owner user");
    
    self.policyNameLabel.text = self.policy.policyName;
    self.grantedByLabel.attributedText = [self attributedGrantedByTextWithPolicy:self.policy];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // policy description is shown on iPad only (large form factor devices)
    {
        self.policyDescriptionLabel.text = self.policy.policyDescription;
    }
    
    self.grantedByLabel.hidden = isOwner;
    
    [self setEditPermissionsButtonVisibilityWithOwner:isOwner];
    
    // set the title of the "Edit permissions" button to the localized string
    NSString *editPermissionsButtonTitle = LocalizeString(@"EditPermissions", @"The title for the Edit Permissions button");
    [self.editPermissionsButton setTitle:editPermissionsButtonTitle forState:UIControlStateNormal];
    
    // get the size of the title when rendered. Then resize the button's width accordingly + padding
    CGSize titleSize = [editPermissionsButtonTitle sizeWithFont:self.editPermissionsButton.titleLabel.font];
    [self.editPermissionsButtonWidth setConstant:titleSize.width + (LEADING_SPACE * 2)];
    [self.editPermissionButtonHeight setConstant:titleSize.height + (LEADING_SPACE * 2)];
    
    // register class for cell reuse identifier
    [self.permissionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDisplayCellID];
    [self.permissionsTableView reloadData];
    
    // adjust the table view height to wrap its content
    // The policy viewer looks differently when displayed by the owner user and a non-owner user.
    // The owner will have an "Edit permissions" button, while the non-owner will have the "Granted By"
    // label. These 2 elements are of a different height, and the permissions table-view must always be
    // spaced a certain amount of pixels from the displayed element, whether it is the button or the label.
    // Because of this, we remove the constraint which constraints the table view to the invisible element,
    // leaving only the spacing constraint to the visible one.
    if (isOwner == YES)
    {
        [self removeConstraint:self.grantedByTableViewVerticalSpace];
    }
    else
    {
        [self removeConstraint:self.editPermissionsTableViewVerticalSpace];
    }
    
    self.permissionsTableView.hidden = isOwner;
    // make sure the labels wrap the text and use multiline if needed
    self.titleLabel.preferredMaxLayoutWidth = self.frame.size.width - (LEADING_SPACE * 2);
    self.policyNameLabel.preferredMaxLayoutWidth = self.frame.size.width - (LEADING_SPACE * 2);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // policy description is shown on iPad only (large form factor devices)
    {
        self.policyDescriptionLabel.preferredMaxLayoutWidth = self.frame.size.width - (LEADING_SPACE * 2);
    }
    
    self.grantedByLabel.preferredMaxLayoutWidth = self.frame.size.width - (LEADING_SPACE * 2);
    
    // add white border to the button
    [[self.editPermissionsButton layer] setBorderWidth:1.0f];
    [[self.editPermissionsButton layer] setCornerRadius:5.0f];
    [[self.editPermissionsButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    // Set UI Automation tags
    self.permissionsTableView.tag = kPermissionsTable;
    self.policyNameLabel.tag = kPolicyNameTag;
    self.grantedByLabel.tag  = kGrantedByTag;
    self.editPermissionsButton.tag = kEditPermissionsTag;
}

- (void)setEditPermissionsButtonVisibilityWithOwner:(BOOL)isOwner
{
    // the "edit" policy button should be only enabled under the following conditions:
    //   1. policyEditingEnabled property valus is TRUE
    //   2. the current user is the document's owner
    //   3. "edit permission" will be disabled in custom till we implement the custom UI in iOS.
    BOOL editPermissionsInCustomScenario = (self.policy.type == Custom) ? FALSE : TRUE;
    
    self.editPermissionsButton.hidden = !(isOwner && self.isPolicyEditingEnabled && editPermissionsInCustomScenario);
}

- (NSUInteger)wrappedHeightForPermissionsTable
{
    NSUInteger totalHeight = 0;
    
    // sum the total of all section heights
    for (int i = 0; i < [self.permissionsTableView numberOfSections]; i++)
    {
        CGRect sectionRect = [self.permissionsTableView rectForSection:i];
        totalHeight += sectionRect.size.height;
    }
    
    return totalHeight;
}

- (NSAttributedString *)attributedGrantedByTextWithPolicy:(MSUserPolicy *)userPolicy
{
    NSString *grantedByTitle = LocalizeString(@"PolicyGrantedByTitle", @"The title for the 'granted by' email section");
    
    UIFont *boldFont = self.policyNameLabel.font;
    UIFont *regularFont = self.titleLabel.font;
    
    NSDictionary *boldAttrs = @{ NSFontAttributeName : boldFont, NSForegroundColorAttributeName : self.policyNameLabel.textColor };
    NSDictionary *regularAttrs = @{ NSFontAttributeName : regularFont, NSForegroundColorAttributeName : self.policyNameLabel.textColor };
    
    const NSRange range = NSMakeRange(grantedByTitle.length + 1, self.policy.owner.length);
    
    NSString *grantedByText = [NSString stringWithFormat:@"%@ %@", grantedByTitle, self.policy.owner];
    NSMutableAttributedString *attributedGrantedByText = [[NSMutableAttributedString alloc] initWithString:grantedByText attributes:regularAttrs];
    [attributedGrantedByText setAttributes:boldAttrs range:range];
    
    return attributedGrantedByText;
}

- (NSUInteger)wrappedHeightForLabelWithFixedWidth:(UILabel *)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, INFINITE_WIDTH);
    return [label.text sizeWithFont:label.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping].height;
}

- (IBAction)editPermissionsTapped:(id)sender
{
    // disable the button to avoid double tapping
    self.editPermissionsButton.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(editPermissionsTapped)]) {
        [self.delegate editPermissionsTapped];
    }
}

- (void)updateUserPolicyDisplay
{
    self.sortedSupportedRights = [[self class] sortRightsForDisplay:self.supportedRights];
}

- (IBAction)editButtonToucUpInside:(id)sender
{
    self.editPermissionsButton.backgroundColor = [UIColor blackColor];
}

- (IBAction)editButtonTouchDown:(id)sender
{
    self.editPermissionsButton.backgroundColor = [UIColor darkGrayColor];
}

- (IBAction)editButtonTouchUpOutside:(id)sender
{
    self.editPermissionsButton.backgroundColor = [UIColor blackColor];
}

@end

