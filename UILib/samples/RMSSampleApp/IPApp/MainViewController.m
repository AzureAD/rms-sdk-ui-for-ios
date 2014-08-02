/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MainViewController.m
 *
 */

// Protection imports
#import <MSRightsManagement/MSProtection.h>
// Custom protection imports
#import <MSRightsManagement/MSCustomProtection.h>

#import <MSRightsManagementUI/MSPolicyViewer.h>
#import <MSRightsManagementUI/MSPolicyPicker.h>
#import <MSRightsManagementUI/MSEmailInputViewController.h>
#import <MSRightsManagementUI/ResourcesUtils.h>

#import <ADALiOS/ADAuthenticationContext.h>

// App imports
#import "MainViewController.h"
#import "MSErrorViewer.h"
#import "StringEncodingUtils.h"
#import "MSPolicyEnforcer.h"

@interface MainViewController () <MSPolicyPickerDelegate, MSPolicyViewerDelegate, MSAuthenticationCallback, MSEmailInputDelegate>

@property (strong, nonatomic) MSEmailInputViewController *emailInputViewController;
// Protection related properties
@property (strong, nonatomic) MSPolicyPicker *policyPicker;
@property (strong, nonatomic) MSUserPolicy *userPolicy;
@property (strong, nonatomic) MSPolicyViewer *policyViewer;
@property (strong, nonatomic) MSPolicyEnforcer *policyEnforcer;
@property (strong, nonatomic) NSArray *appSupportedRights;
@property (strong, nonatomic) NSString *userId;

// App related properties
@property (strong, nonatomic) UIBarButtonItem *lockBarButtonItem;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) UIBarButtonItem *mailBarButtonItem;
@property (assign) NSStringEncoding stringEncoding;

@end

@implementation MainViewController

// Custom Protection consts
static const NSUInteger kDeprecatedAlgAlignement = 16;

// Icon names
static NSString *sLightMailIconPath = @"mail_white.png";
static NSString *sDarkMailIconPath  = @"mail_black.png";
static NSString *sLightLockIconPath = @"lock_white.png";
static NSString *sDarkLockIconPath  = @"lock_black.png";

// Default file name
static NSString *kDefaultTextFileExtension = @"txt";
static NSString *kDefaultProtectedTextFileExtension = @"ptxt";
static NSString *kCustomFileExtension = @"txt2";
static NSString *kDefaultFileName = @"sample";

// Default email messages.
static NSString *sEmailSubject = @"Test email From RMS sample app";
static NSString *sEmailBody    = @"This is an email from the RMS sample app with an attachment";

// Text View access denied message.
static NSString *sNoViewRightsMessage = @"Access denied, Insufficient Rights to view message";

// Text View unsupported file content type.
static NSString *sContentTypeNotSupportedMessage = @"The original file extension is not supported";

static NSString *sUserCancelledAuthenticationMessage = @"Authentication operation was cancelled";

static NSUInteger kProtectedFileSelected = 0;
static NSUInteger kCustomProtectedFileSelected = 1;
static NSUInteger kCustomProtectedFileWithDeprecatedAlgorithmSelected = 2;

#pragma mark - Protection related methods

// This is a protected document if a user policy exists
- (BOOL)isProtected
{
    return (self.userPolicy != nil);
}

- (void)setupAppSupportedRights
{
    // The list of rights which the application supports
    self.appSupportedRights = @[[MSCommonRights view],
                                [MSEditableDocumentRights edit],
                                [MSEditableDocumentRights extract],
                                [MSCommonRights owner]];
}

// Called by AppDelegate after "Open in..." of ptxt or txt2 attachment - Starts the consumption flow
// Works with both RMS-protected files and plaintext files.
- (void)openURL:(NSURL *)attachmentUrl
{
    NSLog(@"Opening file from url: %@",attachmentUrl);
    // Restore the app to its initial state
    [self cleanup];
    
    // Hide the keyboard
    [self.txtView resignFirstResponder];
    [self startAnimationAndHideButtons];
    
    // Dismiss the current policy viewer if it exists
    [self.policyViewer dismiss];
    
    // If the attachment is a custom protected file
    if ([[attachmentUrl pathExtension] isEqualToString:kCustomFileExtension])
    {
        [self handleCustomProtectedFile:[attachmentUrl path]];
    }
    //----------------------------------------------------------------------
    //
    // *** RMS-specific code ***
    //
    // Code that loads protected files into memory
    //
    //  *  create an MSProtectedData that addresses the entire contents of a file (protected or unprotected)
    //  *  See http://msdn.microsoft.com/en-us/library/windows/desktop/dn758348(v=vs.85).aspx for more details
    //
    
    [MSProtectedData protectedDataWithProtectedFile:[attachmentUrl path]
                                             userId:self.userId
                             authenticationCallback:self
                                            options:Default
                                    completionBlock:^(MSProtectedData *data, NSError *error)
     {
         [self updateCurrentProtectionSegmentedControl:data.userPolicy withCustomProtection:NO];
         dispatch_async(dispatch_get_main_queue(),^{
                            [self onConsumptionWithData:data error:error];
         });
     }];
    //
    // *** END RMS-specific code ***
    //
    //------------------------------------------------------------
}

