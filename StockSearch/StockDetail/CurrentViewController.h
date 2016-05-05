//
//  CurrentViewController.h
//  StockSearch
//
//  Created by Tailai Ye on 5/2/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKSharing.h>
#import "StockDetailViewController.h"

@interface CurrentViewController : UIViewController <FBSDKSharingDelegate>

@property (weak, nonatomic) StockDetailViewController *stockDetailViewController;

@end
