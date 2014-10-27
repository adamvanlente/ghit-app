//
//  WXMWAddComments.h
//  ghit
//
//  Created by Adam VanLente on 10/1/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWAddComments : UIViewController

// Outlets for adding comments.
@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
- (IBAction)newCommentAdd:(id)sender;
- (IBAction)newCommentCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *activityIndicatorLabel;

@end
