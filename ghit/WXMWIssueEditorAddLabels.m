//
//  WXMWIssueEditorAddLabels.m
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWIssueEditorAddLabels.h"
#import <OctoKit/OctoKit.h>
#import "Utils.h"

@interface WXMWIssueEditorAddLabels ()

@end

NSMutableArray *selectedItems;

@implementation WXMWIssueEditorAddLabels

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
}

- (void)viewDidAppear:(BOOL)animated
{
    // Set a list of selected items to its initial state.
    [self resetSelectedItems];
    
    // Label selector may be in edit mode.  Either way, need to load all labels for repo.
    [self loadLabelsForRepo];
}

- (void)loadLabelsForRepo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *currentRepo = [defaults objectForKey:@"current_repo_name"];
    
    _loadingLabel.hidden = NO;
    
    NSString *token = [defaults objectForKey:@"token"];
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
        RACSignal *issueLabelRequest = [client fetchIssueLabelsForRepoWithName:currentRepo owner:userName];
        [[issueLabelRequest collect] subscribeNext:^(NSArray *labels) {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               //back on main thread
                               [self showLabelsOnScreen:labels];
                                _loadingLabel.hidden = YES;
                           });
            
        } error:^(NSError *error) {
            // Show an alert.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                            message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    
}

- (void)resetSelectedItems
{
    // Init our array of selected items.
    selectedItems = [[NSMutableArray alloc] init];
    [selectedItems removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *existingLabels = [defaults objectForKey:@"temp_new_issue_labels"];
    
    for (id label in existingLabels) {
        [selectedItems addObject:label];
    }
}

// Given a list of labels, show an button for each one.
- (void)showLabelsOnScreen:(NSArray *)labels
{
    
    CGFloat fromTop = 0;
    CGFloat alpha = 0.2;
    
    for (id label in labels) {
        OCTIssue *issueLabel = label;
        NSString *name = issueLabel.name;
        NSString *color = issueLabel.color;
        
        UIButton *labelButton =[[UIButton alloc] initWithFrame:CGRectMake(40, fromTop, 240, 40)];
        [labelButton setTitle:name forState:UIControlStateNormal];
        labelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        
        UIColor *bgColor = [Utils hexColor:color];
        [labelButton setBackgroundColor: bgColor];
        
        const CGFloat *componentColors = CGColorGetComponents(bgColor.CGColor);
        
        CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
        
        if (colorBrightness < 0.6) {
             [labelButton setTitleColor:[Utils hexColor:@"FFFFFF"] forState:UIControlStateNormal];
        } else {
             [labelButton setTitleColor:[Utils hexColor:@"333333"] forState:UIControlStateNormal];
        }
        
        [labelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        // Keep track of which labels are selected.
        if (![selectedItems containsObject:name]) {
            [labelButton setAlpha:alpha];
        }
        
        [labelButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_labelHolder addSubview:labelButton];
        
        fromTop += 50;
    }
    
    [_labelHolder setUserInteractionEnabled:YES];
    _labelHolder.contentSize = CGSizeMake(300, fromTop + 100);
    
}

- (void)toggleLabelButton:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    NSString *buttonTitle = button.currentTitle;
    
    CGFloat alpha = 0.3;
    
    // Keep track of which labels are selected.
    if ([selectedItems containsObject:buttonTitle]) {
        [selectedItems removeObject:buttonTitle];
    } else {
        [selectedItems addObject:buttonTitle];
        alpha = 1.0;
    }

    [button setAlpha:alpha];
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

- (IBAction)addLabelsToIssue:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedItems forKey:@"temp_new_issue_labels"];

    [defaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAddingLabelsToIssue:(id)sender {
    
    // Do nothing else.  Cancelling out, so all is as it should be.
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
