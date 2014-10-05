//
//  WXMWIssueTVC.m
//  ghit
//
//  Created by Adam VanLente on 9/25/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWIssueTVC.h"
#import "WXMWIssueTVCell.h"
#import "WXMWNavController.h"

@interface WXMWIssueTVC ()

@end

UIRefreshControl *refreshControl;

@implementation WXMWIssueTVC


- (IBAction)unwindToIssueList:(UIStoryboardSegue *)unwindSegue
{
    // Unwind from adding an issue back to list of all issues.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self clearIssuesList];
    
    // Set up a refresh control when pulling down the list.
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshIssueList) forControlEvents:UIControlEventValueChanged];
    
    // As view appears, refresh the list of issues and set the current repo name.
    [self refreshIssueList];
    [self loadCurrentRepoName];
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

// Refresh the current list of issues.
- (void)refreshIssueList
{
    // Clear some defaults that indicate the current state of issue viewing.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"adding_new_issue"];
    [defaults removeObjectForKey:@"editing_existing_issue"];
    [defaults synchronize];
    
    // There's a chance that a user has just cancelled adding an issue.
    // If so, no need to reload the list of issues on viewDidLoad.
    BOOL justCancelled = [defaults objectForKey:@"just_cancelled_adding_issue"];
    if (justCancelled) {
        [defaults removeObjectForKey:@"just_cancelled_adding_issue"];
        [defaults synchronize];
    } else {
    
        // Stop the iOs refreshing icon and clear the issue list.
        [self clearIssuesList];

        // Load some of the saved user defaults.
        NSString *userName = [defaults objectForKey:@"user_name"];
        NSString *token = [defaults objectForKey:@"token"];
        NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];

        // Determine whether to show all issues or only open issues.
        NSString *issuesToShow;
        if ([defaults objectForKey:@"show_closed_issues"]) {
            issuesToShow = @"all";
        } else {
            issuesToShow = @"open";
        }
        
        // Create a user and an authenticated client.
        OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
        OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
        NSString *stringRow = [defaults objectForKey:@"current_repo_index"];
        NSUInteger row = [stringRow integerValue];
        NSArray *repoList = [defaults objectForKey:@"repo_list"];
        OCTRepository *repoItem = [NSKeyedUnarchiver unarchiveObjectWithData:repoList[row]];
        NSString *owner = repoItem.ownerLogin;
        
        [self getRepoIssues:client repo:currentRepoName owner:owner state:issuesToShow];
        
    }
}

- (void)getRepoIssues:(OCTClient *)client repo:(NSString *)repo owner:(NSString *)owner state:(NSString *)state
{
    // Create a request for the list of issues.
    RACSignal *issueRequest = [client fetchIssuesForRepo:repo owner:owner state:state];
    
    // Make the request and collect the response as one array.
    [[issueRequest collect] subscribeNext:^(NSArray *issues) {
        
        // Create a new array for the items that are returned.
        NSMutableArray *issueList = [[NSMutableArray alloc] init];
        
        // For each returned issue, create an encoded version that can be store in NSUserDefaults.
        for (id issue in issues) {
            NSData *issueEncoded = [NSKeyedArchiver archivedDataWithRootObject:issue];
            [issueList addObject:issueEncoded];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Save an object in user defaults for the issue list.
        [defaults setObject:issueList forKey:@"issues_list"];
        [defaults synchronize];
        
        // Reload the table view data (call reload data on the main thread).
        dispatch_async(dispatch_get_main_queue(),
                       ^{    //back on main thread
                           
                           // Set label if no issues exist.
                           if (issueList.count == 0) {
                               _loadingIssuesLabel.text = @"no issues found";
                           }
                           
                           [self.tableView reloadData];
                           [refreshControl endRefreshing];
                       });
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];

}


// Method to clear the list of issues before reloading.
- (void)clearIssuesList
{
    // Set a label to indicate that issues are loading.
    _loadingIssuesLabel.text = @"loading issues...";
    _loadingIssuesLabel.hidden = NO;

    // Clear out the holder containing all issues.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"issues_list"];
    [defaults synchronize];
    
    // Reload the table view.
    [self.tableView reloadData];
}

// Method that sets the current repo name in the UI.
- (void)loadCurrentRepoName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stringRow = [defaults objectForKey:@"current_repo_index"];
    NSUInteger row = [stringRow integerValue];
    
    NSArray *repoList = [defaults objectForKey:@"repo_list"];
    
    OCTRepository *repoItem = [NSKeyedUnarchiver unarchiveObjectWithData:repoList[row]];
    
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *repoTitle = [NSString stringWithFormat:@"%@/%@", userName, repoItem.name];
    
    _currentRepoNameLabel.text = repoTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *issueList = [defaults objectForKey:@"issues_list"];
    // Return the number of rows in the section.
    return [issueList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Create a new cell for the issue list.
    WXMWIssueTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IssueCell"];
    NSUInteger row = [indexPath row];
    
    // Load some user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *issueList = [defaults objectForKey:@"issues_list"];
    
    // Indentify the issue for the current row.
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:issueList[row]];

    [self setIssueToCell:cell issue:issue issueList:issueList];
    
    return cell;
}

- (void)setIssueToCell:(WXMWIssueTVCell *)cell issue:(OCTIssue *)issue issueList:(NSMutableArray *)issueList
{
    // Set the title of the current row.
    cell.issueTitleLabel.text = issue.title;
    
    // Set the label for the current issue ID.
    NSMutableString *issueNumber = [NSMutableString stringWithFormat:@"issue #"];
    NSString *objectId = issue.objectID;
    [issueNumber appendString:objectId];
    cell.issueNumberLabel.text = issueNumber;
    
    // Set the label for the state (open/closed).
    if ([issue.state isEqualToString:@"open"]) {
        cell.issueOpenLabel.hidden = NO;
        cell.issueClosedLabel.hidden = YES;
        cell.issueOpenLabel.layer.masksToBounds = YES;
    } else {
        cell.issueOpenLabel.hidden = YES;
        cell.issueClosedLabel.hidden = NO;
        cell.issueClosedLabel.layer.masksToBounds = YES;
    }
    
    NSUInteger count = [issueList count];
    if (count > 0) {
        _loadingIssuesLabel.hidden = YES;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // User is progressing to view details of an issues.
    if ([segue.identifier isEqualToString:@"viewIssueDetail"]) {
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
        NSUInteger row = ip.row;

        NSMutableArray *issuesList = [defaults objectForKey:@"issues_list"];
        [defaults setObject:issuesList[row] forKey:@"currently_viewing_issue"];
        [defaults synchronize];
    }
    
    // User is creating a new issue.
    if ([segue.identifier isEqualToString:@"createNewIssue"]) {
        [defaults removeObjectForKey:@"editing_existing_issue"];
        [defaults setBool:YES forKey:@"adding_new_issue"];
        [defaults synchronize];
    }
}

@end
