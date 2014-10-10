//
//  Utils.h
//  ghit
//
//  Created by Adam VanLente on 9/30/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Utils : NSObject
+ (UIColor*)hexColor:(NSString *)hex;
+ (void)storeUser:(NSString *)email name:(NSString *)name username:(NSString *)username publicCount:(NSUInteger)publicCount privateCount:(NSUInteger)privateCount;
+ (NSString *)getFontColorForBackgroundColor:(UIColor *)color;
@end
