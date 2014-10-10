//
//  WXMWAddComments.m
//  ghit
//
//  Created by Adam VanLente on 10/1/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWAddComments.h"
#import <OctoKit/OctoKit.h>

@interface WXMWAddComments ()

@end

@implementation WXMWAddComments

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
    
    [self initNewComment];
}

// Clear out the text field for a new comment to be added.
- (void)initNewComment
{
    _commentTextField.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newCommentAdd:(id)sender {
    
    // Access the defaults and get the currently exploring issue.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];

    // Get the issue ID needed for the request.
    NSUInteger issueId = [issue.objectID integerValue];
    NSString *id = [NSString stringWithFormat:@"%lu", (unsigned long)issueId];
    
    // Get the current repo name for the request.
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];

    // Get username and create a OCTClient for the request.
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    // Get the new comment.
    NSString *comments = _commentTextField.text;
    
    // Construct the request for the new comment.
    RACSignal *newCommentRequest = [client addCommentToIssueWithNumber:id name:currentRepoName owner:userName comments:comments];
    
    // Initiate request.
    [newCommentRequest subscribeNext:^(OCTIssueComment *newComment) {
       
        // Remove modal controller on completion.  This will roll back to the previous view, which
        // will either be the issue detail view or the list of existing comments.
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (IBAction)newCommentCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
