//
//  OCTIssueComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueLabel.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTIssueLabel

@synthesize name = _name;
@synthesize color = _color;

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
    @"name": @"name",
    @"color": @"color",
  }];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
  return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)creationDateJSONTransformer {
  return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedDateJSONTransformer {
  return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}
@end
