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
    [self setLoginLabels];
}

- (void)setLoginLabels
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _userNameLabel.hidden = YES;
    // Check the boolean for showing closed issues. Update the switch accordingly.
    if ([defaults boolForKey:@"show_closed_issues"]) {
        _closedIssuesButton.on = YES;
        _closeButtonLabel.text = @"closed issues visible";
    } else {
        _closedIssuesButton.on = NO;
        _closeButtonLabel.text = @"closed issues hidden";
    }
    
    if ([defaults boolForKey:@"hide_private_repos"]) {
        _privateReposSwitch.on = NO;
        _privateReposLabel.text = @"private repos hidden";
    } else {
        _privateReposSwitch.on = YES;
        _privateReposLabel.text = @"private repos visible";
    }
}

// Set UI to indicate that user has logged out.
-(void)clearAllButtons
{
    _viewRepoButton.hidden = YES;
    _loginButton.hidden = YES;
   [_loginButton setTitle:@"" forState:UIControlStateNormal];
    _logoutButton.hidden = YES;
    _userNameLabel.hidden = YES;
    _closedIssuesButton.hidden = YES;
    _closeButtonLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [self clearAllButtons];
    
    // Set the ui to its initial state.
    [self initUi];

    // Determine if user is logged in or out.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"profile_photo"]) {
        [self displayButtonsForLoggedInStatus];
    } else {
        [self displayButtonsForLoggedOutStatus];
    }
}

// Set the UI to its initial state.
- (void)initUi
{
    // Set the background color of the home screen.
    self.view.backgroundColor = [Utils hexColor:@"edecec"];

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

    // Hide the login button as the login occurs.
    _loginButton.hidden = YES;
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    
    // Establish an OCTClient with Octokit.  Client with be authenticated.
    // This method is going to return the client object.
    // FYI the auth scopes allow us to do what we do here as regards getting repos, updating user info.
    [[OCTClient
      signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesNotifications]
     subscribeNext:^(OCTClient *authenticatedClient) {
         
         // Prepare to store some items in defaults.
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         
         // Grab & store user information.  We'll need this stuff a bunch.
         NSString *token = authenticatedClient.token;
         NSString *avatarURL = [authenticatedClient.user.avatarURL absoluteString];
         NSMutableString *imgUrl = [NSMutableString stringWithFormat:avatarURL];
         [imgUrl appendString:@"&s=120"];
         
         NSString *userName = authenticatedClient.user.login;
        
         [defaults setObject:token forKey:@"token"];
         [defaults setObject:userName forKey:@"user_name"];
         [defaults setObject:imgUrl forKey:@"profile_photo"];
         
         [defaults synchronize];
         
         // Now that repos have been stored, we can refresh the table view (on the main thread).
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            // Set UI state to logged in.
                            [self displayButtonsForLoggedInStatus];
                        });
     } error:^(NSError *error) {

         // Error occurred, so user is not logged in.  Show logged out status.
         [self displayButtonsForLoggedOutStatus];
         
         // Hide the login button as the login occurs.
         _loginButton.hidden = NO;
         [_loginButton setTitle:@"login with github" forState:UIControlStateNormal];
     }];
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

// Update the user's profile photo.
-(void)updateProfilePhoto
{
    // Grab the user photo from user defaults, set the photo in the UI.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *profilePicUrl = [defaults objectForKey:@"profile_photo"];
    UIImage *profileImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicUrl]]];
    _profilePic.image = profileImg;
    
    // Also set the username underneath the photo.
    NSString *userName = [defaults objectForKey:@"user_name"];
    _userNameLabel.text = userName;
}

// Set UI to indicate that user is logged in.
-(void)displayButtonsForLoggedInStatus
{
    _viewRepoButton.hidden = NO;
    _loginButton.hidden = YES;
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    _logoutButton.hidden = NO;
    _userNameLabel.hidden = NO;
    _closedIssuesButton.hidden = NO;
    _closeButtonLabel.hidden = NO;
    _privateReposLabel.hidden = NO;
    _privateReposSwitch.hidden = NO;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self updateProfilePhoto];
    });
}

// Set UI to indicate that user has logged out.
-(void)displayButtonsForLoggedOutStatus
{
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
}

// Toggle whether or not user will see hidden issues.
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
