//
//  StockSearchViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 4/17/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "StockSearchViewController.h"
#import "StockDetailViewController.h"
#import "MLPAutoCompleteTextField.h"
#import "StockNameCompletion.h"
#import "FavoriteStockTableViewCell.h"
#import "StockSymbols.h"
#import "AutoRefresh.h"

@interface StockSearchViewController ()

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *getQuoteButton;
@property (weak, nonatomic) IBOutlet UISwitch *autoRefreshSwitch;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UITableView *favoriteStocksTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) enum TabSelection stockDetailTabSelection;
@property (nonatomic) NSString *stockSymbolForDetailString;
@property NSMutableArray *stockSymbolsMutableArray;
@property NSMutableDictionary *stockDetailsMutableDict;
@property NSTimer *autoRefreshTimer;
@property NSManagedObjectContext *managedObjectContext;

@end

@implementation StockSearchViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize data model
    self.managedObjectContext = ((AppDelegate *)([UIApplication sharedApplication].delegate)).managedObjectContext;
//    [self clearDataModel];
    [self initializeDataModel];
    [self initializeStockCache];
//    [self.stockSymbolsMutableArray addObject:@"AAPL"];
//    [self.stockSymbolsMutableArray addObject:@"GOOGL"];
//    [self saveStockSymbolsMutableArray];
    
    // Configure search text field
    [self initializeSearchTextField];
    
    // Initialize activity indicator
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = self.view.backgroundColor;
    [self.view bringSubviewToFront:self.activityIndicator];
    
    // Initialize table view
    self.favoriteStocksTableView.separatorInset = UIEdgeInsetsZero;
    [self fetchAndUpdateStockDetails];
    
    // Set auto-refresh switch
    self.autoRefreshTimer = nil;
    [self.autoRefreshSwitch setOn:[self isAutoRefresh] animated:NO];
    [self updateAutoRefreshState];
    
    // Set refresh button
    UIImage *refreshImage = [[UIImage imageNamed:@"Refresh.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.refreshButton setImage:refreshImage forState:UIControlStateNormal];
    self.refreshButton.imageView.tintColor = [UIColor whiteColor];
    
    // Set stock detail tab selection to current
    self.stockDetailTabSelection = TabSelectionCurrent;
}

- (void)viewWillAppear:(BOOL)animated {
    // Make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowStockDetailSegue"]) {
        StockDetailViewController *stockDetailViewController = (StockDetailViewController *)segue.destinationViewController;
        
        BOOL isFavoriteStock = ([self.stockSymbolsMutableArray indexOfObject:self.stockSymbolForDetailString] != NSNotFound);
        stockDetailViewController.isFavoriteStock = isFavoriteStock;
        stockDetailViewController.stockDetailTabSelection = self.stockDetailTabSelection;
        stockDetailViewController.stockSymbolString = self.stockSymbolForDetailString;
        stockDetailViewController.stockSearchViewController = self;
    }
}

- (void)unwindFromStockDetail:(id)sourceViewController {
    
    StockDetailViewController *source = (StockDetailViewController *)sourceViewController;
    NSAssert([self.stockSymbolForDetailString isEqualToString:source.stockSymbolString], @"Internal Error When Unwinding To Stock Search!");
    
    // Update stock symbol array and table view
    NSUInteger indexOfSymbol = [self.stockSymbolsMutableArray indexOfObject:self.stockSymbolForDetailString];
    if (indexOfSymbol == NSNotFound && source.isFavoriteStock) {
        // Add stock symbol to favorite stocks
        [self.stockSymbolsMutableArray addObject:self.stockSymbolForDetailString];
        [self saveStockSymbolsMutableArray];
    } else if (indexOfSymbol != NSNotFound && !source.isFavoriteStock) {
        // Remove stock symbol from favorite stocks
        [self.stockSymbolsMutableArray removeObjectAtIndex:indexOfSymbol];
        [self saveStockSymbolsMutableArray];
    }
    [self fetchAndUpdateStockDetails];
    
    // Save stock detail tab selection
    self.stockDetailTabSelection = source.stockDetailTabSelection;
}

#pragma mark - Gesture Recognizer

- (IBAction)didTapGetQuoteButton:(id)sender {
    [self validateSearchTextAndGoToDetailView];
}

