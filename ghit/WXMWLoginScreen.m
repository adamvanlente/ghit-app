//
//  WXMWLoginScreen.m
//  ghit
//
//  Created by Adam VanLente on 9/22/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWLoginScreen.h"
#import "Utils.h"
#import "Config.h"
#import <OctoKit/OctoKit.h>


@interface WXMWLoginScreen ()

@end

@implementation WXMWLoginScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    // Set labels based on whether the user is logged in or not.
    [self setToggleSwitches];
    NSLog(@"view did load");
    _loggingInMessage.hidden = YES;

    // Set the ui to its initial state.
    [self initUi];

    // Determine if user is logged in or out.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    BOOL loggedIn = [defaults boolForKey:@"logged_in"];

    if (loggedIn) {
        [self displayButtonsForLoggedInStatus];
    } else {
        [self displayButtonsForLoggedOutStatus];
    }
}

- (void)didFinishLaunchingWithOptions {
    NSLog(@"asdfadsf");
}

- (void)setToggleSwitches
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Check the boolean for showing closed issues. Update the switch accordingly.
    if ([defaults boolForKey:@"show_closed_issues"]) {
        _closedIssuesButton.on = YES;
        _closeButtonLabel.text = @"closed issues visible";
    } else {
        _closedIssuesButton.on = NO;
        _closeButtonLabel.text = @"closed issues hidden";
    }

    // Check the boolean for showing private repos.
    if ([defaults boolForKey:@"hide_private_repos"]) {
        _privateReposSwitch.on = NO;
        _privateReposLabel.text = @"private repos hidden";
    } else {
        _privateReposSwitch.on = YES;
        _privateReposLabel.text = @"private repos visible";
    }

    // Check the boolean for showing organization repos.
    if ([defaults boolForKey:@"show_organization_repos"]) {
        _orgReposSwitch.on = YES;
        _orgReposLabel.text = @"organization repos visible";
    } else {
        _orgReposSwitch.on = NO;
        _orgReposLabel.text = @"organization repos hidden";
    }
}

// Set the UI to its initial state.
- (void)initUi
{
    // Clear all UI elements.
    [self clearAllButtons];

    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"home_bg_2.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    // Set the logo image.
    UIImage *logoImg = [UIImage imageNamed:@"logo.png"];
    _logoImageView.image = logoImg;

    // Clear out the username label.
    _userNameLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Login in to github.
- (IBAction)loginToGithub:(id)sender {

    // Grab the GH credentials from the config file and use to set a OCTClient.
    NSMutableDictionary *config = [Config ghCredentials];
    NSString *clientId = [config objectForKey:@"clientId"];
    NSString *clientSecret = [config objectForKey:@"clientSecret"];
    [OCTClient setClientID:clientId clientSecret:clientSecret];
    [self messageDuringAuthorization];

    // Establish an OCTClient with Octokit.  Client with be authenticated.
    // This method is going to return the client object.
    // FYI the auth scopes allow us to do what we do here as regards getting repos, updating user info.
    [[OCTClient
      signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesNotifications]
     subscribeNext:^(OCTClient *authenticatedClient) {

         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            // Set UI state to logged in.
                            [self saveUser:authenticatedClient];
                            [self displayButtonsForLoggedInStatus];
                        });

     } error:^(NSError *error) {

         // Error occurred, so user is not logged in.  Show logged out status.
         [self displayButtonsForLoggedOutStatus];

         // Hide the login button as the login occurs.
         _loginButton.hidden = NO;
         [_loginButton setTitle:@"login with github" forState:UIControlStateNormal];

         [Utils sendErrorMessageToDatabaseWithMessage:error.description];
     }];
}

