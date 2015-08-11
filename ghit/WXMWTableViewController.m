//
//  WXMWTableViewController.m
//  ghit
//
//  Created by Adam VanLente on 9/23/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWTableViewController.h"
#import "WXMWLoginScreen.h"
#import "WXMWTableViewCell.h"
#import "WXMWNavController.h"
#import "Utils.h"
#import <OctoKit/OctoKit.h>

@interface WXMWTableViewController ()

@end

UIRefreshControl *refreshControl;

@implementation WXMWTableViewController

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
    
    // Remove those pesky lines beneath the table cells.
    self.tableView.separatorColor = [UIColor clearColor];

    // Set up a refresh control when pulling down the list.
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(getUserRepos) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Show the label to indicate that repos are loading.
    _loadingReposLabel.hidden = NO;
    _loadingReposLabel.text = @"loading repos";
    
    // Show the user's repos.
    [self getUserRepos];
}

- (void)getUserRepos
{
    // Grab the user's information and create an OCTClient with it.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    // Fetch the user's repos.
    [self fetchRepositoriesWithClient:client];
}

// Fetch a client's owned repositories.
-(void)fetchRepositoriesWithClient:(OCTClient *)client
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Set an empty array for list of repos
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    // Assemble and make the request for repositiories.
    RACSignal *repoRequest = [client fetchUserRepositories];
    [repoRequest subscribeNext:^(OCTRepository *repository) {

        if ([defaults boolForKey:@"hide_private_repos"] && repository.private) {
            // Do nothing - hiding private repos.
        } else {
            // For each repo returned, store an encoded version in the array.
            NSData *repoEncoded = [NSKeyedArchiver archivedDataWithRootObject:repository];
            [itemsArray addObject:repoEncoded];
        }
        
    } error:^(NSError *error) {
        _loadingReposLabel.hidden = NO;
        _loadingReposLabel.text = @"an error ocurred.  please try again.";

        [Utils sendErrorMessageToDatabaseWithMessage:error.description];
        
    } completed:^{
        
        // When all repos have arrived, store the list of (encoded) repos to user defaults.
        [defaults setObject:itemsArray forKey:@"repo_list"];
        [defaults synchronize];
        
        // Now that repos have been stored, we can refresh the table view (on the main thread).        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                          

                          _loadingReposLabel.hidden = YES;
                          [self.tableView reloadData];
                          [refreshControl endRefreshing];
                           
                       });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Rows are based on the number of repos.  Grab the repo list and get the count.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *repoList = [defaults objectForKey:@"repo_list"];
    return [repoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the list of repos from the user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *repoList = [defaults objectForKey:@"repo_list"];

    // Instantiate a cell.
    WXMWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    // Grab the current repository and its details.
    NSUInteger row = [indexPath row];
        
        OCTRepository *repoItem = [NSKeyedUnarchiver unarchiveObjectWithData:repoList[row]];
    
        [self setRepoIsPrivate:repoItem cell:cell];
        [self setRepoNameAndDescription:repoItem cell:cell];
        [self setIssueCount:repoItem cell:cell];
        [self setRepoOwner:repoItem cell:cell];
    
        return cell;
}

- (void)setRepoIsPrivate:(OCTRepository *)repo cell:(WXMWTableViewCell *)cell
{
    // Set repo type to private/public.
    BOOL isPrivate = repo.private;
    if (isPrivate) {
        cell.repoIcon.image = [UIImage imageNamed:@"repo_private.png"];
        cell.privateLabel.hidden = NO;
        cell.publicLabel.hidden = YES;
    } else {
        cell.repoIcon.image = [UIImage imageNamed:@"repo_public.png"];
        cell.privateLabel.hidden = YES;
        cell.publicLabel.hidden = NO;
    }
}

- (void)setRepoNameAndDescription:(OCTRepository *)repo cell:(WXMWTableViewCell *)cell
{
    NSString *repoName = repo.name;
    NSString *repoDesc = repo.repoDescription;
    NSString *count = [repo.openIssues stringValue];
    
    // Set the rest of the labels for the repo.
    if ([repoDesc isEqualToString:@""]) {
        repoDesc = @"(no description)";
    }
    cell.repoNameLabel.text = repoName;
    cell.repoDescLabel.text = repoDesc;
    cell.issueCountLabel.text = count;
}

- (void)setIssueCount:(OCTRepository *)repo cell:(WXMWTableViewCell *)cell
{
    NSString *count = [repo.openIssues stringValue];
    if ([count isEqualToString:@"1"]) {
        cell.openIssuesNoteLabel.text = @"open issue";
    } else {
        cell.openIssuesNoteLabel.text = @"open issues";
    }
    cell.issueCountLabel.layer.masksToBounds = YES;
}

- (void)setRepoOwner:(OCTRepository *)repo cell:(WXMWTableViewCell *)cell
{
    NSString *owner = repo.ownerLogin;
    cell.repoOwnerLabel.text = owner;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Handler for a specific segue: when a user clicks a repo to view its list
    // of issues.
    if ([segue.identifier isEqualToString:@"repoToIssueSegue"]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // This sync is needed because org repositories setting may be updating
        // defaults int he background.  Want to make sure we've got most
        // up to date set of defaults at this stage.
        [defaults synchronize];

        // Get the clicked row.
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
        NSUInteger row = ip.row;
        
        // Get the current repo.
        NSArray *repoList = [defaults objectForKey:@"repo_list"];
        
        OCTRepository *repoItem = [NSKeyedUnarchiver unarchiveObjectWithData:repoList[row]];
        NSString *repoName = repoItem.name;
        NSString *stringedRow = [NSString stringWithFormat:@"%lu", (unsigned long)row];

        // Store the current repo name and index.
        [defaults setObject:repoName forKey:@"current_repo_name"];
        [defaults setObject:stringedRow forKey:@"current_repo_index"];
        [defaults setObject:repoItem.ownerLogin forKey:@"current_repo_owner"];
        [defaults synchronize];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
