//
//  StockDetailViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 4/24/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "StockDetailViewController.h"
#import "StockDetailTabBarViewController.h"


@interface StockDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UIButton *historicalButton;
@property (weak, nonatomic) IBOutlet UIButton *newsButton;

@property (weak, nonatomic) StockDetailTabBarViewController *stockDetailTabBarViewController;

@end

@implementation StockDetailViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialized navigation bar
    self.navigationItem.title = self.stockSymbolString;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;
    
    // Initialized buttons
    self.currentButton.layer.cornerRadius = 5.0f;
    self.historicalButton.layer.cornerRadius = 5.0f;
    self.newsButton.layer.cornerRadius = 5.0f;
    
    // Switch to right tab in tab bar view controller
    [self switchToTab];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedTabBarSegue"]) {
        self.stockDetailTabBarViewController = segue.destinationViewController;
        self.stockDetailTabBarViewController.tabBar.hidden = YES;
        self.stockDetailTabBarViewController.stockDetailViewController = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.stockSearchViewController unwindFromStockDetail:self];
}

#pragma mark - Gesture Recognizer

- (IBAction)didTapCurrentButton:(id)sender {
    self.stockDetailTabSelection = TabSelectionCurrent;
    [self switchToTab];
}

- (IBAction)didTapHistoricalButton:(id)sender {
    self.stockDetailTabSelection = TabSelectionHistorical;
    [self switchToTab];
}

- (IBAction)didTapNewsButton:(id)sender {
    self.stockDetailTabSelection = TabSelectionNews;
    [self switchToTab];
}

#pragma mark - Worker

- (void)switchToTab {
    
    // Restore all buttons to unselected state
    self.currentButton.backgroundColor = [UIColor clearColor];
    [self.currentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.historicalButton.backgroundColor = [UIColor clearColor];
    [self.historicalButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.newsButton.backgroundColor = [UIColor clearColor];
    [self.newsButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    // Switch to the tab and change cooresponding button style
    switch (self.stockDetailTabSelection) {
        case TabSelectionCurrent:
            self.currentButton.backgroundColor = [UIColor blueColor];
            [self.currentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.stockDetailTabBarViewController.selectedIndex = 0;
            break;
            
        case TabSelectionHistorical:
            self.historicalButton.backgroundColor = [UIColor blueColor];
            [self.historicalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.stockDetailTabBarViewController.selectedIndex = 1;
            break;
            
        case TabSelectionNews:
            self.newsButton.backgroundColor = [UIColor blueColor];
            [self.newsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.stockDetailTabBarViewController.selectedIndex = 2;
            break;
            
        default:
            NSAssert(false, @"Internal Error When Switching Tabs.");
            break;
    }
    
}

@end
