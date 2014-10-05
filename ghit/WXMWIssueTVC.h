//
//  WXMWIssueTVC.h
//  ghit
//
//  Created by Adam VanLente on 9/25/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface WXMWIssueTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// Labels for the list of issues view.
@property (strong, nonatomic) IBOutlet UILabel *loadingIssuesLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentRepoNameLabel;

@end