- (void)startPublishingFlow
{
    [self startAnimationAndHideButtons];
    
    //----------------------------------------------------------------------
    //
    // *** RMS-specific code ***
    //
    //  Code that gets user's templats
    //
    //  *  See http://msdn.microsoft.com/en-us/library/windows/desktop/dn790785(v=vs.85).aspx for more details
    //
    
    self.policyPicker = [[MSPolicyPicker alloc] init];
    self.policyPicker.policy =  self.userPolicy;
    self.policyPicker.delegate = self;
    
    if (self.userId != nil)
    {
        [MSTemplateDescriptor templateListWithUserId:self.userId authenticationCallback:self completionBlock:^(NSArray *templates, NSError *error) {
            
            if (error != nil)
            {
                NSLog(@"Failed to get templates with error: %@", error);
                [[MSErrorViewer sharedInstance] showError:error];
                [self stopAnimationAndShowButtons];
            }
            else
            {
                [self.policyPicker pickTemplateWith:templates];
            }
        }];
    }
    else
    {
        [self showEmailInputView];
    }
    
    //
    // *** END RMS-specific code ***
    //
    //------------------------------------------------------------
}

#pragma mark - MSEmailInputDelegate

- (void)onEmailInputTappedWithEmail:(NSString *)email completionBlock:(void(^)(BOOL completed))completionBlock
{
    [self.emailInputViewController dismissViewControllerAnimated:YES completion:^{
        completionBlock(YES);
        self.emailInputViewController = nil;
        
        [MSTemplateDescriptor templateListWithUserId:email authenticationCallback:self completionBlock:^(NSArray *templates, NSError *error) {
            
            if (error != nil)
            {
                NSLog(@"Failed to get templates with error: %@", error);
                [[MSErrorViewer sharedInstance] showError:error];
                [self stopAnimationAndShowButtons];
            }
            else
            {
                self.userId = email;
                [self.policyPicker pickTemplateWith:templates];
            }
        }];
    }];
}

- (void)handleCustomProtectedFile:(NSString *)path
{
    NSFileHandle *irmFile = [NSFileHandle fileHandleForReadingAtPath:path];
    
    if (irmFile == nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            NSLog(@"Consumption failed, unable to open handle to path %@", path);
            NSError *error = [[NSError alloc] initWithDomain:@"RMS Sample App" code:1 userInfo:nil];
            [[MSErrorViewer sharedInstance] showError:error];
        });
        return;
    }
    
    // Read header information from protectedData and extract the  PL
    /*-------------------------------------------
     | PL length | PL | ContetSizeLength |
     -------------------------------------------*/
    NSData *plSizeData = [irmFile readDataOfLength:sizeof(NSUInteger)];
    NSUInteger plSize;
    [plSizeData getBytes:&plSize range:NSMakeRange(0, sizeof(NSUInteger))];
    
    // get the PL and protectedData
    NSData *pl = [irmFile readDataOfLength:plSize];
    NSUInteger protectedContentSize;
    NSData *protectedContentSizeData = [irmFile readDataOfLength:sizeof(NSUInteger)];
    [protectedContentSizeData getBytes:&protectedContentSize range:NSMakeRange(0, sizeof(NSUInteger))];
    __block NSData *protectedData = [irmFile readDataOfLength:protectedContentSize];
    
    //----------------------------------------------------------------------
    //
    // *** RMS-specific code ***
    //
    // Code that loads custom PL
    //
    //  *  create an MSUserPolicy
    //  *  See http://msdn.microsoft.com/en-us/library/windows/desktop/dn790796(v=vs.85).aspx for more details
    //
    [MSUserPolicy userPolicyWithSerializedPolicy:pl
                                          userId:self.userId
                          authenticationCallback:self
                                         options:Default
                                 completionBlock:^(MSUserPolicy *userPolicy, NSError *error)
     {
         if (error != nil)
         {
             dispatch_async(dispatch_get_main_queue(),^{
                                [self onConsumptionWithData:nil error:error];
             });
         }
         if (userPolicy == nil)
         {
             dispatch_async(dispatch_get_main_queue(),^{
                 [self onConsumptionWithData:nil error:nil];
             });
         }
         else
         {
             [self updateCurrentProtectionSegmentedControl:userPolicy withCustomProtection:YES];
             // Create the MSCustomProtectedData used for decrypting the content
             // The content start position is the header length
             // The decrypted content size is NSUIntegerMax since the content ends in EOF
             [MSCustomProtectedData customProtectedDataWithPolicy:userPolicy
                                                    protectedData:protectedData
                                             contentStartPosition:0
                                                      contentSize:protectedContentSize
                                                  completionBlock:^(MSCustomProtectedData *customProtectectedData,
                                                                    NSError *error){
                                                      dispatch_async(dispatch_get_main_queue(),^{
                                                          [self onConsumptionWithData:customProtectectedData error:error];
                                                      });
                                                      
                                                  }];
         }
     }];
}

