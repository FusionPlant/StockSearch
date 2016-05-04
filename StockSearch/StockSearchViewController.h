//
//  StockSearchViewController.h
//  StockSearch
//
//  Created by Tailai Ye on 4/17/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

enum TabSelection {
    TabSelectionCurrent,
    TabSelectionHistorical,
    TabSelectionNews
};

- (void)unwindFromStockDetail:(id)sourceViewController;

@end
