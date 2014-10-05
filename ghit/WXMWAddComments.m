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

- (void)initNewComment
{
    _commentTextField.text = @"";
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

- (IBAction)newCommentAdd:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];
    NSUInteger issueId = [issue.objectID integerValue];
    NSString *id = [NSString stringWithFormat:@"%lu", (unsigned long)issueId];
    
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    NSString *comments = _commentTextField.text;
    
    RACSignal *newCommentRequest = [client addCommentToIssueWithNumber:id name:currentRepoName owner:userName comments:comments];
    
    [newCommentRequest subscribeNext:^(OCTIssueComment *newComment) {
       
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
