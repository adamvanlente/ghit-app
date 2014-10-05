//
//  WXMWIssueDetailView.m
//  ghit
//
//  Created by Adam VanLente on 9/26/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWIssueDetailView.h"
#import "Utils.h"
#import <OctoKit/OctoKit.h>
#import <MMMarkdown/MMMarkdown.h>

@interface WXMWIssueDetailView ()

@end

@implementation WXMWIssueDetailView

BOOL firstLoad = YES;

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

    [self loadCurrentIssue];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!firstLoad) {
        [self loadNewIssue];
    }
    firstLoad = NO;

}

- (void)loadNewIssue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"user_name"];
    id objectId = [defaults objectForKey:@"current_repo_index"];
    
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    RACSignal *updatedIssueRequest = [client fetchIndividualIssueFromRepoWithName:currentRepoName owner:userName objectId:objectId];

    [updatedIssueRequest subscribeNext:^(OCTIssue *issue) {

               dispatch_async(dispatch_get_main_queue(),
                       ^{  //back on main thread
                           NSData *issueEncoded = [NSKeyedArchiver archivedDataWithRootObject:issue];
                           [defaults setObject:issueEncoded forKey:@"currently_viewing_issue"];
                           [defaults synchronize];
                           [self setIssueToScreen:issue];
                       });
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (void)loadCurrentIssue
{
    // Get the current issue and repo name from defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];
    id objectId = issue.objectID;
    [defaults setObject:objectId forKey:@"current_repo_index"];
    [defaults synchronize];

    [self setIssueToScreen:issue];
}

- (void)setIssueToScreen:(OCTIssue *)issue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *repoTitle = [NSString stringWithFormat:@"%@/%@", userName, currentRepoName];
    
    NSNumber *comments = issue.comments;
    NSString *commentCount = [comments stringValue];

    if ([commentCount isEqualToString:@"0"]) {
        _viewCommentsButton.hidden = YES;
    } else {
        _viewCommentsButton.hidden = NO;
    }
    
    // Set the UI to display information about the various aspects of an issue.
    [self setIssueTitles:repoTitle title:issue.title];
    [self setIssueDescription:issue];
    [self setIssueNumber:issue];
    [self setIssueState:issue];
    [self setIssueAssignee:issue];
    [self setIssueLabelList:issue];
    
    [defaults synchronize];
}

- (void)setIssueTitles:(NSString*)currentRepoName title:(NSString*)title
{
    // Set labels for current issue and repo.
    _parentRepoLabel.text = currentRepoName;
    _issueTitleLabel.text = title;
}

- (void)setIssueDescription:(OCTIssue*)issue
{
    if ([issue.body isEqualToString:@""]) {
        _issueDescLabel.text = @"(no description for issue.)";
    } else {
        
         NSString *markedDownComment = [MMMarkdown HTMLStringWithMarkdown:issue.body extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];
        
        [_webViewer setOpaque:NO];
        _webViewer.backgroundColor = [Utils hexColor:@"edecec"];
        
        [_webViewer loadHTMLString:[NSString stringWithFormat:@"<style type='text/css'>body { font-family: 'Helvetica Neue', sans-serif; font-size: 14px; font-weight: light; color: #333; } </style>%@", markedDownComment] baseURL:nil];
    }
}

- (void)setIssueNumber:(OCTIssue*)issue
{
    NSMutableString *issueNumber = [NSMutableString stringWithFormat:@"issue #"];
    NSString *objectId = issue.objectID;
    [issueNumber appendString:objectId];
    _issueNumberLabel.text = issueNumber;
}

- (void)setIssueState:(OCTIssue*)issue
{
    if ([issue.state isEqualToString:@"open"]) {
        _issueClosedLabel.hidden = YES;
        _issueOpenLabel.hidden = NO;
    } else {
        _issueClosedLabel.hidden = NO;
        _issueOpenLabel.hidden = YES;
    }
}

- (void)setIssueAssignee:(OCTIssue*)issue
{
    if (issue.assignee) {
        NSString *login = [issue.assignee objectForKey:@"login"];
        _assigneeLabel.text = login;
        _assigneeLabel.textColor = [Utils hexColor:@"333333"];
        [_assigneeLabel setBackgroundColor: [Utils hexColor:@"F1F1F1"]];
    } else {
        _assigneeLabel.text = @"no user assigned";
        _assigneeLabel.textColor = [Utils hexColor:@"DCDCDC"];
        [_assigneeLabel setBackgroundColor: [Utils hexColor:@"F1F1F1"]];
    }
}

- (void)setIssueLabelList:(OCTIssue*)issue
{
    [[_labelHolderView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *labels = issue.labels;
    CGFloat fromTop = 0;
    CGFloat left = 0;
    NSUInteger count = 0;
    
    for (id item in labels) {
        count++;
        
        left = count % 2 == 0 ? 160 : 0;

        NSString *name = [item objectForKey:@"name"];
        NSString *labelColor = [item objectForKey:@"color"];
        CGRect rect = CGRectMake(left, fromTop, 120, 25);
        UILabel *labelLabel = [[UILabel alloc] initWithFrame:rect];
        labelLabel.text = name;
        labelLabel.font = [UIFont systemFontOfSize:12.0];
        labelLabel.textColor = [Utils hexColor:@"FFFFFF"];
        [labelLabel setBackgroundColor: [Utils hexColor:labelColor]];
        
        labelLabel.textAlignment = NSTextAlignmentCenter;
        
        labelLabel.layer.cornerRadius = 2;
        labelLabel.layer.masksToBounds = YES;
        
        [_labelHolderView addSubview:labelLabel];
        
        fromTop = count % 2 == 0 ? fromTop + 28 : fromTop;
    }
    
    if (labels.count == 0) {
        [self setDisplayForNoLabels];
    }
}

- (void)setDisplayForNoLabels
{
    CGRect rect = CGRectMake(0, 0, 120, 25);
    UILabel *labelLabel = [[UILabel alloc] initWithFrame:rect];
    labelLabel.text = @"no labels";
    labelLabel.font = [UIFont systemFontOfSize:12.0];
    labelLabel.textColor = [Utils hexColor:@"333333"];
    labelLabel.textAlignment = NSTextAlignmentCenter;
    [labelLabel setBackgroundColor: [Utils hexColor:@"F1F1F1"]];
    labelLabel.layer.cornerRadius = 2;
    labelLabel.layer.masksToBounds = YES;
    
    [_labelHolderView addSubview:labelLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"editExistingIssue"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"adding_new_issue"];
        [defaults setBool:YES forKey:@"editing_existing_issue"];
        [defaults synchronize];
    }
    
}


@end