- (IBAction)didChangeAutoRefreshSwitch:(id)sender {
    if (self.autoRefreshSwitch.on) {
        [self fetchAndUpdateStockDetails];
    }
    [self saveIsAutoRefresh:self.autoRefreshSwitch.on];
    [self updateAutoRefreshState];
}

- (IBAction)didTapRefreshButton:(id)sender {
    [self fetchAndUpdateStockDetails];
}

#pragma mark - Worker

- (void)initializeSearchTextField {
    StockNameCompletion *searchViewStockNameCompletion = [[StockNameCompletion alloc]init];
    self.searchTextField.autoCompleteDataSource = searchViewStockNameCompletion;
    self.searchTextField.autoCompleteDelegate = searchViewStockNameCompletion;
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.searchTextField.layer.borderWidth = 2.0f;
    self.searchTextField.showTextFieldDropShadowWhenAutoCompleteTableIsOpen = NO;
    self.searchTextField.applyBoldEffectToAutoCompleteSuggestions = NO;
    self.searchTextField.autoCompleteRowHeight = 55.0f;
    self.searchTextField.maximumNumberOfAutoCompleteRows = 4;
    self.searchTextField.autoCompleteTableBorderColor = [UIColor whiteColor];
    self.searchTextField.autoCompleteTableBorderWidth = 1.0f;
}

// Update refresh state and schedule the timer if necessary
// Earilest refresh will happen after 10s
- (void)updateAutoRefreshState {
    if (self.autoRefreshSwitch.on) {
        if (self.autoRefreshTimer == nil) {
            self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(fetchAndUpdateStockDetailsWithTimer:) userInfo:nil repeats:YES];
        }
    } else {
        if (self.autoRefreshTimer != nil) {
            [self.autoRefreshTimer invalidate];
            self.autoRefreshTimer = nil;
        }
    }
}

- (NSMutableDictionary *)dictionaryWithJSONData:(NSData *)JSONData {
    
    NSDictionary *stockDetailDict = [NSJSONSerialization JSONObjectWithData:JSONData options:(NSJSONReadingOptions)0 error:nil];
    NSMutableDictionary *stockDetailMutableDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"Price", @"", @"Change", @"", @"CompanyName", @"", @"MarketCap", nil];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
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
    
    // Set company name
    stockDetailMutableDict[@"CompanyName"] = stockDetailDict[@"Name"];
    
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
    numberFormatter.positiveFormat = @"Market Cap: #####0.00";
    NSString *marketCapString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:marketCapValue]];
    stockDetailMutableDict[@"MarketCap"] = [marketCapString stringByAppendingString:marketCapSuffix];
    
    return stockDetailMutableDict;
}

- (void)fetchAndUpdateStockDetails {
    
    NSInteger symbolCount = self.stockSymbolsMutableArray.count;
    
    if (symbolCount > 0) {
        // Use serial queue to atomically count the newtwork traffic threads
        dispatch_queue_t networkTrafficCountingQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
        NSInteger *onGoingNetworkTrafficCount = calloc(1, sizeof(NSInteger));
        *onGoingNetworkTrafficCount = symbolCount;
        [self.activityIndicator startAnimating];
        
        // Query stock information for each symbol
        for (NSString *symbolString in self.stockSymbolsMutableArray) {
            
            NSString *URLString = [@"http://stockSearch-1266.appspot.com/?symbol=" stringByAppendingString:symbolString];
            NSURL *URL = [NSURL URLWithString:URLString];
            
            NSURLSessionDataTask *stockSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
                // If row has not been deleted, update the stock details mutable dictionary and reload table data
                if (error == nil && [self.stockSymbolsMutableArray indexOfObject:symbolString] != NSNotFound) {
                    self.stockDetailsMutableDict[symbolString] = [self dictionaryWithJSONData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.favoriteStocksTableView reloadData];
                    });
                    
                } else {
                    //Network error when retriving stock information.
                    NSLog(@"Network Error When Retriving Stock Information.");
                }
                dispatch_async(networkTrafficCountingQueue, ^{
                    *onGoingNetworkTrafficCount = *onGoingNetworkTrafficCount - 1;
                    NSAssert(*onGoingNetworkTrafficCount >= 0, @"Internal Error When Counting Network Traffic! Count: %ld", *onGoingNetworkTrafficCount);
                    if (*onGoingNetworkTrafficCount == 0) {
                        free(onGoingNetworkTrafficCount);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.activityIndicator.isAnimating) {
                                [self.activityIndicator stopAnimating];
                            }
                        });
                    }
                });
            }];
            
            [stockSearchTask resume];
        }
    } else {
        [self.favoriteStocksTableView reloadData];
    }
}

