//
//  NewsViewController.h
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSString *stockSymbolString;

@end
