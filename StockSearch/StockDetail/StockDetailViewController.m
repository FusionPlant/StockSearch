//
//  StockDetailViewController.m
//  StockSearch
//
//  Created by Tailai Ye on 4/24/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "StockDetailViewController.h"
#import "StockDetailTabBarViewController.h"


@interface StockDetailViewController ()

@end

@implementation StockDetailViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedTabBarSegue"]) {
        StockDetailTabBarViewController *vc = segue.destinationViewController;
        vc.tabBar.hidden = YES;
    }
}


#pragma mark - Networking

- (void) networking {
    
    NSURLSession *stockSearchSession = [NSURLSession sharedSession];
    NSURL *URL = [NSURL URLWithString:@"http://stockSearch-1266.appspot.com/?company_name=aapl"];
    NSURLSessionDataTask *stockSearchTask = [stockSearchSession dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError* error){
        if (error == nil) {
            NSArray *mydic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
            NSLog(@"dictionary: %@, %d", mydic, [mydic isKindOfClass:[NSArray class]]);
        }
    }];
    [stockSearchTask resume];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
