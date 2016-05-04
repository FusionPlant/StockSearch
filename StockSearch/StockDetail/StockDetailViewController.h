//
//  StockDetailViewController.h
//  StockSearch
//
//  Created by Tailai Ye on 4/24/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StockSearchViewController.h"

@interface StockDetailViewController : UIViewController

@property (weak, nonatomic) StockSearchViewController *stockSearchViewController;
@property (nonatomic) enum TabSelection stockDetailTabSelection;
@property (nonatomic) NSString *stockSymbolString;
@property (nonatomic) BOOL isFavoriteStock;

@end
