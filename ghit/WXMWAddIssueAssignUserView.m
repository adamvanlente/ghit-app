//
//  WXMWAddIssueAssignUserView.m
//  ghit
//
//  Created by Adam VanLente on 9/28/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWAddIssueAssignUserView.h"
#import <OctoKit/OctoKit.h>

@interface WXMWAddIssueAssignUserView ()

@end

@implementation WXMWAddIssueAssignUserView

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
    
    NSLog(@"test");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"user_name"];
    
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    RACSignal *contribRequest = [client fetchContributorsForRepo:currentRepoName owner:userName];
    [[contribRequest collect] subscribeNext:^(OCTUser *contributors) {
        NSLog(@"%@", contributors);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
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

@end
