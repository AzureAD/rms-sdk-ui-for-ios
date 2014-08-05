UI Library for Microsoft RMS SDK v4 for iOS
==================


The UI Library for Microsoft RMS SDK v4 for iOS provides the UI required for the SDK functionality. This library is optional and a developer may choose to build their own UI when using Microsoft RMS SDK v4.

##Features

This library provides following iOS components:
* **EmailInputViewController**: Shows an email address input screen, which is required for RMS operations like protection of files. RMS SDK expects to get the email address of the user who wants to protect data or files to redirect to his organization sign-in portal.
* **PolicyPicker**: Shows a policy picker screen, where the user can choose RMS template or specify the permissions to create a policy for protection of data or files.
* **PolicyViewer**: Shows the permissions that the user has on a RMS protected data or file.

##Contributing

All code is licensed under MICROSOFT SOFTWARE LICENSE TERMS, MICROSOFT RIGHTS MANAGEMENT SERVICE SDK UI LIBRARIES. We enthusiastically welcome contributions and feedback. You can clone the repo and start contributing now.


## How to use this library

### Prerequisites
You must have downloaded and/or installed following software

* Git
* OS X is required for all iOS development.
* Xcode versions (5.0 to 5.0.2)
* Xcode is available through the Mac App Store.
* The Microsoft Rights Management SDK 4.0 package for iOS.
* Authentication library: We recommend that you use the [Azure AD Authentication Library (ADAL)](http://msdn.microsoft.com/en-us/library/jj573266.aspx). However, other authentication libraries that support OAuth 2.0 can be used as well.
For more information see, [ADAL for iOS](https://github.com/AzureAD/azure-activedirectory-library-for-objc).
Application under ./rms-sdk-ui-for-ios/samples/RMSSampleApp demonstrates a sample RMS complaint application that uses RMS SDK v4, this UI library and ADAL.

### Setting up development environment

To develop your own RMS complaint iOS application using RMS SDK V4 please follow these steps. 

1. Download Microsoft RMS SDK v4 for iOS from [here](http://www.microsoft.com/en-ie/download/details.aspx?id=43674) and setup up your development environment following [this](http://msdn.microsoft.com/en-us/library/dn758308(v=vs.85).aspx) guidance. 
2. Import UI library project (uilib) under ./rms-sdk-ui-for-ios/ directory. 
3. Setup ADAL project by following instructions [here](https://github.com/AzureAD/azure-activedirectory-library-for-objc/blob/master/README.md) and import it.
4. Add library reference of RMS SDK v4 project to your application project.
5. Add library reference of uilib project to your application project.
6. Add library reference of ADAL project to your application project.
Note For more information about the RMS SDK v4 please visit developer guidance, code examples and API reference. Read the What's new topic for information about API updates, release notes, and frequently asked questions (FAQ).


## Sample Usage
Sample application included in the repository demonstrates the usage of this library. It is located at samples\RMSSampleApp. Following are some snippets from the sample application ordered to achieve a following scenario.

### Sample Scenario: Publish a file using a RMS template and show UserPolicy.
**Step 1 : Receive email input from user by using MSEmailInputViewController and get Templates using MSIPC SDK v4**
```iOS
- (void)showEmailInputView
{
    NSLog(@"Presenting an instance of MSEmailInputViewController");
    
    if (self.emailInputViewController == nil)
    {
        self.emailInputViewController =
        [[MSResourcesUtils storyboard] instantiateViewControllerWithIdentifier:@"MSEmailInputViewController"];
        self.emailInputViewController.delegate = self;
    }
    
    [self.navigationController presentViewController:self.emailInputViewController animated:YES completion:nil];
}

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
```

**Step 2 : Use MSPolicyPicker to show these templates Use list of templates obtained above to call pickTemplateWith:templates method to display templates. Notice you can also pass in previously chosen template (originalTemplateDescriptor) for highlighting it. **
```iOS
[self.policyPicker pickTemplateWith:templates];
- (void)  pickTemplateWith:( NSArray*)templates
{
    self.policyPickHelper = [[MSPolicyPickHelper alloc] initWithPolicyPicker:self];
    self.policyPickHelper.pickTemplateDelegate = self;
    [self.policyPickHelper runPickTemplateUI:self.policy.templateDescriptor templates:templates];
}
```

**Step 3 : Create UserPolicy from TemplateDescriptor chosen in step 3 using MSIPC SDK v4 API**
```iOS
#pragma mark - MSPolicyPickerDelegate implementation
// Called after the user selects a template
- (void)didSelectProtection:(MSTemplateDescriptor *)templateDescriptor picker:(MSPolicyPicker *)sender
{
    NSLog(@"User selected a template");
    // put in self PreferDeprecatedAlgorithms
    MSUserPolicyCreationOptions options = None;
    
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
```

**Step 4 : Show chosen policy to user. Notice that you can allow editing of chosen user policy (assuming user has rights to do so).**
```iOS
// Initializes and shows the policy viewer
- (void)showPolicyViewer
{
    self.policyViewer = [MSPolicyViewer policyViewerWithUserPolicy:self.userPolicy
                                                supportedAppRights:self.appSupportedRights];
    self.policyViewer.delegate = self;
    [self.policyViewer show];
}
```
















