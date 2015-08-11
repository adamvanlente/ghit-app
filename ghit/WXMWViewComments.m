//
//  WXMWViewComments.m
//  ghit
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
    [[_commentHolder subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
        dispatch_async(dispatch_get_main_queue(),
                       ^{

                            // Show an alert.
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                        message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                       });
    }];
}

// Show comments on screen, in order from newest to oldest.
- (void)showCommentsOnScreen:(NSArray *)comments
{
    
    CGFloat fromTop = 25;
    CGFloat padding = 10;
    
    NSUInteger count = comments.count;

    for (id commentObj in comments) {
        count--;
        
        OCTIssueComment *comment = [comments objectAtIndex:count];

        // Create a holder label for our comment.
        UILabel *commentLabel = [self makeCommentLabel:comment fromTop:fromTop];

        // Get height of current comment label and adjust it slightly.
        CGFloat prevLabelHeight = commentLabel.frame.size.height;
        CGFloat newCommentHeight = prevLabelHeight + (padding * 1.5);
        commentLabel.frame = CGRectMake(20, fromTop, 290, newCommentHeight);

        // Make a webview for the actual comment body.  Comment will be parsed as markdown,
        // so a webview is required in the event that there are html elements in the markdown.
        UIWebView *textLabel = [self makeInnerCommentWebView:prevLabelHeight comment:comment padding:padding];

        // Append the webview to the comment label and make some display adjustments.
        [commentLabel addSubview:textLabel];
        commentLabel.layer.cornerRadius = 3;
        commentLabel.clipsToBounds = YES;

        // Append the comment to the main holder - commentHolder.
        [_commentHolder addSubview:commentLabel];

        // Create note containing contributor and time of comment.
        NSMutableString *note = [self makeCommentNote:comment];

        // Set the location where the note should appear.
        CGFloat noteHeight = (fromTop + prevLabelHeight + (padding * 2));
        
        // Insert the comment.
        [self insertCommentNote:noteHeight padding:padding note:note];

        // Increment fromTop with each comment so the preceding comment is set in the right spot.
        fromTop += prevLabelHeight + 50;
    }

    // As loop concludes, enable user interaction for scrolling, and rest the size of the main
    // holder based on all the content that has just been placed in it.
    [_commentHolder setUserInteractionEnabled:YES];
     _commentHolder.contentSize = CGSizeMake(290, fromTop);
    
    
}

// Creates a label that holds a comment.  Note: this is an empty label created in order
// to give the illusion of padding in the UI.
- (UILabel *)makeCommentLabel:(OCTIssueComment *)comment fromTop:(NSUInteger)fromTop
{
    // Create a label for the comment.
    UILabel *commentLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, fromTop, 300, 0)];

    // Set comment background color.
    [commentLabel setBackgroundColor: [Utils hexColor:@"ffffff"]];

    // Set comment body and font details.
    commentLabel.text = comment.body;
    commentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    commentLabel.numberOfLines = 0; //will wrap text in new line

    // Force element to flex fit the text that has been inserted.
    [commentLabel sizeToFit];

    // Empty the label - we can now insert a smaller version of the text
    // which will make the comment appear padded.
    commentLabel.text = @"";
    
    return commentLabel;
}

// Create a web view that will hold the comment contents.
- (UIWebView *)makeInnerCommentWebView:(CGFloat)prevLabelHeight comment:(OCTIssueComment *)comment padding:(CGFloat)padding
{
    // Convert comment from markdown to html.
    NSString *markedDownComment = [MMMarkdown HTMLStringWithMarkdown:comment.body extensions:MMMarkdownExtensionsGitHubFlavored error:NULL];

    // Set label height and create it.
    CGFloat textLabelHeight = (prevLabelHeight + (padding * 2));
    UIWebView *textLabel =[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 287, textLabelHeight)];
    
    // Set display properties of webview label.
    [textLabel setOpaque:NO];
    textLabel.backgroundColor = [Utils hexColor:@"edecec"];
    [textLabel loadHTMLString:[NSString stringWithFormat:@"<style type='text/css'>body { font-family: 'Helvetica Neue', sans-serif; font-size: 16px; font-weight: light; color: #333; } img { display: block; width: 250px; height: 250px; margin: 12px auto; } </style>%@", markedDownComment] baseURL:nil];
    [textLabel sizeToFit];
    
    return textLabel;
}

- (NSMutableString *)makeCommentNote:(OCTIssueComment *)comment
{
    // Create a note/string that will contain the name of the commentor and the time of comment.
    NSMutableString *note = [NSMutableString stringWithFormat:@"by: "];
    
    // Commentor name.
    [note appendString:comment.commenterLogin];
    [note appendString:@" on "];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    // Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    // Create a string to represent the date and append to the note.
    NSString *stringFromDate = [formatter stringFromDate:comment.creationDate];
    [note appendString:stringFromDate];
    
    return note;
}

// Insert a note below the comment showing who created it and when.
- (void)insertCommentNote:(CGFloat)noteHeight padding:(CGFloat)padding note:(NSMutableString *)note
{
    UILabel *commentNotesLabel = [[UILabel alloc] initWithFrame:CGRectMake((padding * 3), noteHeight, 290, (padding * 2))];
    commentNotesLabel.textColor = [Utils hexColor:@"333333"];
    commentNotesLabel.text = note;
    commentNotesLabel.font = [UIFont systemFontOfSize:12];
    [_commentHolder addSubview:commentNotesLabel];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToIssue:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
