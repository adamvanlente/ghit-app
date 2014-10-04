//
//  WXMWAddIssueLabelView.h
//  ghit-beta
//
//  Created by Adam VanLente on 9/27/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMWAddIssueLabelView : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *labelBugButton;
@property (weak, nonatomic) IBOutlet UIButton *labelEnhancementButton;
@property (weak, nonatomic) IBOutlet UIButton *labelInvalidButton;
@property (weak, nonatomic) IBOutlet UIButton *labelQuestionButton;
@property (weak, nonatomic) IBOutlet UIButton *labelDuplicateButton;
@property (weak, nonatomic) IBOutlet UIButton *labelHelpWantedButton;
@property (weak, nonatomic) IBOutlet UIButton *labelWontfixButton;

- (IBAction)toggleLabelButton:(id)sender;



@end
