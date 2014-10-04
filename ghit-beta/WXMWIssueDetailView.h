//
//  WXMWIssueDetailView.h
//  ghit-beta
//
//  Created by Adam VanLente on 9/26/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWIssueDetailView : UIViewController

// Labels for the detail view of an Issue item.
@property (weak, nonatomic) IBOutlet UITextView *issueDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueClosedLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueOpenLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentRepoLabel;
@property (weak, nonatomic) IBOutlet UIView *labelHolderView;
@property (weak, nonatomic) IBOutlet UILabel *assigneeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton *viewCommentsButton;
@property (weak, nonatomic) IBOutlet UIWebView *webViewer;

@end