- (void)onConsumptionWithData:(MSProtectedData *)data error:(NSError *)error
{
    [self stopAnimationAndShowButtons];
    // Note: Need to store the user policy in order to use it with the Policy Viewer
    if (error != nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            NSLog(@"Consumption failed with error: %@", error);
            [[MSErrorViewer sharedInstance] showError:error];
        });
        return;
    }
    if (data == nil)
    {
        self.txtView.text = sUserCancelledAuthenticationMessage;
    }
    self.userPolicy = data.userPolicy;
    if([self isProtected])
    {
        if (![self isSupportedFileExtention:data.originalFileExtension])
        {
            self.txtView.text = sContentTypeNotSupportedMessage;
        }
        else
        {
            // Check if the user has the right to view the data
            self.txtView.text = [self.userPolicy accessCheck:[MSCommonRights view]] ?
            [self retrievePlaintextData:data.retrieveData] :
            sNoViewRightsMessage;

            // Use the policy enforcer to protect the Text View which containing the protected content
            self.policyEnforcer = [[MSPolicyEnforcer alloc] initWithProtectionPolicy:self.userPolicy];
            [self.policyEnforcer addRuleToControl:self.txtView
                                      whenNoRight:[MSEditableDocumentRights edit]
                                         doAction:MSEnforcementActionDisableEdit];
        }
        
        [self showPolicyViewer];
    }
};


//----------------------------------------------------------------------
// *** RMS-specific code ***
//
// Allow users to select a user policy.
//
// Every MSProtectedData has a MSUserPolicy class associated with it.
// Your code should maintain a reference to the MSUserPolicy associated with
// the currently loaded document.  This user policy will be used to enforce
// usage restrictions for the loaded content, for example:
//
//      disabling PRINT functionality if the current user doesn't have the PRINT right
//      disabling EDIT  functionality if the current user doesn't have the EDIT right
//      <...etc...>
//
// See http://msdn.microsoft.com/en-us/library/windows/desktop/dn758257(v=vs.85).aspx for more
// information on usage restrictions.
//
// RMS-aware applications should provide a clearly visible UI mechanism to allow users to initiate
// protection of the current loaded document.  Typical applications will expose this through a
// button with a lock-shaped icon, that we'll call the "ProtectionButton"
//
// This method demonstrates how to handle a user clicking on the ProtectionButton
- (void)onLockButton:(id)sender
{
    // Hide the keyboard
    [self.txtView resignFirstResponder];
    
    // Protection: The document is not protected and the application will show the policy picker
    // to allow the user to select the protection template to be applied to the document
    if (![self isProtected])
    {
        [self startPublishingFlow];
    }
    // Consumption: The document is already protected thus the application will show the current
    // protection associated with it.
    else
    {
        // Show the policy viewer if it is not displayed
        if (self.policyViewer == nil)
        {
            [self showPolicyViewer];
        }
        // If the policy viewer is displayed, dismiss it
        else
        {
            [self.policyViewer dismiss];
        }
    }
}

