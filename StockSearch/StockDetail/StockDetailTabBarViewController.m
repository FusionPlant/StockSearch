//
//  StockDetailTabBarViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "StockDetailTabBarViewController.h"
#import "CurrentViewController.h"
#import "HistoricalViewController.h"
#import "NewsViewController.h"

@interface StockDetailTabBarViewController ()

@end

@implementation StockDetailTabBarViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize current view
    CurrentViewController *currentVC = self.viewControllers[0];
    currentVC.stockDetailViewController = self.stockDetailViewController;
    
    // Initialize historical view
    //HistoricalViewController *historicalVC = self.viewControllers[1];
    
    // Initialize news view
    //NewsViewController *newsVC = self.viewControllers[2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
