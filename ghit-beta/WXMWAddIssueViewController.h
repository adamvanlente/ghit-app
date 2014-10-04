//
//  WXMWAddIssueViewController.h
//  ghit-beta
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWAddIssueViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelCreateNewIssue:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *issueTitle;

@property (weak, nonatomic) IBOutlet UITextView *issueBody;

@property (weak, nonatomic) IBOutlet UIButton *addLabelsButton;
@property (weak, nonatomic) IBOutlet UIButton *assignUserButton;
@property (weak, nonatomic) IBOutlet UIButton *addNewIssueButton;
- (IBAction)addNewIssue:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *issueEditorTitle;
@property (weak, nonatomic) IBOutlet UIButton *updateAndCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *updateIssueButton;
- (IBAction)updateAndClose:(id)sender;

@end
