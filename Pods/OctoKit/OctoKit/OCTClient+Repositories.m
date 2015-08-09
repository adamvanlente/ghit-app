//
//  OCTClient+Repositories.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2013-11-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTClient+Repositories.h"
#import "OCTClient+Private.h"
#import "OCTContent.h"
#import "OCTOrganization.h"
#import "OCTRepository.h"
#import "OCTTeam.h"
#import "OCTBranch.h"
#import "OCTIssue.h"
#import "OCTIssueComment.h"
#import "OCTIssueLabel.h"
#import "OCTUser.h"

@implementation OCTClient (Repositories)

- (RACSignal *)fetchUserRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repos" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchUserPublicRepositories {
    return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/repositories" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchUserStarredRepositories {
	return [[self enqueueUserRequestWithMethod:@"GET" relativePath:@"/starred" parameters:nil resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoriesForOrganization:(OCTOrganization *)organization {
	NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"orgs/%@/repos", organization.login] parameters:nil notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	return [self createRepositoryWithName:name organization:nil team:nil description:description private:isPrivate];
}

- (RACSignal *)createIssueForRepo:(NSString *)name owner:(NSString *)owner labels:(NSArray *)labels title:(NSString *)title body:(NSString *)body assignee:(NSString * )assignee {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
   
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"title"] = title;
	options[@"body"] = body;
    options[@"labels"] = labels;
    
    if (assignee != nil) {
        options[@"assignee"] = assignee;
    }

	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues", owner, name];
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:options notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

- (RACSignal *)updateIssueForRepo:(NSString *)name owner:(NSString *)owner labels:(NSArray *)labels title:(NSString *)title body:(NSString *)body assignee:(NSString * )assignee objectId:(NSUInteger)objectId state:(NSString *)state {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
    NSString *id = [NSString stringWithFormat:@"%lu", (unsigned long)objectId];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"title"] = title;
	options[@"body"] = body;
    options[@"labels"] = labels;
    options[@"state"] = state;
    
    if (assignee != nil) {
        options[@"assignee"] = assignee;
    }
    
	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues/%@", owner, name, id];
	NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:options notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

- (RACSignal *)fetchContributorsForRepo:(NSString *)name owner:(NSString *)owner {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
    
	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/contributors", owner, name];
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTUser.class] oct_parsedResults];
}

- (RACSignal *)fetchIssuesForRepo:(NSString *)name owner:(NSString *)owner state:(NSString *)state {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues?state=%@", owner, name, state];
	
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

- (RACSignal *)fetchIndividualIssueFromRepoWithName:(NSString *)name owner:(NSString *)owner objectId:(id)objectId {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues/%@", owner, name, objectId];

    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}




- (RACSignal *)fetchIssueLabelsForRepoWithName:(NSString *)repoName owner:(NSString *)owner {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
    
	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/labels", owner, repoName];
	
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTIssue.class] oct_parsedResults];
}

- (RACSignal *)fetchCommentsForIssueWithNumber:(NSString *)number name:(NSString *)name owner:(NSString *)owner {
    
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
    
	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues/%@/comments", owner, name, number];
	
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

	return [[self enqueueRequest:request resultClass:OCTIssueComment.class] oct_parsedResults];
}


- (RACSignal *)addCommentToIssueWithNumber:(NSString *)number name:(NSString *)name owner:(NSString *)owner comments:(NSString *) comments {
    
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"body"] = comments;
	
    NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/issues/%@/comments", owner, name, number];
	
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:options notMatchingEtag:nil];
	return [[self enqueueRequest:request resultClass:OCTIssueComment.class] oct_parsedResults];
}

- (RACSignal *)createRepositoryWithName:(NSString *)name organization:(OCTOrganization *)organization team:(OCTTeam *)team description:(NSString *)description private:(BOOL)isPrivate {
	if (!self.authenticated) return [RACSignal error:self.class.authenticationRequiredError];

	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[@"name"] = name;
	options[@"private"] = @(isPrivate);

	if (description != nil) options[@"description"] = description;
	if (team != nil) options[@"team_id"] = team.objectID;
	
	NSString *path = (organization == nil ? @"user/repos" : [NSString stringWithFormat:@"orgs/%@/repos", organization.login]);
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:options notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}



- (RACSignal *)fetchRelativePath:(NSString *)relativePath inRepository:(OCTRepository *)repository reference:(NSString *)reference {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	relativePath = relativePath ?: @"";
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/contents/%@", repository.ownerLogin, repository.name, relativePath];
	
	NSDictionary *parameters = nil;
	if (reference.length > 0) {
		parameters = @{ @"ref": reference };
	}
	
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryReadme:(OCTRepository *)repository {
	NSParameterAssert(repository != nil);
	NSParameterAssert(repository.name.length > 0);
	NSParameterAssert(repository.ownerLogin.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/readme", repository.ownerLogin, repository.name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTContent.class] oct_parsedResults];
}

- (RACSignal *)fetchRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);
	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];
	
	return [[self enqueueRequest:request resultClass:OCTRepository.class] oct_parsedResults];
}

- (RACSignal *)fetchBranchesForRepositoryWithName:(NSString *)name owner:(NSString *)owner {
	NSParameterAssert(name.length > 0);
	NSParameterAssert(owner.length > 0);

	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/branches", owner, name];
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTBranch.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitsFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA {
	NSParameterAssert(repository);

	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/commits", repository.ownerLogin, repository.name];

	NSDictionary *parameters = nil;
	if (SHA.length > 0) {
		parameters = @{ @"sha": SHA };
	}

	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTGitCommit.class] oct_parsedResults];
}

- (RACSignal *)fetchCommitFromRepository:(OCTRepository *)repository SHA:(NSString *)SHA {
	NSParameterAssert(repository);
	NSParameterAssert(SHA.length > 0);

	NSString *path = [NSString stringWithFormat:@"/repos/%@/%@/commits/%@", repository.ownerLogin, repository.name, SHA];
	NSDictionary *parameters = @{@"sha": SHA};
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];

	return [[self enqueueRequest:request resultClass:OCTGitCommit.class] oct_parsedResults];
}

@end
