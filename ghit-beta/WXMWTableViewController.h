//
//  WXMWTableViewController.h
//  ghit-beta
//
//  Created by Adam VanLente on 9/23/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface WXMWTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// Label that indicates if repos are loading.
@property (weak, nonatomic) IBOutlet UILabel *loadingReposLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;

@end
