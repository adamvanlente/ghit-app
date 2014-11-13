//
//  WXMWAddIssueViewController.m
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWAddIssueViewController.h"
#import "WXMWIssueTVC.h"
#import <OctoKit/OctoKit.h>

@interface WXMWAddIssueViewController ()

@end

@implementation WXMWAddIssueViewController

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
    
    _activityIndicator.hidden = YES;
    _activityIndicatorLabel.hidden = YES;
    
    // Set some defaults and get the list of available contributors/assignees.
    [self initNewIssueDefaults];
    [self setCurrentRepoContributors];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Set the UI for adding a new issue.
    if ([defaults objectForKey:@"adding_new_issue"]) {
        _issueEditorTitle.text = @"Add an issue";
        _addNewIssueButton.hidden = NO;
        _updateAndCloseButton.hidden = YES;
        _updateIssueButton.hidden = YES;
    }
    
    // Set the UI for updating an existing issue.
    if ([defaults objectForKey:@"editing_existing_issue"]) {
        _issueEditorTitle.text = @"Edit issue";
        _addNewIssueButton.hidden = YES;
        _updateAndCloseButton.hidden = NO;
        _updateIssueButton.hidden = NO;
       [self loadExistingIssue];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _activityIndicator.hidden = YES;
    _activityIndicatorLabel.hidden = YES;
}

- (void)loadExistingIssue
{
    // Get the current issue and repo name from defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];

    // Set the title and body of the issue.
    _issueTitle.text = issue.title;
    _issueBody.text = issue.body;
    
    // Create a list of all the labels for the current repo.
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    NSArray *labels = issue.labels;
    
    for (id label in labels) {
        NSString *name = [label objectForKey:@"name"];
        [selectedItems addObject:name];
    }
    
    // If repo is currently open, reveal the button to close the issue.
    if ([issue.state isEqualToString:@"open"]) {
        _updateAndCloseButton.hidden = NO;
    } else {
        _updateAndCloseButton.hidden = YES;
    }

    // Store all the info about this issue in User Defaults.
    NSDictionary *issueAssignee = issue.assignee;
    NSString *assignee = [issueAssignee objectForKey:@"login"];
    [defaults setObject:assignee forKey:@"current_issue_assignee"];
    [defaults setObject:selectedItems forKey:@"temp_new_issue_labels"];
    [defaults setObject:@"open" forKey:@"issue_state"];
    [defaults synchronize];
}

// Set some default values for a new issue.
- (void)initNewIssueDefaults
{
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    [defaults setObject:emptyArray forKey:@"temp_new_issue_labels"];
    [defaults setObject:nil forKey:@"current_issue_assignee"];
    [defaults synchronize];
}

// Clear default values for a new issue.
- (void)clearNewIssueDefaults
{
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"current_issue_assignee"];
    [defaults removeObjectForKey:@"temp_new_issue_labels"];
    [defaults synchronize];
}

// Get a list of all the users that may contribute to this repo, in order to offer
// them as options when assigning a user to the issue.
- (void)setCurrentRepoContributors
{
    // Get current reponame and current username,
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"current_repo_owner"];
    
    // Create a client in order to make a request.
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    // Create a holder for the list of contributors.
    NSMutableArray *allowedContributors = [[NSMutableArray alloc] init];
    
    // Add the current user by default.
    [allowedContributors addObject:userName];
    [defaults setObject:allowedContributors forKey:@"current_repo_contributors"];
    [defaults synchronize];
    
    // Request the list of contributors.
    RACSignal *contribRequest = [client fetchContributorsForRepo:currentRepoName owner:userName];
    [contribRequest subscribeNext:^(OCTUser *contributor) {
        
        // Add all users who are not the current user to the list of available contributors.
        if (![contributor.login isEqualToString:userName]) {
            [allowedContributors addObject:contributor.login];
        }
        
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } completed:^{
        
        // Once all users have been fetched, save the list of users.
        [defaults setObject:allowedContributors forKey:@"current_repo_contributors"];
        [defaults synchronize];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cancel creating an issue.  Create a boolean so that we don't needlessly refresh
// the issue when returning to the detail screen.
- (IBAction)cancelCreateNewIssue:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"just_cancelled_adding_issue"];
    [defaults synchronize];
    
    // Dismiss the new issue creation modal.
    [self dismissViewControllerAnimated:YES completion:nil];
}

