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

// Load the labels for the current repo.  Though the labels are for the specific issue here,
// available labels are obtained on a repo by repo basis; users can create custom labels
// at the repo level.
- (void)loadLabelsForRepo
{
    // Get the current repo information.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *currentRepo = [defaults objectForKey:@"current_repo_name"];
    
    // Reveal the loading indicator while the request is made.
    _loadingLabel.hidden = NO;
    
    // Create a client for the request.
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

// Reset the list of selected items in memory.
- (void)resetSelectedItems
{
    // Init our array of selected items.
    selectedItems = [[NSMutableArray alloc] init];
    [selectedItems removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *existingLabels = [defaults objectForKey:@"temp_new_issue_labels"];
    
    // Clear any content that may be hanging around in memory.
    for (id label in existingLabels) {
        [selectedItems addObject:label];
    }
}

// Given a list of labels, show an button for each one.
- (void)showLabelsOnScreen:(NSArray *)labels
{
    // Starting distance from top of canvas and default opacity for the labels.
    CGFloat fromTop = 0;
    CGFloat alpha = 0.2;
    
    // For each label that can be associated with an issue, create a button in the UI.
    for (id label in labels) {
        OCTIssue *issueLabel = label;

        // Set name and color (Github api provides us with the color).
        NSString *name = issueLabel.name;
        NSString *color = issueLabel.color;
        
        // Create the button and set basic display properties.
        UIButton *labelButton =[[UIButton alloc] initWithFrame:CGRectMake(40, fromTop, 240, 40)];
        [labelButton setTitle:name forState:UIControlStateNormal];
        labelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        
        // Set background color for the label.
        UIColor *bgColor = [Utils hexColor:color];
        [labelButton setBackgroundColor: bgColor];
        
        // Font color.  This is determined based on the background color.
        NSString *fontColor = [Utils getFontColorForBackgroundColor:bgColor];
        
        // Set text alignment and font color.
        [labelButton setTitleColor:[Utils hexColor:fontColor] forState:UIControlStateNormal];
        [labelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        // If label is currently selected, adjust its opacity to 100% to indicate such.
        if (![selectedItems containsObject:name]) {
            [labelButton setAlpha:alpha];
        }
        
        // Add a toggle event for when the user clicks the label.  This actually selects the label.
        [labelButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add label to the view.
        [_labelHolder addSubview:labelButton];
        
        // Increment the distance the next button will be from the top.
        fromTop += 50;
    }
    
    // Set the label holders interaction to enabled - will allow user to scroll if list is too long.
    [_labelHolder setUserInteractionEnabled:YES];
    _labelHolder.contentSize = CGSizeMake(300, fromTop + 100);
    
}

// Toggle a label on or off.
- (void)toggleLabelButton:(id)sender
{
    // Get the button from the sender id.
    UIButton *button = (UIButton *)sender;
    NSString *buttonTitle = button.currentTitle;
    
    // Default alpha.
    CGFloat alpha = 0.2;
    
    // If item is selected, remove it.  If not, add it to list of selected and increase
    // opacity to 100%.
    if ([selectedItems containsObject:buttonTitle]) {
        [selectedItems removeObject:buttonTitle];
    } else {
        [selectedItems addObject:buttonTitle];
        alpha = 1.0;
    }

    // Indicate what has happened to the user; show if a button has been selected/deselected.
    [button setAlpha:alpha];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// User is confirming their selection.  Add the selected labels to a list held in user defaults.
- (IBAction)addLabelsToIssue:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedItems forKey:@"temp_new_issue_labels"];

    [defaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// User is cancelling out, so all is as it should be.  Simply dismiss the current view.
- (IBAction)cancelAddingLabelsToIssue:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
