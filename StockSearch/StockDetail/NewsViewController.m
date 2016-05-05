//
//  NewsViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsFeedTableViewCell.h"

@interface NewsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *newsFeedsTableView;

@property NSArray *newsFeedsArray;

@end

@implementation NewsViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsFeedsArray = [NSArray array];
    [self fetchAndUpdateNewsFeeds];
}

#pragma mark - Worker

- (NSArray *)newsArrayWithJSONData:(NSData *)JSONData {
    
    NSDictionary *allNewsFeedsDict = [NSJSONSerialization JSONObjectWithData:JSONData options:(NSJSONReadingOptions)0 error:nil];
    NSMutableArray *newsFeedsMutableArray = [NSMutableArray array];
    
    for (NSDictionary *newsFeedDict in allNewsFeedsDict[@"d"][@"results"]) {
        
        // Get all fields needed
        NSString *URL = newsFeedDict[@"Url"];
        NSString *title = newsFeedDict[@"Title"];
        NSString *description = newsFeedDict[@"Description"];
        NSString *publisher = newsFeedDict[@"Source"];
        
        // Format time
        NSString *time = newsFeedDict[@"Date"];
        NSUInteger dateLength = time.length;
        if (dateLength > 4) {
            time = [time substringToIndex:dateLength-4];
        }
        time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        
        // Add to news feeds array
        [newsFeedsMutableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:URL, @"URL", title, @"Title", description, @"Description", publisher, @"Publisher", time, @"Time", nil]];
    }
    
    return [newsFeedsMutableArray copy];
}

- (void)fetchAndUpdateNewsFeeds {
    
    NSString *URLString = [@"http://stockSearch-1266.appspot.com/?newsfeeds=" stringByAppendingString:self.stockSymbolString];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLSessionDataTask *stockSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
        // Update news feeds table and reload table data
        if (error == nil) {
            self.newsFeedsArray = [self newsArrayWithJSONData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.newsFeedsTableView reloadData];
            });
            
        } else {
            //Network error when retriving news feeds.
            NSLog(@"Network Error When Retriving News Feeds.");
        }
    }];
    
    [stockSearchTask resume];
    
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // Go to link
    NSDictionary *newsDict = self.newsFeedsArray[indexPath.row];
    NSURL *newsFeedURL = [NSURL URLWithString:newsDict[@"URL"]];
    [[UIApplication sharedApplication] openURL:newsFeedURL];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section
    return self.newsFeedsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    // Load cell prototype
    NSString *CellIdentifier = @"NewsFeedCell";
    NewsFeedTableViewCell *cell = (NewsFeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSAssert(cell != nil, @"Internal Error When Dequeuing Cell.");
    
    // Use news feeds in array to update label text
    NSAssert(self.newsFeedsArray.count > indexPath.row, @"Internal Error When Updating News Feed Cell.");
    NSDictionary *newsDict = self.newsFeedsArray[indexPath.row];
    cell.titleLabel.text = newsDict[@"Title"];
    cell.descriptionLabel.text = newsDict[@"Description"];
    cell.publisherLabel.text = newsDict[@"Publisher"];
    cell.timeLabel.text = newsDict[@"Time"];
    
    return cell;
}

@end
