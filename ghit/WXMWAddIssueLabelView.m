//
//  WXMWAddIssueLabelView.m
//  ghit
//
//  Created by Adam VanLente on 9/27/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWAddIssueLabelView.h"

@interface WXMWAddIssueLabelView ()

@end

NSMutableArray *selectedItems;

@implementation WXMWAddIssueLabelView


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self resetIssueLabelButtons];
    
    selectedItems = [[NSMutableArray alloc] init];
    [selectedItems removeAllObjects];
}

- (void)resetIssueLabelButtons
{
    [_labelBugButton setAlpha:0.4];
    [_labelBugButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelEnhancementButton setAlpha:0.4];
    [_labelEnhancementButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelInvalidButton setAlpha:0.4];
    [_labelInvalidButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelQuestionButton setAlpha:0.4];
    [_labelQuestionButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelDuplicateButton setAlpha:0.4];
    [_labelDuplicateButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelHelpWantedButton setAlpha:0.4];
    [_labelHelpWantedButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_labelWontfixButton setAlpha:0.4];
    [_labelWontfixButton addTarget:self action:@selector(toggleLabelButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toggleLabelButton:(id)sender {

    CGFloat alpha = 0.4;
    
    NSString *clickedLabel = [sender currentTitle];

    if ([selectedItems containsObject:clickedLabel]) {
        [selectedItems removeObject:clickedLabel];
    } else {
        [selectedItems addObject:clickedLabel];
        alpha = 1.0;
    }
    
    if ([clickedLabel isEqualToString:@"bug"]) {
        [_labelBugButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"enhancement"]) {
        [_labelEnhancementButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"invalid"]) {
        [_labelInvalidButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"question"]) {
        [_labelQuestionButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"duplicate"]) {
        [_labelDuplicateButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"help wanted"]) {
        [_labelHelpWantedButton setAlpha:alpha];
    }
    
    if ([clickedLabel isEqualToString:@"wontfix"]) {
        [_labelWontfixButton setAlpha:alpha];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedItems forKey:@"temp_new_issue_labels"];
    [defaults synchronize];
    
}
@end
