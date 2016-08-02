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

#import <UIKit/UIKit.h>

#import "MSEmailInputViewController.h"
#import "MSResourcesUtils.h"
#import "MSEmailInputDelegate.h"

@interface MSEmailInputViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *rmsLogo;
@property (weak, nonatomic) IBOutlet UILabel *invalidEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressRequestLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (strong, nonatomic) UIActivityIndicatorView *progressIndicator;
@property (nonatomic) BOOL waitingFlag; // to record the state that we are waiting on the sdk

- (IBAction)onContinueTapped:(id)sender;
- (IBAction)onPrivacyTapped:(id)sender;
- (IBAction)onHelpTapped:(id)sender;

@end

@implementation MSEmailInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Intentionally left empty
    }

    return self;
}

#pragma mark - local helper methods

///Returns YES (true) if Email is valid
+ (BOOL)isValidEmail:(NSString *)emailString strict:(BOOL)strictFilter
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = strictFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

#pragma mark - Private methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = self.waitingFlag;
    self.navigationItem.hidesBackButton = YES;
    self.invalidEmailAddressLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI actions
- (IBAction)onContinueTapped:(id)sender
{
    NSLog(@"Continue tapped.. current email address is %@", self.emailTextField.text);
    
    // perform some basic RegEx checks to validate the email address string
    if ([MSEmailInputViewController isValidEmail:self.emailTextField.text strict:YES] != YES)
    {
        NSLog(@"Invalid email address..");
        self.invalidEmailAddressLabel.hidden = NO;
    }
    else
    {
        NSLog(@"Valid email address entered..");
        
        [self.view endEditing:YES];
        
        // Initialize the progress indicator
        if (self.progressIndicator == nil)
        {
            self.progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.progressIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
            self.progressIndicator.center = self.view.center;
            [self.view addSubview:self.progressIndicator];
            [self.progressIndicator bringSubviewToFront:self.view];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        }
        
        self.invalidEmailAddressLabel.hidden = YES;
        
        // Disable the interactive UI
        self.waitingFlag = YES;
        [self hideAllViewsOnScreen:YES];
        [self.progressIndicator startAnimating];
        [self.delegate onEmailInputTappedWithEmail:self.emailTextField.text completionBlock:^(BOOL completed){
            
            self.waitingFlag = NO;
            
            // Restore UI look and function
            [self.progressIndicator stopAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            
            if (completed == NO)
            {
                NSLog(@"Auth failed..");
                [self hideAllViewsOnScreen:NO];
            }
        }];
    }
}

- (IBAction)onPrivacyTapped:(id)sender
{
    NSLog(@"Privacy tapped..");
    // open the link in Safari app and moves our app to the background
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://go.microsoft.com/fwlink/?LinkId=317563"]];
}

- (IBAction)onHelpTapped:(id)sender
{
    NSLog(@"Help tapped..");
    // open the link in Safari app and moves our app to the background
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://go.microsoft.com/fwlink/?LinkId=324513"]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Screen touched");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Enter hit..");
    [self onContinueTapped:self];
    
    return YES;
}

#pragma mark - Helper methods

// method to hide or show all elements on screen based on input parameter
-(void)hideAllViewsOnScreen:(BOOL)hide
{
    self.navigationController.navigationBarHidden = hide;
    [self.rmsLogo setHidden:hide];
    [self.emailAddressRequestLabel setHidden:hide];
    [self.emailTextField setHidden:hide];
    [self.continueButton setHidden:hide];
    [self.privacyButton setHidden:hide];
    [self.helpButton setHidden:hide];
}

@end