//
// *** END RMS-specific code ***
//
//------------------------------------------------------------


//-------------------------------------------------------
// onMailButton
//
// Most applications persist data.  This sample shows how to persist the current loaded content to a file for the purpose
// of "sending" it (e.g., as an attachment to an email).  Similar logic is used for other persistence mechanisms (e.g.,
// saving a file to disk).
//
// This code works with both RMS-protected files and plaintext files.
//
// Note: If the mail button is pressed after opening an attachment -
// the attachment will be published and emailed and not the default file.
- (void)onMailButton:(id)sender
{
    // Hide the keyboard
    [self.txtView resignFirstResponder];
    //------------------------------------------------------------------------------------------------
    // *** RMS-specific code ***
    //
    // Most RMS-aware applications use different file extensions depending on whether the file is protected or not.
    // EXAMPLES:
    //
    // TXT (plain text) PTXT (protected text)
    // JPG (plaintext JPG) PJPG (protected JPG)
    // CSV (plaintext CSV) PCSV (protected CSV)
    // TXT (plain text) TXT2 (custom protected text)
    // <...etc...>
    //
    // Your application should store the original file extension with the protected file so that other application
    // and tools can decrypt it later. In this example, we're protecting a TXT file, so we'll use the ".txt"
    // extension when we create the document's UserPolicy
    //
    // The protected file extension will be .ptxt/.txt2 is the document is protected or .txt if not.
    NSString *fileExtension = kDefaultTextFileExtension;
    if (self.isProtected)
    {
        fileExtension = (self.protectionTypeSegmentedControl.selectedSegmentIndex != kProtectedFileSelected) ?
            kCustomFileExtension :
        kDefaultProtectedTextFileExtension;
    }
    
    NSString *filePath = [[self.path stringByDeletingPathExtension] stringByAppendingPathExtension:fileExtension];
    
    if (self.protectionTypeSegmentedControl.selectedSegmentIndex == kProtectedFileSelected || !self.isProtected)
    {
        [self sendFile:filePath];
    }
    else
    {
        [self sendCustomFile:filePath];
    }
    //
    // *** END RMS-specific code ***
    //
    //------------------------------------------------------------
}

- (void)sendFile:(NSString *)filePath
{
    NSData *unprotectedData = [self.txtView.text dataUsingEncoding:self.stringEncoding];

    // Use NSData's category method for protecting the document
    // STEP #4: update code that persists files (e.g., save, send, share, etc)
    //
    //  *  create an MSMutableProtectedData to write content to, which works with both protected and unprotected data
    //  *  See http://msdn.microsoft.com/en-us/library/windows/desktop/dn758325(v=vs.85).aspx for more details
    //
    [unprotectedData protectedDataInFile:filePath
                   originalFileExtension:kDefaultTextFileExtension
                    withUserPolicy:self.userPolicy
                         completionBlock:^(MSMutableProtectedData *data, NSError *error)
     {
         if (error != nil)
         {
             dispatch_async(dispatch_get_main_queue(),^
                            {
                                NSLog(@"Protection failed on file: %@, error: %@", filePath, error);
                                [[MSErrorViewer sharedInstance] showError:error];
                            });
             return;
         }
         //Send the protected content
         [self sendMail:filePath];
     }];
}

