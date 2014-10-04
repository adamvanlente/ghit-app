//
//  WXMWAddIssueView.h
//  ghit-beta
//
//  Created by Adam VanLente on 9/27/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWAddIssueView : UIViewController
- (IBAction)addNewIssue:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *issueName;
@property (weak, nonatomic) IBOutlet UITextField *issueComments;

@end
