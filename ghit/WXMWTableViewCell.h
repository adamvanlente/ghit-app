//
//  WXMWTableViewCell.h
//  ghit
//
//  Created by Adam VanLente on 9/23/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWTableViewCell : UITableViewCell

// Labels and image holder for a repo list item.
@property (strong, nonatomic) IBOutlet UILabel *repoNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *repoDescLabel;
@property (strong, nonatomic) IBOutlet UILabel *issueCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicLabel;
@property (strong, nonatomic) IBOutlet UIImageView *repoIcon;
@property (weak, nonatomic) IBOutlet UILabel *privateLabel;
@property (weak, nonatomic) IBOutlet UILabel *openIssuesNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *repoOwnerLabel;

@end
