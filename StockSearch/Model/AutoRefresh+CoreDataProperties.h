//
//  AutoRefresh+CoreDataProperties.h
//  StockSearch
//
//  Created by Tailai Ye on 5/1/16.
//  Copyright © 2016 TailaiYe. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AutoRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface AutoRefresh (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isAutoRefresh;

@end

NS_ASSUME_NONNULL_END
