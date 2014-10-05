//
//  WXMWIssueEditorAddLabels.h
//  ghit
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWIssueEditorAddLabels : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *labelHolder;
@property (weak, nonatomic) IBOutlet UIButton *addLabelsButton;
- (IBAction)addLabelsToIssue:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelAddingLabelsToIssue:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end
