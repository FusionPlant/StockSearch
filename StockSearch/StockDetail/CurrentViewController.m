//
//  CurrentViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "CurrentViewController.h"
#import "StockDetailTabBarViewController.h"

@interface CurrentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *currentTableView;
@property (weak, nonatomic) IBOutlet UIImageView *yahooImageView;

@end

@implementation CurrentViewController

# pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize facebook button
    UIImage *facebookImage = [[UIImage imageNamed:@"Facebook.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.facebookShareButton setImage:facebookImage forState:UIControlStateNormal];
    self.facebookShareButton.imageView.tintColor = [UIColor greenColor];
    
    // Initialize favorite button
    self.favoriteButton.imageView.tintColor = [UIColor greenColor];
    [self updateFavoriteButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshStockDetailTable];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

# pragma mark - Gesture Recognizer

- (IBAction)didTapFacebookShareButton:(id)sender {
}

- (IBAction)didTapFavoriteButton:(id)sender {
    self.stockDetailViewController.isFavoriteStock = !self.stockDetailViewController.isFavoriteStock;
    [self updateFavoriteButton];
}

# pragma mark - Worker

- (void)refreshStockDetailTable {
}

- (void)updateFavoriteButton {
    UIImage *favoriteImage;
    if (self.stockDetailViewController.isFavoriteStock) {
        favoriteImage = [UIImage imageNamed:@"StarFilled.png"];
    } else {
        favoriteImage = [UIImage imageNamed:@"StarHollow.png"];
    }
    favoriteImage = [favoriteImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
}

@end