- (IBAction)localLogin:(id)sender {

    // Set username and password for request.
    _passwordText.delegate = self;
    NSString *userName = _userNameText.text;
    NSString *password = _passwordText.text;

    // Case for user || pass being empty.
    if (_userNameText.text.length == 0 || _passwordText.text.length == 0) {

        // Show an alert, user/pass cannot be empty.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User/Pass cannot be empty."
                                                        message:@"Please enter a username and/or password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    } else {

        //  Set a message about the authorization attempt.
        [self messageDuringAuthorization];

        // Grab the GH credentials from the config file and use to set a OCTClient.
        NSMutableDictionary *config = [Config ghCredentials];
        NSString *clientId = [config objectForKey:@"clientId"];
        NSString *clientSecret = [config objectForKey:@"clientSecret"];
        [OCTClient setClientID:clientId clientSecret:clientSecret];

        // Set the user.
        OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
        NSString *otp;

        if (_authCodeText.text.length == 0) {
            otp = nil;
            [_passwordText resignFirstResponder];
        } else {
            otp = _authCodeText.text;
            [_authCodeText resignFirstResponder];
        }

        [[OCTClient signInAsUser:user password:password oneTimePassword:otp scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesNotifications]

        subscribeNext:^(OCTClient *authenticatedClient) {

            // Now that repos have been stored, we can refresh the table view (on the main thread).
            dispatch_async(dispatch_get_main_queue(),
                        ^{
                            // Set UI state to logged in.
                            [self saveUser:authenticatedClient];
                            [self displayButtonsForLoggedInStatus];
                        });

        } error:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(),
                        ^{
                        [self displayButtonsForLoggedOutStatus];

                        // Incorrect/invalid login credentials.
                        if (error.code == 666) {
                            // Show an alert.
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid credentials."
                                                        message:@"Username or password is incorrect.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        // User has two factor authentication enabled, give them an input for that value.
                        } else if (error.code == 671) {
                            // Show an alert.
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication required."
                                                        message:@"Your account requires two step authentication.  Please enter your authentication code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];

                            [self displayButtonsForLoggedOutStatus];
                            _authCodeText.hidden = NO;

                            _userNameText.text = userName;
                            _passwordText.text = password;
                            _authCodeText.text = @"";
                            _authCodeText.delegate = self;
                        } else {

                            NSString *errorMessage = (@"Error logging user in: %@", error.description);
                            [Utils sendErrorMessageToDatabaseWithMessage:errorMessage];
                        }
            });
        }];

    }

}

// Save the user details as they are logged in.
- (void)saveUser:(OCTClient *)client
{

    // Prepare to store some items in defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Grab & store user information.  We'll need this stuff a bunch.
    NSString *token = client.token;

    if (token.length > 0) {
        NSString *userName = client.user.rawLogin;
        NSString *cleanUser = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];

        [defaults setObject:token forKey:@"token"];
        [defaults setObject:cleanUser forKey:@"user_name"];
        [defaults setBool:YES forKey:@"logged_in"];

        [defaults synchronize];

        // Store a user as they sign in.
        NSString *email = client.user.email;
        NSString *name = client.user.name;
        NSUInteger publicCount = client.user.publicRepoCount;
        NSUInteger privateCount = client.user.privateRepoCount;

        [Utils storeUser:email name:name username:userName publicCount:publicCount privateCount:privateCount];
    } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token expired."
                           message:@"Your token for ghit has expired.  Taking you to a browser to sign in." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"OK", nil];
            [alert show];
            return;
    }
}

// Set the UI as a user is logging in.
- (void)messageDuringAuthorization
{
    // Hide the login button as the login occurs.
    _loginButton.hidden = YES;
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    _commitImg.hidden = YES;
    _loggingInMessage.hidden = NO;
    _loggingInMessage.text = @"logging in";
    _userNameText.hidden = YES;
    _passwordText.hidden = YES;
    _authCodeText.hidden = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        NSLog(@"just cancelled");
    } else {
        [self loginToGithub:self];
    }
}

// Log out of github.
- (IBAction)logoutOfGithub:(id)sender {

    // Completely clear out the NSUserDefaults dict, removing traces of user.
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in [defaults allKeys]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Set UI to logged out status.
    [self displayButtonsForLoggedOutStatus];

}