// Protects the data and writes it to filePath
// If protection succeeds, attach the protected file to an email and open the email dialog
- (void)sendCustomFile:(NSString*)filePath
{
    NSMutableData *unprotectedData = [NSMutableData dataWithData:[self.txtView.text dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableData *backingData = [[NSMutableData alloc] init];    
    //Get the PL from a given policy
    NSData *pl = [self.userPolicy serializedPolicy];
    NSUInteger protectedContentLength = [MSCustomProtectedData getEncryptedContentLengthWithPolicy:self.userPolicy contentLength:unprotectedData.length];
    
    // In deprecated algorithm mode the content must be 16 bytes aligned.
    // Increasing the size of the stream will add a padding with 0s.
    if (self.userPolicy.doesUseDeprecatedAlgorithm)
    {
        if ((protectedContentLength % kDeprecatedAlgAlignement) != 0)
        {
            protectedContentLength = (((protectedContentLength / kDeprecatedAlgAlignement) + 1) * kDeprecatedAlgAlignement);
        }        
        [unprotectedData setLength:protectedContentLength];
    }
    
    // Write header information to backing data including the PL
    //
    // ------------------------------------
    // | PL length | PL | ContetSizeLength |
    // -------------------------------------
    //
    
    NSUInteger plLength = [pl length];
    [backingData appendData:[NSData dataWithBytes:&plLength length:sizeof(plLength)]];
    [backingData appendData:pl];
    [backingData appendData:[NSData dataWithBytes:&protectedContentLength length:sizeof(protectedContentLength)]];
    
    NSUInteger headerLength = sizeof(plLength) + plLength + sizeof(protectedContentLength);

    // Use MSMutableCustomProtectedData for protecting the document using cutom protection
    //
    //  *  create an MSMutableCustomProtectedData to write content to
    //  *  See http://msdn.microsoft.com/en-us/library/windows/desktop/dn758321(v=vs.85).aspx for more details
    //
    [MSMutableCustomProtectedData customProtectorWithUserPolicy:self.userPolicy
                                                          backingData:backingData
                                               protectedContentOffset:headerLength
                                                      completionBlock:^(MSMutableCustomProtectedData *customProtectedData, NSError *error)
     {
         if (error == nil)
         {
             [customProtectedData updateData:unprotectedData error:&error];
         }
         
         if (error != nil)
         {
             dispatch_async(dispatch_get_main_queue(),^
                            {
                                NSLog(@"Protection failed on file: %@, error: %@", filePath, error);
                                [[MSErrorViewer sharedInstance] showError:error];
                            });
             return;
         }
         // ---------------------------------------------------------------------------
         // *** Warning: To avoid data loss and/or corruption, close must be called after writing to your
         // MSMutableCustomProtectedData
         // ---------------------------------------------------------------------------
         [customProtectedData close:&error];
         [backingData writeToFile:filePath atomically:YES];
         [self sendMail:filePath];
     }];
}


#pragma mark - MSPolicyPickerDelegate implementation
// Called after the user selects a template
- (void)didSelectProtection:(MSTemplateDescriptor *)templateDescriptor picker:(MSPolicyPicker *)sender
{
    NSLog(@"User selected a template");
    // put in self PreferDeprecatedAlgorithms
    MSUserPolicyCreationOptions options = None;
    // Note that this is for custom protection only
    if (self.protectionTypeSegmentedControl.selectedSegmentIndex == kCustomProtectedFileWithDeprecatedAlgorithmSelected)
    {
        // This flag is used to indicate if to prefer deprecated algorithms.
        // Only apps that have to be backward compatible with the old versions should use deprecated algorithms.
        // It is not recommended to use deprecated algorithms for the apps that don't have a backward compatibility requirements.
        // This sample uses deprecated algorithms mode only for illustration purposes.
        // Note that deprecated algorithms don't support auto-padding -- so developers code will change in order to use preferDeprecatedAlgorithms == YES.
        options |=  PreferDeprecatedAlgorithms;
    }
    
    [MSUserPolicy userPolicyWithTemplateDescriptor:templateDescriptor userId:self.userId signedAppData:nil authenticationCallback:self options:options completionBlock:^(MSUserPolicy *userPolicy, NSError *error) {
        NSLog(@"User policy created");
        
        BOOL wasPreviouslyProtected = (self.userPolicy != nil);
        
        // The selected policy is saved
        self.userPolicy = userPolicy;
        [self stopAnimationAndShowButtons];
        
        // Check if the policy viewer is already visible and if not, display it.
        if (!wasPreviouslyProtected)
        {
            [self showPolicyViewer];
        }
    }];
}

// Called if the user canceled the Pick Policy flow - Causes the activity indicator to be hidden
- (void)didCancelProtection:(MSPolicyPicker *)sender
{
    NSLog(@"User cancelled the protection process");
    [self stopAnimationAndShowButtons];
}

// Called if an error occured in the Policy Picker flow - Log the error and hide the activity indicator
- (void)didFailWithError:(NSError *)error picker:(MSPolicyPicker *)sender
{
    NSLog(@"Failed to pick a protection policy with error: %@", error);
    [[MSErrorViewer sharedInstance] showError:error];
    [self stopAnimationAndShowButtons];
}

// Called after the user clicks the edit permissions in the Policy Viewer and before the Policy Picker is shown
- (void)willShowPolicyPickerView:(MSPolicyPicker *)sender
{
    self.lockBarButtonItem.enabled = NO;
}

// Called after the user dismisses the Policy Picker 
- (void)didDismissPolicyPickerView:(MSPolicyPicker *)sender
{
    self.lockBarButtonItem.enabled = YES;
}

#pragma mark - MSPolicyViewerDelegate implementation
// Called after the policy viewer is dismissed
- (void)didDismissPolicyViewer
{
    self.policyViewer = nil;
}

// Called when edit button pressed
- (void)editPermissionsTapped
{
    // Dismiss the policy viewer
    [self.policyViewer dismiss];
    
    [self startPublishingFlow];
}

#pragma mark - UI methods

// When the view loads, initialize the application for publishing:
// 1. Initialize the list of rights that are supported.
// 2. The buttons need to be initialized programmatically due to two buttons being displayed on the right side of the navigation bar.
// 3. Initialize the default path to the Pfile to the device's documents directory.
// 4. Set focus on text view control to allow editing and show keyboard.
- (void)showEmailInputView
{
    NSLog(@"Presenting an instance of MSEmailInputViewController");
    
    if (self.emailInputViewController == nil)
    {
        self.emailInputViewController =
        [[ResourcesUtilsUI storyboard] instantiateViewControllerWithIdentifier:@"MSEmailInputViewController"];
        self.emailInputViewController.delegate = self;
    }
    
    [self.navigationController presentViewController:self.emailInputViewController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAppSupportedRights];
    // The default encoding for the text is UTF8
    self.stringEncoding = NSUTF8StringEncoding;
    
    self.mailBarButtonItem = [self barButtonItemWithImageName:sDarkMailIconPath highlightImageName:sLightMailIconPath action:@selector(onMailButton:)];
    self.lockBarButtonItem = [self barButtonItemWithImageName:sDarkLockIconPath highlightImageName:sLightLockIconPath action:@selector(onLockButton:)];

    // Add right buttons to navigation bar
    self.navigationItem.rightBarButtonItems = @[self.lockBarButtonItem, self.mailBarButtonItem];

    // Set the path to the protected file
    self.path = [NSString stringWithFormat:@"%@/%@.%@",
                 [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],
                 kDefaultFileName,
                 kDefaultProtectedTextFileExtension];
    // Set the segmented control to auto resize, so in oreintation change the control will assume all width
    self.protectionTypeSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Observe keyboard show and hide notifications to resize the text view to accommodate the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.activityIndicator setCenter:self.view.center];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Handle Keyboard notifications
- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.txtView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    newFrame.size.height -= keyboardFrame.size.height * (up ? 1 : -1);
    self.txtView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}

#pragma mark - UIViewController protocol
// Called when the view is rotated - used to reposition the activity indicator
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{   
    [self.activityIndicator setCenter:self.view.center];
}

#pragma mark - MFMailComposeViewController protocol
// Called after an email is sent - Logs the result of the operation
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the email Interface
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private Methods

// Check the original file extension is ".txt" if it is not nil (as it is in custom protection)
- (BOOL)isSupportedFileExtention:(NSString *)extension
{
    return extension == nil ? YES : [extension isEqualToString:[NSString stringWithFormat:@".%@", kDefaultTextFileExtension]];
}

// Update the segemented cotrol to the current onsumed content
- (void)updateCurrentProtectionSegmentedControl:(MSUserPolicy *)userPolicy
                           withCustomProtection:(BOOL)customProtection
{
    if (!customProtection)
    {
        self.protectionTypeSegmentedControl.selectedSegmentIndex = kProtectedFileSelected;
    }
    else
    {
        self.protectionTypeSegmentedControl.selectedSegmentIndex =
        userPolicy.doesUseDeprecatedAlgorithm ?
        kCustomProtectedFileWithDeprecatedAlgorithmSelected : kCustomProtectedFileSelected;
    }
}

// attach the protected file to an email and open the email dialog
- (void)sendMail:(NSString*)attachmentFilePath
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:sEmailSubject];
        [mc setMessageBody:sEmailBody isHTML:NO];
        // If protected file set MIME to be "application/ptext"
        if ([[attachmentFilePath pathExtension] isEqualToString:kDefaultProtectedTextFileExtension] ||
            [[attachmentFilePath pathExtension] isEqualToString:kCustomFileExtension])
        {
            // Note: The attachment needs to have a binary mimeType
            // Emailing the ptxt file with a textual mimeType can cause the file to be corrupted
            [mc addAttachmentData:[NSData dataWithContentsOfFile:attachmentFilePath] mimeType:@"application/ptext" fileName:[attachmentFilePath lastPathComponent]];
        }
        else
        {
            [mc addAttachmentData:[NSData dataWithContentsOfFile:attachmentFilePath] mimeType:@"text/plain" fileName:[attachmentFilePath lastPathComponent]];
        }
        // Dismiss the policy viewer (if it is opened) and present the mail composer view controller
        [self.policyViewer dismiss];
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RMS sample app"
                                                            message:@"Please configure your device to send email"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

