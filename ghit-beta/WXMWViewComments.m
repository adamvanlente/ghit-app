//
//  WXMWViewComments.m
//  ghit-beta
//
//  Created by Adam VanLente on 10/1/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "WXMWViewComments.h"
#import "Utils.h"
#import <OctoKit/OctoKit.h>
#import <MMMarkdown/MMMarkdown.h>


@interface WXMWViewComments ()

@end

@implementation WXMWViewComments

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

}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadComments];    
}

- (void)loadComments
{
    _loadingLabel.hidden = NO;
    
    // Get the current issue and repo name from defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedIssue = [defaults objectForKey:@"currently_viewing_issue"];
    OCTIssue *issue = [NSKeyedUnarchiver unarchiveObjectWithData:encodedIssue];
    
    NSString *currentRepoName = [defaults objectForKey:@"current_repo_name"];
    NSString *userName = [defaults objectForKey:@"user_name"];
    NSString *id = issue.objectID;
    
    NSString *token = [defaults objectForKey:@"token"];
    
    // Create a user and an authenticated client.
    OCTUser *user = [OCTUser userWithRawLogin:userName server:OCTServer.dotComServer];
    OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
    
    // Create a request for the list of issues.
    RACSignal *commentRequest = [client fetchCommentsForIssueWithNumber:id name:currentRepoName owner:userName];
    
    // Make the request and collect the response as one array.
    [[commentRequest collect] subscribeNext:^(NSArray *comments) {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           //back on main thread
                           _loadingLabel.hidden = YES;
                           [self showCommentsOnScreen:comments];
                       });

        
    } error:^(NSError *error) {
        // Show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)showCommentsOnScreen:(NSArray *)comments
{
    
    CGFloat fromTop = 25;
    CGFloat padding = 10;
    
    NSUInteger count = comments.count;

    for (id commentObj in comments) {
        count--;
        
        OCTIssueComment *comment = [comments objectAtIndex:count];

        UILabel *commentLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, fromTop, 300, 0)];
        [commentLabel setBackgroundColor: [Utils hexColor:@"ffffff"]];
        commentLabel.text = comment.body;
        commentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        commentLabel.numberOfLines = 0; //will wrap text in new line
        [commentLabel sizeToFit];
        commentLabel.text = @"";

        CGFloat prevLabelHeight = commentLabel.frame.size.height;
        CGFloat newCommentHeight = prevLabelHeight + (padding * 2.0);
        commentLabel.frame = CGRectMake(20, fromTop, 290, newCommentHeight);

        CGFloat textLabelHeight = prevLabelHeight + (padding * 2);

        NSString *markedDownComment = [MMMarkdown HTMLStringWithMarkdown:comment.body extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];
        
        UIWebView *textLabel =[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 287, textLabelHeight)];

        [textLabel setOpaque:NO];
        textLabel.backgroundColor = [Utils hexColor:@"edecec"];
        [textLabel loadHTMLString:[NSString stringWithFormat:@"<font face='Helvetica' size='3'>%@", markedDownComment] baseURL:nil];
        
        [textLabel sizeToFit];
        [commentLabel addSubview:textLabel];

        commentLabel.layer.cornerRadius = 3;
        commentLabel.clipsToBounds = YES;
        [_commentHolder addSubview:commentLabel];

        NSMutableString *note = [NSMutableString stringWithFormat:@"by: "];
        [note appendString:comment.commenterLogin];
        [note appendString:@" on "];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        //Optionally for time zone conversions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSString *stringFromDate = [formatter stringFromDate:comment.creationDate];
        [note appendString:stringFromDate];
        
        CGFloat noteHeight = (fromTop + prevLabelHeight + (padding * 2.5));
        UILabel *commentNotesLabel = [[UILabel alloc] initWithFrame:CGRectMake((padding * 2), noteHeight, 290, (padding * 2))];
        commentNotesLabel.textColor = [Utils hexColor:@"333333"];
        commentNotesLabel.text = note;
        commentNotesLabel.font = [UIFont systemFontOfSize:12];
        [_commentHolder addSubview:commentNotesLabel];
        
        fromTop += prevLabelHeight + 50;
    }

    [_commentHolder setUserInteractionEnabled:YES];
     _commentHolder.contentSize = CGSizeMake(290, fromTop);
    
    
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

- (IBAction)backToIssue:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
