//
//  WXMWIssueEditorAssignUser.h
//  ghit-beta
//
//  Created by Adam VanLente on 10/2/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWIssueEditorAssignUser : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *userHolder;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelAssignUser:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@end
