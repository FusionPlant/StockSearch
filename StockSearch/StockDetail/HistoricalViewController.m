//
//  HistoricalViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "HistoricalViewController.h"

@interface HistoricalViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *stockChartWebView;

@end

@implementation HistoricalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load web view
    NSURL *stockChartURL = [NSURL URLWithString:[@"http://stockchart-1301.appspot.com/?symbol=" stringByAppendingString:self.stockSymbolString]];
    [self.stockChartWebView loadRequest:[NSURLRequest requestWithURL:stockChartURL]];
    self.stockChartWebView.scrollView.scrollEnabled = NO;
}

@end