- (void)fetchAndUpdateStockDetailsWithTimer:(NSTimer *)timer {
    [self fetchAndUpdateStockDetails];
}

- (void)showAlertWithTitle:(NSString *) title {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)validateSearchTextAndGoToDetailView {
    
    // Show alert when no input symbol
    if (self.searchTextField.text.length == 0) {
        [self showAlertWithTitle:@"Please Enter a Stock Name or Symbol."];
        return;
    }
    
    //Get the string before the first hyphen in the text field.
    NSRange hyphenRange = [self.searchTextField.text rangeOfString:@"-"];
    NSUInteger symbolLength = hyphenRange.location;
    if (symbolLength == NSNotFound) {
        symbolLength = self.searchTextField.text.length;
    }
    NSString *symbolString = [self.searchTextField.text substringToIndex:symbolLength].uppercaseString;
    
    // Check symbolString only contain letters
    NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet];
    if ([symbolString stringByTrimmingCharactersInSet:letterSet].length > 0) {
        [self showAlertWithTitle:@"Invalid Symbol"];
        return;
    }
    
    NSString *URLString = [@"http://stockSearch-1266.appspot.com/?company_name=" stringByAppendingString:symbolString];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLSessionDataTask *stockSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
        if (error == nil) {
            // Compare returned symbols with the text in search text field
            NSArray *searchResultArray = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
            for (NSDictionary *stockItem in searchResultArray) {
                if ([symbolString isEqualToString:((NSString *)stockItem[@"Symbol"]).uppercaseString]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.stockSymbolForDetailString = symbolString;
                        [self performSegueWithIdentifier:@"ShowStockDetailSegue" sender:self];
                    });
                    return;
                }
            }
            
            // Show an alert when no returned symbols matches the one in search text field
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"Invalid Symbol"];
            });
        } else {
            // Network error when validating symbol
            NSLog(@"Network Error When Validating Symbol.");
        }
    }];
    
    [stockSearchTask resume];
    
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    [self validateSearchTextAndGoToDetailView];
    return YES;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FavoriteStockTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.stockSymbolForDetailString = cell.symbolLabel.text;
    [self performSegueWithIdentifier:@"ShowStockDetailSegue" sender:self];
}