// The preparation and request to create a new issue.
- (IBAction)addNewIssue:(id)sender {
    
    NSString *newIssueName = _issueTitle.text;
    NSString *newIssueComments = _issueBody.text;
    
    // Make sure the issue has a name.  That is the minimum amount required.
    if ([newIssueName isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose a name."
                                                        message:@"A name is required for an issue."
                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
     
        // Get all the data for the POST from the user defaults.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *selectedLabels = [defaults objectForKey:@"temp_new_issue_labels"];
        NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
        NSString *assignee = [defaults objectForKey:@"current_issue_assignee"];
        NSUInteger objectId = [[defaults objectForKey:@"current_repo_index"] integerValue];
        NSString *state = [defaults objectForKey:@"issue_state"];
        
        // Create a client to make the request.
        NSString *userName = [defaults objectForKey:@"current_repo_owner"];
        NSString *token = [defaults objectForKey:@"token"];
        OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
        OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
        
        // Determine which request to instantiate: create new issue (POST) or update existing (PATCH).
        if ([defaults objectForKey:@"adding_new_issue"]) {
            [self addNewlyCreatedIssue:newIssueName comments:newIssueComments labels:selectedLabels repo:currentRepoName assignee:assignee client:client userName:userName];
        } else if ([defaults objectForKey:@"editing_existing_issue"]) {
            [self updateExistingIssue:newIssueName comments:newIssueComments labels:selectedLabels repo:currentRepoName assignee:assignee client:client userName:userName objectId:objectId state:state];
        }
    }
}

// Make a request to update an existing issue.
- (void)updateExistingIssue:(NSString *)issueName comments:(NSString *)comments labels:(NSMutableArray *)labels repo:(NSString *)repo assignee:(NSString *)assignee client:(OCTClient *)client userName:(NSString *)userName objectId:(NSUInteger)objectId state:(NSString *)state
{
    // Form the update issue request.
    RACSignal *updateIssueRequest = [client updateIssueForRepo:repo owner:userName labels:labels title:issueName body:comments assignee:assignee objectId:objectId state:state];
    [[updateIssueRequest collect] subscribeNext:^(OCTIssue *issue) {

        // If successful, dismiss the modal on the main thread.  Refreshing is handled by the parent view.
        dispatch_async(dispatch_get_main_queue(),
                       ^{  //back on main thread
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

// Make a request to add a new issue.
- (void)addNewlyCreatedIssue:(NSString *)issueName comments:(NSString *)comments labels:(NSMutableArray *)labels repo:(NSString *)repo assignee:(NSString *)assignee
    client:(OCTClient *)client userName:(NSString *)userName
{

    _activityIndicator.hidden = NO;
    _activityIndicatorLabel.hidden = NO;

    // Form the create new issue request.
    RACSignal *createNewIssueRequest = [client createIssueForRepo:repo owner:userName labels:labels title:issueName body:comments assignee:assignee];
    [[createNewIssueRequest collect] subscribeNext:^(OCTIssue *issue) {
        // If successful, dismiss the modal on the main thread.  Refreshing is handled by the parent view.
        dispatch_async(dispatch_get_main_queue(),
                       ^{  //back on main thread
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        _activityIndicator.hidden = YES;
        _activityIndicatorLabel.hidden =YES;
    }];
    
}

// Close and issue.  Simply sets the 'state' global to closed, then updates the issue like a normal update.
// Result is a closed issue.
- (IBAction)updateAndClose:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"closed" forKey:@"issue_state"];
    [defaults synchronize];
    
    [self addNewIssue:self];
}
@end
