//
//  CurrentViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import "CurrentViewController.h"
#import "CurrentTableViewController.h"
#import "AFNetworking.h"

@interface CurrentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *yahooImageView;

@property (weak, nonatomic) CurrentTableViewController *currentTableViewController;

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
    [self fetchAndUpdateYahooImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedCurrentTableSegue"]) {
        self.currentTableViewController = segue.destinationViewController;
    }
}

# pragma mark - Gesture Recognizer

- (IBAction)didTapFacebookShareButton:(id)sender {
    
    FBSDKShareLinkContent *facebookShareContent = [[FBSDKShareLinkContent alloc] init];
    
    NSDictionary *stockDetailDict = self.currentTableViewController.stockDetailDictionary;
    NSString *priceString = [stockDetailDict[@"Price"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *companyNameString = stockDetailDict[@"CompanyName"];
    NSString *symbolString = stockDetailDict[@"Symbol"];
    facebookShareContent.contentTitle = [NSString stringWithFormat:@"Current Stock Price of %@ is %@", companyNameString, priceString];
    facebookShareContent.contentDescription = [NSString stringWithFormat:@"Stock Information of %@ (%@)", companyNameString, symbolString];
    facebookShareContent.imageURL = [NSURL URLWithString:[@"http://chart.finance.yahoo.com/t?lang=en-US&width=220&height=200&s=" stringByAppendingString:symbolString]];
    facebookShareContent.contentURL = [NSURL URLWithString:[@"http://finance.yahoo.com/q?s=" stringByAppendingString:symbolString]];
    
    //[FBSDKShareDialog showFromViewController:self withContent:facebookShareContent delegate:nil];
    [FBSDKShareDialog showFromViewController:self.stockDetailViewController withContent:facebookShareContent delegate:nil];
}

- (IBAction)didTapFavoriteButton:(id)sender {
    self.stockDetailViewController.isFavoriteStock = !self.stockDetailViewController.isFavoriteStock;
    [self updateFavoriteButton];
}

# pragma mark - Worker

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

- (void)showAlertWithTitle:(NSString *) title {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSDictionary *)stockDictionaryWithJSONData:(NSData *)JSONData {
    
    NSDictionary *stockDetailDict = [NSJSONSerialization JSONObjectWithData:JSONData options:(NSJSONReadingOptions)0 error:nil];
    NSMutableDictionary *stockDetailMutableDict = [NSMutableDictionary dictionary];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    // Return nil if status is not success
    if (![stockDetailDict[@"Status"] isEqualToString:@"SUCCESS"]) {
        return nil;
    }
    
    // Set company name
    stockDetailMutableDict[@"CompanyName"] = stockDetailDict[@"Name"];
    
    // Set Symbol
    stockDetailMutableDict[@"Symbol"] = stockDetailDict[@"Symbol"];
    
    // Set price
    numberFormatter.positiveFormat = @"$ ###0.00";
    stockDetailMutableDict[@"Price"] = [numberFormatter stringFromNumber:stockDetailDict[@"LastPrice"]];
    
    // Set price change
    numberFormatter.negativeFormat = @"-##0.00";
    numberFormatter.positiveFormat = @"+##0.00";
    NSString *priceChangeString = [numberFormatter stringFromNumber:stockDetailDict[@"Change"]];
    
    // Set price change percent
    numberFormatter.negativeFormat = @"(-##0.00'%')";
    numberFormatter.positiveFormat = @"(##0.00'%')";
    stockDetailMutableDict[@"Change"] = [priceChangeString stringByAppendingString:[numberFormatter stringFromNumber:stockDetailDict[@"ChangePercent"]]];
    
    // Set time and date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"E MMM d HH:mm:ss 'UTC'ZZZZZ yyyy";
    NSDate *date = [dateFormatter dateFromString:stockDetailDict[@"Timestamp"]];
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = @"MMM d yyyy HH:mm";
    stockDetailMutableDict[@"Time"] = [dateFormatter stringFromDate:date];
    
    // Set market cap
    NSInteger marketCapValue = [stockDetailDict[@"MarketCap"] integerValue];
    NSString *marketCapSuffix = @"";
    if (marketCapValue >= 1000000000) {
        marketCapValue /= 1000000000;
        marketCapSuffix = @" Billion";
    } else if (marketCapValue >= 1000000) {
        marketCapValue /= 1000000;
        marketCapSuffix = @" Million";
    }
    numberFormatter.positiveFormat = @"#####0.00";
    NSString *marketCapString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:marketCapValue]];
    stockDetailMutableDict[@"MarketCap"] = [marketCapString stringByAppendingString:marketCapSuffix];
    
    // Set volume
    numberFormatter.positiveFormat = @"########0";
    stockDetailMutableDict[@"Volume"] = [numberFormatter stringFromNumber:stockDetailDict[@"Volume"]];
    
    // Set price change YTD
    numberFormatter.positiveFormat = @"+###0.00";
    numberFormatter.negativeFormat = @"-###0.00";
    NSString *changeYTDString = [numberFormatter stringFromNumber:stockDetailDict[@"ChangeYTD"]];
    
    // Set price change percent YTD
    numberFormatter.positiveFormat = @"(##0.00'%')";
    numberFormatter.negativeFormat = @"(-##0.00'%')";
    stockDetailMutableDict[@"ChangeYTD"] = [changeYTDString stringByAppendingString:[numberFormatter stringFromNumber:stockDetailDict[@"ChangePercentYTD"]]];
    
    // Set high, low, and open price
    numberFormatter.positiveFormat = @"$ ###0.00";
    stockDetailMutableDict[@"High"] = [numberFormatter stringFromNumber:stockDetailDict[@"High"]];
    stockDetailMutableDict[@"Low"] = [numberFormatter stringFromNumber:stockDetailDict[@"Low"]];
    stockDetailMutableDict[@"Open"] = [numberFormatter stringFromNumber:stockDetailDict[@"Open"]];
    
    return [stockDetailMutableDict copy];
}

- (void)refreshStockDetailTable {
    
    NSString *URLString = [@"http://stockSearch-1266.appspot.com/?symbol=" stringByAppendingString:self.stockDetailViewController.stockSymbolString];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLSessionDataTask *stockSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
        // Update table view data if details are fetched successfully
        if (error == nil) {
            NSDictionary *stockDetailDictionary = [self stockDictionaryWithJSONData:data];
            if (stockDetailDictionary != nil) {
                self.currentTableViewController.stockDetailDictionary = stockDetailDictionary;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.currentTableViewController updateStockDetail];
                });
            } else {
                // Show an alert when no stock detail available
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithTitle:@"No stock detail available."];
                });
            }
        } else {
            //Network error when retriving stock information.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"Network Error When Retriving Stock Information."];
            });
        }
    }];
    
    [stockSearchTask resume];
    
}

- (void)updateYahooImageWithURL:(NSURL *)imageURL {
    self.yahooImageView.image = [UIImage imageWithContentsOfFile:imageURL.path];
}

- (void)fetchAndUpdateYahooImage {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[@"http://chart.finance.yahoo.com/t?lang=en-US&width=400&height=300&s=" stringByAppendingString:self.stockDetailViewController.stockSymbolString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"YahooChart.png"];
        // Delete old file if exist
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        // Update yahoo image if it is fetched successfully
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateYahooImageWithURL:filePath];
            });
        }
    }];
    
    [downloadTask resume];
}

@end
