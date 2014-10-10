//
//  WXMWIssueEditorAddLabels.h
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWIssueEditorAddLabels : UIViewController

// Outleys for associating labels with an issue.
@property (weak, nonatomic) IBOutlet UIScrollView *labelHolder;
@property (weak, nonatomic) IBOutlet UIButton *addLabelsButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

// Actions for editing labels associated with an issue.
- (IBAction)addLabelsToIssue:(id)sender;
- (IBAction)cancelAddingLabelsToIssue:(id)sender;

@end