// Set the background color for price change label when highlighted
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteStockTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.stockPriceChangeLabel.text.length > 0) {
        unichar changeSign = [cell.stockPriceChangeLabel.text characterAtIndex:0];
        if (changeSign == '+') {
            cell.stockPriceChangeLabel.backgroundColor = [UIColor greenColor];
        } else if (changeSign == '-') {
            cell.stockPriceChangeLabel.backgroundColor = [UIColor redColor];
        }
    }
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section
    return self.stockSymbolsMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    // Load cell prototype
    static NSString *CellIdentifier = @"FavoriteStockCell";
    FavoriteStockTableViewCell *cell = (FavoriteStockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSAssert(cell != nil, @"Internal Error When Dequeuing Cell.");
    
    // Use stock detail information in dictionary to update label text
    NSInteger stockIndex = indexPath.row;
    if (stockIndex >= self.stockSymbolsMutableArray.count) {
        // Row already deleted
        cell.symbolLabel.text = @"";
        cell.stockPriceLabel.text = @"";
        cell.stockPriceChangeLabel.text = @"";
        cell.companyNameLabel.text = @"";
        cell.marketCapLabel.text = @"";
    } else {
        NSString *symbolString = self.stockSymbolsMutableArray[stockIndex];
        cell.symbolLabel.text = symbolString;
        cell.stockPriceLabel.text = self.stockDetailsMutableDict[symbolString][@"Price"];
        cell.stockPriceChangeLabel.text = self.stockDetailsMutableDict[symbolString][@"Change"];
        cell.companyNameLabel.text = self.stockDetailsMutableDict[symbolString][@"CompanyName"];
        cell.marketCapLabel.text = self.stockDetailsMutableDict[symbolString][@"MarketCap"];
    }
    
    // Set background color for price change label
    cell.stockPriceChangeLabel.backgroundColor = [UIColor whiteColor];
    if (cell.stockPriceChangeLabel.text.length > 0) {
        unichar changeSign = [cell.stockPriceChangeLabel.text characterAtIndex:0];
        if (changeSign == '+') {
            cell.stockPriceChangeLabel.backgroundColor = [UIColor greenColor];
        } else if (changeSign == '-') {
            cell.stockPriceChangeLabel.backgroundColor = [UIColor redColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FavoriteStockTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *symbolString = cell.symbolLabel.text;
        
        // Delete symbol from mutable array and dictionary, then save to data model
        [self.stockSymbolsMutableArray removeObject:symbolString];
        [self.stockDetailsMutableDict removeObjectForKey:symbolString];
        [self saveStockSymbolsMutableArray];
        [tableView reloadData];
    }
}


#pragma mark - Data Model

- (void)initializeDataModel {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"StockSymbols" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (result.count == 0) {
        // Initialize StockSymbols to empty mutable array and save
        StockSymbols *stockSymbols = [NSEntityDescription insertNewObjectForEntityForName:@"StockSymbols" inManagedObjectContext:self.managedObjectContext];
        stockSymbols.symbolArrayData = [NSPropertyListSerialization dataWithPropertyList:[NSMutableArray array] format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    }
    
    request.entity = [NSEntityDescription entityForName:@"AutoRefresh" inManagedObjectContext:self.managedObjectContext];
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (result.count == 0) {
        // Initialize AutoRefresh to NO and save
        AutoRefresh *autoRefresh = [NSEntityDescription insertNewObjectForEntityForName:@"AutoRefresh" inManagedObjectContext:self.managedObjectContext];
        autoRefresh.isAutoRefresh = [NSNumber numberWithBool:NO];
    }
    
    //save state
    [self saveChangesToObjectsInMyMOC];
}

- (void)initializeStockCache {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"StockSymbols" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    StockSymbols *stockSymbols = result[0];
    self.stockSymbolsMutableArray = [NSPropertyListSerialization propertyListWithData:stockSymbols.symbolArrayData options:NSPropertyListMutableContainers format:nil error:nil];
    self.stockDetailsMutableDict = [NSMutableDictionary dictionaryWithCapacity:self.stockSymbolsMutableArray.count];
    
    //Add empty strings to each dictionary entry
    for (NSString *symbolString in self.stockSymbolsMutableArray) {
        NSMutableDictionary *emptyStockMutableDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"Price", @"", @"Change", @"", @"CompanyName", @"", @"MarketCap", nil];
        self.stockDetailsMutableDict[symbolString] = emptyStockMutableDict;
    }
    
}

- (void)saveStockSymbolsMutableArray {
    
    // Use cached array to update data model
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"StockSymbols" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    StockSymbols *stockSymbols = result[0];
    stockSymbols.symbolArrayData = [NSPropertyListSerialization dataWithPropertyList:self.stockSymbolsMutableArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    
    // Save change to data model
    [self saveChangesToObjectsInMyMOC];
}

- (BOOL)isAutoRefresh {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"AutoRefresh" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    AutoRefresh *autoRefresh = result[0];
    return autoRefresh.isAutoRefresh.boolValue;
}

- (void)saveIsAutoRefresh:(BOOL)isAutoRefresh {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"AutoRefresh" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    AutoRefresh *autoRefresh = result[0];
    autoRefresh.isAutoRefresh = [NSNumber numberWithBool:isAutoRefresh];
    
    //save state
    [self saveChangesToObjectsInMyMOC];
}

// Only for development; Clear all stored data
- (void)clearDataModel {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"StockSymbols" inManagedObjectContext:self.managedObjectContext];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (result.count == 1) {
        [self.managedObjectContext deleteObject:result[0]];
    }
    
    request.entity = [NSEntityDescription entityForName:@"AutoRefresh" inManagedObjectContext:self.managedObjectContext];
    result = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (result.count == 1) {
        [self.managedObjectContext deleteObject:result[0]];
    }
    
    //save state
    [self saveChangesToObjectsInMyMOC];
}

- (void)saveChangesToObjectsInMyMOC {
    NSError *error = nil;
    if (self.managedObjectContext.hasChanges && ![self.managedObjectContext save:&error]) {
        NSAssert(false, @"Data Model Error When Saving Data! %@, %@", error, error.userInfo);
    }
}

@end
