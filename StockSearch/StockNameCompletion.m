//
//  StockNameCompletion.m
//  StockSearch
//
//  Created by Tailai Ye on 4/18/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "StockNameCompletion.h"
#import "MLPAutoCompleteTextField.h"
#import "MLPAutoCompletionObject.h"

@implementation StockNameCompletion

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler {
    
    //Only make request when the user enters a minimum of 3 characters
    if (string.length < 3) {
        handler([NSArray array]);
    }
    
    
    //Get the string before the first hyphen in the text field.
    //TODO: also sanitize space and so on.
    NSRange hyphenRange = [string rangeOfString:@"-"];
    NSUInteger symbolLength = hyphenRange.location;
    if (symbolLength == NSNotFound) {
        symbolLength = string.length;
    }
    NSString *symbolString = [string substringToIndex:symbolLength].uppercaseString;
    
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
            NSLog(@"Network Error Occurred When Auto-Completing!");
            handler([NSArray array]);
        }
    }];
    
    [stockSearchTask resume];
    
}

- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
    autoCompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


@end
