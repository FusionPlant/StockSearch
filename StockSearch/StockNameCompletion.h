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


//- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
//shouldStyleAutoCompleteTableView:(UITableView *)autoCompleteTableView
//               forBorderStyle:(UITextBorderStyle)borderStyle;
//
///*IndexPath corresponds to the order of strings within the autocomplete table,
// not the original data source.*/
- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
//
//
///*IndexPath corresponds to the order of strings within the autocomplete table,
// not the original data source.
// autoCompleteObject may be nil if the selectedString had no object associated with it.
// */
//- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
//  didSelectAutoCompleteString:(NSString *)selectedString
//       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
//            forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView;

@end
