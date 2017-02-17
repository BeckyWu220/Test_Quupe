//
//  QpTransTableView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-02.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "TransactionTableCell.h"

@import Firebase;
@import Batch;
#import "quupe-Swift.h"

@protocol QpTransTableDelegate <NSObject>

- (void)SwitchToCheckoutViewWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo;
- (void)SwitchToReviewViewForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID;
- (void)SwitchToInvoiceViewForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID;
@end

@interface QpTransTableView : UITableView <UITableViewDelegate, UITableViewDataSource, TransactionCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSMutableArray *tableData;

@property (weak, nonatomic) id <QpTransTableDelegate> controllerDelegate;

@property BOOL simplified;

- (void)paymentSucceededForItem:(NSDictionary *)itemInfo Token:(NSString *)token;
- (void)sortCells;

@end
