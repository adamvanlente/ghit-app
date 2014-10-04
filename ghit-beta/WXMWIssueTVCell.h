//
//  WXMWIssueTVCell.h
//  ghit-beta
//
//  Created by Adam VanLente on 9/25/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWIssueTVCell : UITableViewCell

// Labels for an issue cell.
@property (weak, nonatomic) IBOutlet UILabel *issueTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueClosedLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueOpenLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueNumberLabel;

@end
