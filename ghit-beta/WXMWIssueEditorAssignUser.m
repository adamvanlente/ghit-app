//
//  WXMWIssueEditorAssignUser.m
//  ghit-beta
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
    _loadingLabel.hidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *contribs = [defaults objectForKey:@"current_repo_contributors"];
    
    [self makeUserLabels:contribs];
}

- (void)makeUserLabels:(NSArray *)allowedContributors
{
    NSUInteger fromTop = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedUser = [defaults objectForKey:@"current_issue_assignee"];
    
    for (id user in allowedContributors) {
        
        [self createUserButton:user fromTop:fromTop selectedUser:selectedUser];
        fromTop += 50;;
    }
    
    [self createUserButton:@"no assignee" fromTop:fromTop selectedUser:selectedUser];
    
    _loadingLabel.hidden = YES;
}

- (void)createUserButton:(NSString *)user fromTop:(CGFloat)fromTop selectedUser:(NSString *)selectedUser
{
    CGRect rect = CGRectMake(30, fromTop, 250, 35);
    UIButton *labelLabel = [[UIButton alloc] initWithFrame:rect];
    [labelLabel setTitle:user forState:UIControlStateNormal];
    labelLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSString *bgColorString = @"F1F1F1";
    NSString *textColorString = @"333333";

    if ([user isEqualToString:selectedUser]) {
        bgColorString = @"2EAD59";
        textColorString = @"F1F1F1";
    }
    
    if (!selectedUser || [selectedUser isEqualToString:@""]) {
        if ([user isEqualToString:@"no assignee"]) {
            bgColorString = @"2EAD59";
            textColorString = @"F1F1F1";
        }
    }

    [labelLabel setTitleColor:[Utils hexColor:textColorString] forState:UIControlStateNormal];
    [labelLabel setBackgroundColor: [Utils hexColor:bgColorString]];
    labelLabel.layer.cornerRadius = 2;
    labelLabel.layer.masksToBounds = YES;
    
    [_userHolder addSubview:labelLabel];
    
    [labelLabel addTarget:self action:@selector(addUserAsAssignee:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)addUserAsAssignee:(id)sender
{
    NSString *user = [sender currentTitle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([user isEqualToString:@"no assignee"]) {
        user = nil;
    }
    
    [defaults setObject:user forKey:@"current_issue_assignee"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)cancelAssignUser:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