// Initializes and shows the policy viewer
- (void)showPolicyViewer
{
    self.policyViewer = [MSPolicyViewer policyViewerWithUserPolicy:self.userPolicy
                                                supportedAppRights:self.appSupportedRights];
    self.policyViewer.delegate = self;
    [self.policyViewer show];
}

// Restores the application to its original state
// Called at the start of the "Open In" consumption flow
- (void)cleanup
{
    if (self.policyEnforcer != nil)
    {
        [self.policyEnforcer removeAllRulesFromControl:self.txtView];
    }
    
    self.policyPicker = nil;
    self.userPolicy = nil;
    self.txtView.text = @"";
}

// Create a custom bar button item and return it
- (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName highlightImageName:(NSString *)highlightImageName action:(SEL)action
{
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIImage *buttonHighlightImage = [UIImage imageNamed:highlightImageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonHighlightImage forState:UIControlStateHighlighted];
    button.bounds = CGRectMake(0, 0, buttonImage.size.width + 10, buttonImage.size.height);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lockBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return lockBarButtonItem;
}

// Starts the progress activity indicator animation
// and hides the Lock and Mail buttons
- (void)startAnimationAndHideButtons
{
    self.lockBarButtonItem.customView.hidden = YES;
    self.mailBarButtonItem.customView.hidden = YES;
    self.activityIndicator.hidden = NO;
    self.txtView.editable = NO;
    [self.activityIndicator startAnimating];
}

// Stops the progress activity indicator animation
// and shows the Lock and Mail buttons
- (void)stopAnimationAndShowButtons
{
    self.lockBarButtonItem.customView.hidden = NO;
    self.mailBarButtonItem.customView.hidden = NO;
    self.protectionTypeSegmentedControl.hidden = NO;
    self.activityIndicator.hidden = YES;
    if (self.userPolicy == nil || [self.userPolicy accessCheck:[MSEditableDocumentRights edit]])
    {
        self.txtView.editable = YES;
    }
    [self.activityIndicator stopAnimating];
}

// Retrieves the decrypted data and converts it to an NSString *
- (NSString *)retrievePlaintextData:(NSData *)plainData
{
    self.stringEncoding = [StringEncodingUtils getStringEncoding:plainData];
    return [[NSString alloc] initWithData:plainData encoding:self.stringEncoding];
}

// Authentication Callback using ADAL
- (void)accessTokenWithAuthenticationParameters:(MSAuthenticationParameters *)authenticationParameters completionBlock:(void(^)(NSString *accessToken, NSError *error))completionBlock;
{
    ADAuthenticationError *error;
    ADAuthenticationContext* context = [
                                        ADAuthenticationContext authenticationContextWithAuthority:authenticationParameters.authority
                                        error:&error
                                        ];
    
    context.validateAuthority = FALSE;
    // Please change these values: appClientId, redirectURI after registering your app
    NSString *appClientId = @"com.microsoft.sampleApp";
    NSURL *redirectURI = [NSURL URLWithString:@"local://authorize"];
    // Retrieve token using ADAL
    [context acquireTokenWithResource:authenticationParameters.resource
                             clientId:appClientId
                          redirectUri:redirectURI
                               userId:self.userId == nil ? authenticationParameters.userId : nil
                      completionBlock:^(ADAuthenticationResult *result) {
                          if (result.status != AD_SUCCEEDED)
                          {
                              if (result.status == AD_USER_CANCELLED)
                              {
                                  NSLog(@"User cancelled auth");
                                  completionBlock(nil, [NSError errorWithDomain:@"sampleAppDomain" code:AUTH_CANCELED userInfo:result.error.userInfo]);
                              }
                              else
                              {
                                  NSLog(@"Auth Failed");
                                  completionBlock(nil, result.error);
                              }
                          }
                          else
                          {
                              completionBlock(result.accessToken, result.error);
                          }
                      }];
}

@end
