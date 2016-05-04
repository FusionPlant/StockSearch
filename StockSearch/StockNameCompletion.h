//
//  StockNameCompletion.h
//  StockSearch
//
//  Created by Tailai Ye on 4/18/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextFieldDataSource.h"
#import "MLPAutoCompleteTextFieldDelegate.h"

@interface StockNameCompletion : NSObject <MLPAutoCompleteTextFieldDataSource, MLPAutoCompleteTextFieldDelegate>

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler;

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView;

@end
