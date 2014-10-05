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
- (IBAction)togglePrivateRepos:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *privateReposLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commitImg;


- (IBAction)toggleShowClosedIssues:(id)sender;


@end
