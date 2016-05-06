//
//  StockNameCompletion.m
//  StockSearch
//
//  Created by Tailai Ye on 4/18/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "StockNameCompletion.h"

@implementation StockNameCompletion

# pragma mark - AutoComplete DataSource

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler {
    
    // Only make request when the user enters a minimum of 3 characters
    if (string.length < 3) {
        handler([NSArray array]);
        return;
    }
    
    // Get the string before the first hyphen in the text field.
    NSRange hyphenRange = [string rangeOfString:@"-"];
    NSUInteger symbolLength = hyphenRange.location;
    if (symbolLength == NSNotFound) {
        symbolLength = string.length;
    }
    NSString *symbolString = [string substringToIndex:symbolLength].uppercaseString;
    
    // Check symbolString only contain letters
    NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet];
    if ([symbolString stringByTrimmingCharactersInSet:letterSet].length > 0) {
        handler([NSArray array]);
        return;
    }
    
    //Issue network request for json reply.
    NSString *URLString = [@"http://stockSearch-1266.appspot.com/?company_name=" stringByAppendingString:symbolString];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLSessionDataTask *stockSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
        if (error == nil) {
            NSArray *searchResultArray = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
            NSMutableArray *autoCompleteArray = [NSMutableArray arrayWithCapacity:searchResultArray.count];
            
            for (NSDictionary *stockItem in searchResultArray) {
                NSString *autoCompleteString = [NSString stringWithFormat:@"%@-%@-%@", stockItem[@"Symbol"], stockItem[@"Name"], stockItem[@"Exchange"]];
                [autoCompleteArray addObject:autoCompleteString];
            }
            handler([autoCompleteArray copy]);
        } else {
            //network error
            NSLog(@"Network Error When Auto-Completing!");
            handler([NSArray array]);
        }
    }];
    
    [stockSearchTask resume];
    
}

#pragma mark - AutoComplete Delegate

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    autoCompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


@end
