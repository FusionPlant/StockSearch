//
//  FavoriteStockTableViewCell.h
//  StockSearch
//
//  Created by Tailai Ye on 4/29/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteStockTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *stockPriceLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *stockPriceChangeLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *marketCapLabel;

@end
