//
//  WXMWLoginScreen.h
//  ghit
//
//  Created by Adam VanLente on 9/22/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface WXMWLoginScreen : UIViewController

// Action for logging into github.
- (IBAction)loginToGithub:(id)sender;
- (IBAction)localLogin:(id)sender;

// Action to log out of github.
- (IBAction)logoutOfGithub:(id)sender;

// Various labels for the login/settings screen.
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewRepoButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UISwitch *closedIssuesButton;
@property (weak, nonatomic) IBOutlet UILabel *closeButtonLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privateReposSwitch;
@property (weak, nonatomic) IBOutlet UILabel *privateReposLabel;
@property (weak, nonatomic) IBOutlet UISwitch *orgReposSwitch;
@property (weak, nonatomic) IBOutlet UILabel *orgReposLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commitImg;
@property (weak, nonatomic) IBOutlet UILabel *loggingInMessage;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *authCodeText;

// Method to toggle the visiblity of closed issues.
- (IBAction)toggleShowClosedIssues:(id)sender;

// Method to toggle the visiblity of private repos.
- (IBAction)togglePrivateRepos:(id)sender;

// Method to toggle organization repos.
- (IBAction)toggleOrganizationRepos:(id)sender;
- (IBAction)rateGhit:(id)sender;
- (IBAction)ghitSite:(id)sender;

@end
