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

#import "MSConsentsViewController.h"
#import "MSResourcesUtils.h"

@interface MSConsentsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@property (weak, nonatomic) IBOutlet UILabel *serviceUrlConsentLabel;
@property (weak, nonatomic) IBOutlet UITableView *urlsTableView;

@property (weak, nonatomic) IBOutlet UILabel *documentTrackingConsentLabel;

@property (weak, nonatomic) IBOutlet UIView *toggleSwitchAndLabelView;
@property (weak, nonatomic) IBOutlet UISwitch *dontShowThisAgainSwitch;

@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceUrlConsentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceUrlConsentLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlsTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentTrackingConsentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentTrackingConsentLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toggleSwitchAndLabelViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyButtonBottomConstraint;

@property (strong, nonatomic) NSArray *urls;
@property (nonatomic) MSConsentViewType currentConsentViewType;
@property (nonatomic) BOOL needtoHideNavigationBarOnExit;
@property (nonatomic) UIInterfaceOrientation currentOrientation;

- (IBAction)onCancelTapped:(id)sender;
- (IBAction)onAcceptTapped:(id)sender;
- (IBAction)onDontShowAgainTapped:(id)sender;
- (IBAction)onPrivacyTapped:(id)sender;
- (IBAction)onHelpTapped:(id)sender;

@end

static NSString *const kDisplayCellID = @"UrlCell";
static NSString *const kFontRegular = @"HelveticaNeue";
static NSString *const kFontBold = @"HelveticaNeue-Bold";
const static float URL_TABLEVIEWCELL_MARGINS = 22.0f;
const static float LABEL_VERTICAL_SPACING = 20.0f;
const static float LABEL_MARGINS = 12.0f;
const static float LABEL_FONT_SIZE = 15.0f;
const static float INFINITE_HEIGHT = 20000.0f;

@implementation MSConsentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"MSConsentsViewController initWithNibName called");
        self.needtoHideNavigationBarOnExit = NO;
        self.currentConsentViewType = MSDocumentTrackingAndServiceURLConsentView;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"MSConsentsViewController initWithCoder called");
        self.needtoHideNavigationBarOnExit = NO;
        self.currentConsentViewType = MSDocumentTrackingAndServiceURLConsentView;
    }
    return self;
}

