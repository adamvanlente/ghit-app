//
//  Utils.m
//  ghit
//
//  Created by Adam VanLente on 9/30/14.
//  Copyright (c) 2014 West by Midwest. All rights reserved.
//

#import "Utils.h"
#import "Config.h"

@implementation Utils

NSMutableData *_responseData;

// Create a UI Color given a hex color.
+(UIColor*)hexColor:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) return [UIColor grayColor];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (void)storeUser:(NSString *)email name:(NSString *)name username:(NSString *)username publicCount:(NSUInteger)publicCount privateCount:(NSUInteger)privateCount
{

    NSMutableDictionary *config = [Config ghCredentials];
    NSString *baseUrl = [config objectForKey:@"storageUrl"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%lu/%lu", baseUrl, email, name, username, publicCount, privateCount];

    NSURL *reqUrl = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self sendSynchronousRequestToMongoWithUrl:reqUrl];
}

+ (void)sendErrorMessageToDatabaseWithMessage:(NSString *)msg {

    NSMutableDictionary *config = [Config ghCredentials];
    NSString *baseUrl = [config objectForKey:@"errorMessageUrl"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", baseUrl, msg];

    NSURL *reqUrl = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self sendSynchronousRequestToMongoWithUrl:reqUrl];
}

+ (void)sendSynchronousRequestToMongoWithUrl:(NSURL *) reqUrl
{
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:reqUrl];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
}

+ (NSString *)getFontColorForBackgroundColor:(UIColor *)color
{
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    
    if (colorBrightness < 0.6) {
        return @"FFFFFF";
    } else {
        return @"333333";
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

+ (id)alloc {
    [NSException raise:@"Cannot be instantiated!" format:@"Static class 'ClassName' cannot be instantiated!"];
    return nil;
}

@end