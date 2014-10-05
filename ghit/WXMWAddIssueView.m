//
//  WXMWAddIssueView.m
//  ghit
//
//  Created by Adam VanLente on 9/27/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWAddIssueView.h"
#import "WXMWIssueTVC.h"
#import <OctoKit/OctoKit.h>

@interface WXMWAddIssueView ()

@end

@implementation WXMWAddIssueView

- (IBAction)undwindFromAddLabels:(UIStoryboardSegue *)unwindSegue
{
    // Unwind that thang
}

- (IBAction)unwindFromAssignUser:(UIStoryboardSegue *)unwindSegue
{
    // Unwind that thang
}

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    [defaults setObject:emptyArray forKey:@"temp_new_issue_labels"];
    [defaults synchronize];
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

- (IBAction)addNewIssue:(id)sender {
    
    NSString *newIssueName = _issueName.text;
    NSString *newIssueComments = _issueComments.text;
    
    if ([newIssueName isEqualToString:@""]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose a name."
                                                        message:@"A name is required for an issue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
        
        [self performSegueWithIdentifier:@"undwindToIssueList" sender:self];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *selectedLabels = [defaults objectForKey:@"temp_new_issue_labels"];
        NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
        NSString *userName = [defaults objectForKey:@"user_name"];
        
        [defaults setBool:YES forKey:@"look_for_new_issue"];
        [defaults synchronize];
        
        NSString *token = [defaults objectForKey:@"token"];
        OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
        OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
        
        RACSignal *createNewIssueRequest = [client createIssueForRepo:currentRepoName owner:userName labels:selectedLabels title:newIssueName body:newIssueComments];
        
        [[createNewIssueRequest collect] subscribeNext:^(OCTIssue *issue) {
            
            [defaults setBool:YES forKey:@"newly_created_issue_found"];
            
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}
@end