#pragma mark - Private methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.urlsTableView.delegate = self;
    self.urlsTableView.dataSource = self;
    self.currentOrientation = UIDeviceOrientationUnknown;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIInterfaceOrientation latestOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.currentOrientation != latestOrientation)
    {
        NSLog(@"Need to update constraints");
        self.currentOrientation = latestOrientation;
        [self setConstraintsBasedOnConsentViewType];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBar.isHidden)
    {
        NSLog(@"needtoHideNavigationBarOnExit");
        self.needtoHideNavigationBarOnExit = YES;
        self.navigationController.navigationBarHidden = NO;
    }
    
    [self setConstraintsBasedOnConsentViewType];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.needtoHideNavigationBarOnExit == YES)
    {
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - Public methods

- (void)setupConsentViewFor:(MSConsentViewType)viewType withUrls:(NSArray *)urls
{
    self.currentConsentViewType = viewType;
    self.urls = urls;
}

#pragma mark - UI actions

- (IBAction)onCancelTapped:(id)sender
{
    NSLog(@"Cancel tapped..");
    if (self.delegate != nil)
    {
        [self.delegate onConsentActionTapped:NO showAgain:!(self.dontShowThisAgainSwitch.isOn)];
    }
}

- (IBAction)onAcceptTapped:(id)sender
{
    NSLog(@"Accept tapped..");
    if (self.delegate != nil)
    {
        [self.delegate onConsentActionTapped:YES showAgain:!(self.dontShowThisAgainSwitch.isOn)];
    }
}

- (IBAction)onDontShowAgainTapped:(id)sender
{
    NSLog(@"Don't Show Again tapped.. Current state is: %d", self.dontShowThisAgainSwitch.isOn);
}

- (IBAction)onPrivacyTapped:(id)sender
{
    NSLog(@"Privacy tapped..");
    // open the link in Safari app and moves our app to the background
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://go.microsoft.com/fwlink/?LinkId=317563"]];
}

- (IBAction)onHelpTapped:(id)sender
{
    NSLog(@"Help tapped..");
    // open the link in Safari app and moves our app to the background
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://go.microsoft.com/fwlink/?LinkId=324513"]];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (int32_t)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int32_t)tableView:(UITableView *)tableView numberOfRowsInSection:(int32_t)section
{
    return self.urls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[self.urls objectAtIndex:indexPath.row] absoluteString];
    
    NSUInteger wrappedheight = [self wrappedHeightForText:cellText width:self.urlsTableView.frame.size.width
                                                     font:kFontBold fontSize:LABEL_FONT_SIZE
                                            lineBreakMode:NSLineBreakByCharWrapping];
    
    return wrappedheight + URL_TABLEVIEWCELL_MARGINS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlForRow = [[self.urls objectAtIndex:indexPath.row] absoluteString];
    UIFont *customFont = [UIFont fontWithName:kFontBold size:LABEL_FONT_SIZE];
    UITableViewCell *cell = [self.urlsTableView dequeueReusableCellWithIdentifier:kDisplayCellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCellID];
    }
    
    cell.textLabel.text = urlForRow;
    cell.textLabel.font = customFont;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.backgroundView =  [[UIView alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma - Private helper methods

- (void)setConstraintsBasedOnConsentViewType
{
    if (self.currentConsentViewType == MSDocumentTrackingConsentView)
    {
        [self setConstraintsForDocumentTrackingConsent];
    }
    else if (self.currentConsentViewType == MSServiceURLConsentView)
    {
        [self setConstraintsForServiceURLConsent];
    }
    else if (self.currentConsentViewType == MSDocumentTrackingAndServiceURLConsentView)
    {
        [self setConstraintsForDocumentTrackingAndServiceURLConsent];
    }
    else
    {
        NSLog(@"Unknown consent view type: %d", self.currentConsentViewType);
    }
}

- (void)setConstraintsForDocumentTrackingConsent
{
    NSLog(@"setConstraintsForDocumentTrackingConsent called");
    
    // The table is not shown for this type of a consent
    // |------------|
    // |btn      btn|
    // |------------|
    // |   label    |
    // |            |
    // | switchView |
    // |            |
    // |            |
    // |            |
    // |            |
    // |            |
    // | btn btn    |
    // |------------|
    
    self.serviceUrlConsentLabel.hidden = YES;
    self.urlsTableView.hidden = YES;
    self.documentTrackingConsentLabel.hidden = NO;
    
    self.documentTrackingConsentLabelHeightConstraint.constant = [self wrappedHeightForLabel:self.documentTrackingConsentLabel];
    
    self.documentTrackingConsentLabelTopConstraint.constant = LABEL_VERTICAL_SPACING;
    
    self.toggleSwitchAndLabelViewTopConstraint.constant = self.documentTrackingConsentLabelTopConstraint.constant
    + self.documentTrackingConsentLabelHeightConstraint.constant
    + LABEL_VERTICAL_SPACING;
}

- (void)setConstraintsForServiceURLConsent
{
    NSLog(@"setConstraintsForServiceURLConsent called");
    
    // |------------|
    // |btn      btn|
    // |------------|
    // |   label    |
    // |            |
    // |  urlTable  |
    // |            |
    // | switchView |
    // |            |
    // |            |
    // |            |
    // | btn btn    |
    // |------------|
    
    self.serviceUrlConsentLabel.hidden = NO;
    self.urlsTableView.hidden = NO;
    self.documentTrackingConsentLabel.hidden = YES;
    
    self.serviceUrlConsentLabelHeightConstraint.constant = [self wrappedHeightForLabel:self.serviceUrlConsentLabel];
    
    [self.urlsTableView reloadData];
    [self wrapUrlsTableIfPossible];
    
    self.serviceUrlConsentLabelTopConstraint.constant = LABEL_VERTICAL_SPACING;
    
    self.toggleSwitchAndLabelViewTopConstraint.constant = self.serviceUrlConsentLabelTopConstraint.constant
                                                            + self.serviceUrlConsentLabelHeightConstraint.constant
                                                            + LABEL_VERTICAL_SPACING
                                                            + self.urlsTableViewHeightConstraint.constant
                                                            +LABEL_VERTICAL_SPACING;
}

- (void)setConstraintsForDocumentTrackingAndServiceURLConsent
{
    NSLog(@"setConstraintsForDocumentTrackingAndServiceURLConsent called");
    
    // |------------|
    // |btn      btn|
    // |------------|
    // |   label    |
    // |            |
    // |  urlTable  |
    // |            |
    // |   label    |
    // |            |
    // | switchView |
    // |            |
    // | btn btn    |
    // |------------|
    
    self.serviceUrlConsentLabel.hidden = NO;
    self.urlsTableView.hidden = NO;
    self.documentTrackingConsentLabel.hidden = NO;
    
    self.serviceUrlConsentLabelHeightConstraint.constant = [self wrappedHeightForLabel:self.serviceUrlConsentLabel];
    
    self.documentTrackingConsentLabelHeightConstraint.constant = [self wrappedHeightForLabel:self.documentTrackingConsentLabel];
    
    [self.urlsTableView reloadData];
    [self wrapUrlsTableIfPossible];
    
    // All views until the urlsTable are fine. Ones below need to update Y constraints
    self.documentTrackingConsentLabelTopConstraint.constant = self.serviceUrlConsentLabelTopConstraint.constant
    + self.serviceUrlConsentLabelHeightConstraint.constant
    + LABEL_VERTICAL_SPACING
    + self.urlsTableViewHeightConstraint.constant
    + LABEL_VERTICAL_SPACING;
    
    self.toggleSwitchAndLabelViewTopConstraint.constant = self.documentTrackingConsentLabelTopConstraint.constant
    + self.documentTrackingConsentLabelHeightConstraint.constant
    + LABEL_VERTICAL_SPACING;
}

- (void)wrapUrlsTableIfPossible
{
    // Check if the urlsTable can be compressed vertically
    NSUInteger totalTableHeight = [self wrappedHeightForUrlsTable];
    NSUInteger maxTableHeight = [self maxHeightForUrlsTable];
    if (totalTableHeight < maxTableHeight)
    {
        NSLog(@"Table can be shrunk to %d from the maximum of %d", totalTableHeight, maxTableHeight);
        self.urlsTableViewHeightConstraint.constant = totalTableHeight;
    } else
    {
        NSLog(@"Table is at its maximum height of %d", maxTableHeight);
        self.urlsTableViewHeightConstraint.constant = maxTableHeight;
    }
}

- (NSUInteger)wrappedHeightForUrlsTable
{
    NSUInteger totalHeight = 0;
    
    // sum the total of all section heights
    for (int i = 0; i < [self.urlsTableView numberOfSections]; i++)
    {
        CGRect sectionRect = [self.urlsTableView rectForSection:i];
        totalHeight += sectionRect.size.height;
    }
    
    return totalHeight;
}

// This method returns the maximum permissible height for the urls table for the current consent view based on the type
- (NSUInteger)maxHeightForUrlsTable
{
    NSUInteger maxPermissibleHeight = 0;
    
    if (self.currentConsentViewType == MSDocumentTrackingConsentView)
    {
        // The urls table is not shown for this type of a consent view
    }
    else if (self.currentConsentViewType == MSServiceURLConsentView)
    {
        maxPermissibleHeight = self.view.frame.size.height -
        (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height
            + LABEL_VERTICAL_SPACING + self.serviceUrlConsentLabelHeightConstraint.constant
            + LABEL_VERTICAL_SPACING
            + LABEL_VERTICAL_SPACING + self.toggleSwitchAndLabelView.frame.size.height
            + LABEL_VERTICAL_SPACING + self.privacyButton.frame.size.height
            + self.privacyButtonBottomConstraint.constant);
        
    }
    else if (self.currentConsentViewType == MSDocumentTrackingAndServiceURLConsentView)
    {
        maxPermissibleHeight = self.view.frame.size.height -
            (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height
             + LABEL_VERTICAL_SPACING + self.serviceUrlConsentLabelHeightConstraint.constant
             + LABEL_VERTICAL_SPACING
             + LABEL_VERTICAL_SPACING + self.documentTrackingConsentLabelHeightConstraint.constant
             + LABEL_VERTICAL_SPACING + self.toggleSwitchAndLabelView.frame.size.height
             + LABEL_VERTICAL_SPACING + self.privacyButton.frame.size.height
             + self.privacyButtonBottomConstraint.constant);
    }
    else
    {
        NSLog(@"Unknown consent view type: %d", self.currentConsentViewType);
    }

    return maxPermissibleHeight;
}

- (NSUInteger)wrappedHeightForText:(NSString *)text width:(NSUInteger)width
                              font:(NSString *)fontName fontSize:(CGFloat)fontSize
                     lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize constraint = CGSizeMake(width, INFINITE_HEIGHT);
    CGSize size = [text sizeWithFont:[UIFont fontWithName:fontName size:fontSize]
                   constrainedToSize:constraint
                       lineBreakMode:lineBreakMode];
    
    return size.height;
}

- (NSUInteger)wrappedHeightForLabel:(UILabel *)label
{
    CGRect labelFrame = label.frame;
    NSUInteger newLabelHeight = [self wrappedHeightForText:label.text width:labelFrame.size.width
                                                      font:kFontRegular fontSize:LABEL_FONT_SIZE
                                             lineBreakMode:NSLineBreakByWordWrapping];
    
    return newLabelHeight + LABEL_MARGINS;
}

@end


















