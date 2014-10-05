//
//  WXMWViewComments.h
//  ghit
//
//  Created by Adam VanLente on 10/1/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWViewComments : UIViewController
- (IBAction)backToIssue:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *commentHolder;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end
