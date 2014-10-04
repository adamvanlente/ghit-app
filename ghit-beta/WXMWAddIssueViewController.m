//
//  WXMWAddIssueViewController.m
//  ghit-beta
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
    // Do any additional setup after loading the view.
    
    [self initNewIssueDefaults];
    [self setCurrentRepoContributors];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"adding_new_issue"]) {
        _issueEditorTitle.text = @"Add an issue";
        _addNewIssueButton.hidden = NO;
        _updateAndCloseButton.hidden = YES;
        _updateIssueButton.hidden = YES;
    }
    
    if ([defaults objectForKey:@"editing_existing_issue"]) {
        [self loadExistingIssue];
        _issueEditorTitle.text = @"Edit issue";
        _addNewIssueButton.hidden = YES;
        _updateAndCloseButton.hidden = NO;
        _updateIssueButton.hidden = NO;
    }
}

- (void)loadExistingIssue
{
    // Get the current issue and repo name from defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];

    _issueTitle.text = issue.title;
    _issueBody.text = issue.body;
    
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    NSArray *labels = issue.labels;
    
    for (id label in labels) {
        NSString *name = [label objectForKey:@"name"];
        [selectedItems addObject:name];
    }
    
    NSDictionary *issueAssignee = issue.assignee;
    NSString *assignee = [issueAssignee objectForKey:@"login"];
    [defaults setObject:assignee forKey:@"current_issue_assignee"];
    [defaults setObject:selectedItems forKey:@"temp_new_issue_labels"];
    [defaults setObject:@"open" forKey:@"issue_state"];
    [defaults synchronize];
}

- (void)viewDidAppear:(BOOL)animated
{
//
}

- (void)initNewIssueDefaults
{
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    [defaults setObject:emptyArray forKey:@"temp_new_issue_labels"];
    [defaults setObject:nil forKey:@"current_issue_assignee"];
    [defaults synchronize];
}

- (void)clearNewIssueDefaults
{
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"current_issue_assignee"];
    [defaults removeObjectForKey:@"temp_new_issue_labels"];
    [defaults synchronize];
}

- (void)setCurrentRepoContributors
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"user_name"];
    
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    NSMutableArray *allowedContributors = [[NSMutableArray alloc] init];
    [allowedContributors addObject:userName];
    [defaults setObject:allowedContributors forKey:@"current_repo_contributors"];
    [defaults synchronize];
    
    RACSignal *contribRequest = [client fetchContributorsForRepo:currentRepoName owner:userName];
    [contribRequest subscribeNext:^(OCTUser *contributor) {
        
        if (![contributor.login isEqualToString:userName]) {
            [allowedContributors addObject:contributor.login];
        }
        
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } completed:^{
        
        [defaults setObject:allowedContributors forKey:@"current_repo_contributors"];
        [defaults synchronize];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelCreateNewIssue:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"just_cancelled_adding_issue"];
    [defaults synchronize];

     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addNewIssue:(id)sender {
    
    NSString *newIssueName = _issueTitle.text;
    NSString *newIssueComments = _issueBody.text;
    
    if ([newIssueName isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose a name."
                                                        message:@"A name is required for an issue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
     
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *selectedLabels = [defaults objectForKey:@"temp_new_issue_labels"];
        NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
        NSString *assignee = [defaults objectForKey:@"current_issue_assignee"];
        NSUInteger objectId = [[defaults objectForKey:@"current_repo_index"] integerValue];
        NSString *state = [defaults objectForKey:@"issue_state"];
        
        NSString *userName = [defaults objectForKey:@"user_name"];
        NSString *token = [defaults objectForKey:@"token"];
        OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
        OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
        
        
        if ([defaults objectForKey:@"adding_new_issue"]) {
            [self addNewlyCreatedIssue:newIssueName comments:newIssueComments labels:selectedLabels repo:currentRepoName assignee:assignee client:client userName:userName];
        }
        
        if ([defaults objectForKey:@"editing_existing_issue"]) {
            [self updateExistingIssue:newIssueName comments:newIssueComments labels:selectedLabels repo:currentRepoName assignee:assignee client:client userName:userName objectId:objectId state:state];
        }
    
    }
}

- (void)updateExistingIssue:(NSString *)issueName comments:(NSString *)comments labels:(NSMutableArray *)labels repo:(NSString *)repo assignee:(NSString *)assignee client:(OCTClient *)client userName:(NSString *)userName objectId:(NSUInteger)objectId state:(NSString *)state
{
    RACSignal *updateIssueRequest = [client updateIssueForRepo:repo owner:userName labels:labels title:issueName body:comments assignee:assignee objectId:objectId state:state];

    [[updateIssueRequest collect] subscribeNext:^(OCTIssue *issue) {
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

- (void)addNewlyCreatedIssue:(NSString *)issueName comments:(NSString *)comments labels:(NSMutableArray *)labels repo:(NSString *)repo assignee:(NSString *)assignee client:(OCTClient *)client userName:(NSString *)userName
{
    [self dismissViewControllerAnimated:YES completion:nil];
    RACSignal *createNewIssueRequest = [client createIssueForRepo:repo owner:userName labels:labels title:issueName body:comments assignee:assignee];

    [[createNewIssueRequest collect] subscribeNext:^(OCTIssue *issue) {
        // pass.
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (IBAction)updateAndClose:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"closed" forKey:@"issue_state"];
    [defaults synchronize];
    
    [self addNewIssue:self];
}
@end