// Set all buttons and labels to an empty/cleared state.
-(void)clearAllButtons
{
    _viewRepoButton.hidden = YES;
    _browserLoginButton.hidden = YES;
    _loginButton.hidden = YES;
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    _logoutButton.hidden = YES;
    _userNameLabel.hidden = YES;
    _closedIssuesButton.hidden = YES;
    _closeButtonLabel.hidden = YES;
    _commitImg.hidden = YES;
    _loggingInMessage.hidden = YES;
    _loggingInMessage.text = @"";
}

// Set UI to indicate that user is logged in.
-(void)displayButtonsForLoggedInStatus
{
    _browserLoginButton.hidden = YES;
    _loggingInMessage.hidden = YES;
    _loggingInMessage.text = @"";
    _viewRepoButton.hidden = NO;
    _loginButton.hidden = YES;
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    _logoutButton.hidden = NO;
    _userNameLabel.hidden = NO;
    _closedIssuesButton.hidden = NO;
    _closeButtonLabel.hidden = NO;
    _privateReposLabel.hidden = NO;
    _privateReposSwitch.hidden = NO;
    _orgReposSwitch.hidden = NO;
    _orgReposLabel.hidden = NO;
    _commitImg.hidden = YES;
    _userNameText.hidden = YES;
    _passwordText.hidden = YES;
    _authCodeText.hidden = YES;
    _authCodeText.text = @"";

    // Delay the loading of the profile image slightly, or it will hold up the other actions.
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5);

}

// Set UI to indicate that user has logged out.
-(void)displayButtonsForLoggedOutStatus
{
    _browserLoginButton.hidden = NO;
    _viewRepoButton.hidden = YES;
    _loginButton.hidden = NO;
   [_loginButton setTitle:@"login with github" forState:UIControlStateNormal];
    _logoutButton.hidden = YES;
    _userNameLabel.text = @"";
    _userNameLabel.hidden = YES;
    _profilePic.image = nil;
    _closedIssuesButton.hidden = YES;
    _closeButtonLabel.hidden = YES;
    _privateReposLabel.hidden = YES;
    _privateReposSwitch.hidden = YES;
    _orgReposLabel.hidden = YES;
    _orgReposSwitch.hidden = YES;
    _commitImg.hidden = NO;
    _loggingInMessage.hidden = YES;
    _loggingInMessage.text = @"";
    _userNameText.hidden = NO;
    _userNameText.text = @"";
    _passwordText.hidden = NO;
    _passwordText.text = @"";
    _authCodeText.hidden = YES;
    _authCodeText.text = @"";

    // Set the logo image.
    UIImage *commitImg = [UIImage imageNamed:@"commits"];
    _commitImg.image = commitImg;
}

// Toggle whether or not user will see private repos.
- (IBAction)togglePrivateRepos:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showReposWithNoIssues = _privateReposSwitch.on;

    if (showReposWithNoIssues) {
        [defaults removeObjectForKey:@"hide_private_repos"];
        _privateReposLabel.text = @"private repos visible";
    } else {
        [defaults setBool:YES forKey:@"hide_private_repos"];
        _privateReposLabel.text = @"private repos hidden";
    }
    [defaults synchronize];
}

// Toggle whether or not user will see private repos.
- (IBAction)toggleOrganizationRepos:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showOrganizationRepos = _orgReposSwitch.on;

    if (showOrganizationRepos) {
        [defaults setBool:YES forKey:@"show_organization_repos"];
        _orgReposLabel.text = @"organization repos visible";
    } else {
        [defaults removeObjectForKey:@"show_organization_repos"];
        _orgReposLabel.text = @"organization repos hidden";
    }
    [defaults synchronize];
}

- (IBAction)rateGhit:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id929836674"]];
}

- (IBAction)ghitSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://ghit.io"]];
}

// Toggle whether or not user will see closed issues.
- (IBAction)toggleShowClosedIssues:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showReposWithNoIssues = _closedIssuesButton.on;

    if (showReposWithNoIssues) {
        [defaults setBool:YES forKey:@"show_closed_issues"];
        _closeButtonLabel.text = @"closed issues visible";
    } else {
        [defaults removeObjectForKey:@"show_closed_issues"];
        _closeButtonLabel.text = @"closed issues hidden";
    }
    [defaults synchronize];
}
@end
