//
//  WXMWAddIssueViewController.h
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWAddIssueViewController : UIViewController

// Outlets for creating a new issue.
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *issueTitle;
@property (weak, nonatomic) IBOutlet UITextView *issueBody;
@property (weak, nonatomic) IBOutlet UIButton *addLabelsButton;
@property (weak, nonatomic) IBOutlet UIButton *assignUserButton;
@property (weak, nonatomic) IBOutlet UIButton *addNewIssueButton;
@property (weak, nonatomic) IBOutlet UILabel *issueEditorTitle;
@property (weak, nonatomic) IBOutlet UIButton *updateAndCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *updateIssueButton;

// Actions for creating a new issue.
- (IBAction)cancelCreateNewIssue:(id)sender;
- (IBAction)addNewIssue:(id)sender;
- (IBAction)updateAndClose:(id)sender;

@end
