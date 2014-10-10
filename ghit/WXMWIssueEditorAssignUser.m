//
//  WXMWIssueEditorAssignUser.m
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWIssueEditorAssignUser.h"
#import <OctoKit/OctoKit.h>
#import "Utils.h"

@interface WXMWIssueEditorAssignUser ()

@end

@implementation WXMWIssueEditorAssignUser

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
    
    // Reveal the loading indicator.
    _loadingLabel.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Get the list of contributors from user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *contribs = [defaults objectForKey:@"current_repo_contributors"];
    
    // Make buttons for users.
    [self makeUserButtons:contribs];
}

// Make a butotn for each user that can be assigned as a contributor.
- (void)makeUserButtons:(NSArray *)allowedContributors
{
    // Distance from the top of the canvas.
    NSUInteger fromTop = 0;
    
    // Get the currently selected assignee (there may not be one).
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedUser = [defaults objectForKey:@"current_issue_assignee"];
    
    // Create button for each available user.
    for (id user in allowedContributors) {
        [self createUserButton:user fromTop:fromTop selectedUser:selectedUser];
        fromTop += 50;;
    }
    
    // Create one additional label to let the user non-assign the issue.
    [self createUserButton:@"no assignee" fromTop:fromTop selectedUser:selectedUser];
    
    // Hide loading indicator.
    _loadingLabel.hidden = YES;
}

// Create a button for a user.
- (void)createUserButton:(NSString *)user fromTop:(CGFloat)fromTop selectedUser:(NSString *)selectedUser
{
    // Create the button and set its title/content with the username.
    CGRect rect = CGRectMake(30, fromTop, 250, 35);
    UIButton *labelLabel = [[UIButton alloc] initWithFrame:rect];
    [labelLabel setTitle:user forState:UIControlStateNormal];
    labelLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    // Set a default background and text color.
    NSString *bgColorString = @"F1F1F1";
    NSString *textColorString = @"333333";

    // Alter colors if the user is the currently selected one.
    if ([user isEqualToString:selectedUser]) {
        bgColorString = @"2EAD59";
        textColorString = @"F1F1F1";
    }
    
    // If no selected user exists, give 'no assignee' button the style of the selected item.
    if (!selectedUser || [selectedUser isEqualToString:@""]) {
        if ([user isEqualToString:@"no assignee"]) {
            bgColorString = @"2EAD59";
            textColorString = @"F1F1F1";
        }
    }

    // Set some display properties for the button.
    [labelLabel setTitleColor:[Utils hexColor:textColorString] forState:UIControlStateNormal];
    [labelLabel setBackgroundColor: [Utils hexColor:bgColorString]];
    labelLabel.layer.cornerRadius = 2;
    labelLabel.layer.masksToBounds = YES;
    
    // Append to the user-list holder.
    [_userHolder addSubview:labelLabel];
    
    // Add click event to the button.
    [labelLabel addTarget:self action:@selector(addUserAsAssignee:) forControlEvents:UIControlEventTouchUpInside];
    
}

// Assign the user to the issue.
- (IBAction)addUserAsAssignee:(id)sender
{
    NSString *user = [sender currentTitle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Represent no user with nil.
    if ([user isEqualToString:@"no assignee"]) {
        user = nil;
    }
    
    // Remember the current user selection.
    [defaults setObject:user forKey:@"current_issue_assignee"];
    [defaults synchronize];
    
    // Dismiss the current view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// User is cancelling.  Dismiss the current view.
- (IBAction)cancelAssignUser:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
