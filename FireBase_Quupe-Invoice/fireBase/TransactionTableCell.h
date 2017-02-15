//
//  TransactionTableCell.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-05.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
//#import "AppDelegate.h"

@import Firebase;

#import "QpButton.h"
#import "QpAsyncImage.h"

@class TransactionTableCell;

@protocol TransactionCellDelegate <NSObject>

@required

- (void)SetItemStatusTo:(NSString *)itemStatus ItemKey:(NSString *)key TargetUID:(NSString *)targetUID;

@optional

- (void)SwitchToCheckoutViewWithCell:(TransactionTableCell *)cell;
- (void)SwitchToReviewViewForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID;

@end

@interface TransactionTableCell : UITableViewCell <QpButtonDelegate>

@property (strong, nonatomic) IBOutlet QpAsyncImage *imgView;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UILabel *itemRentRange;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSString *itemKey;
@property (strong, nonatomic) NSString *targetUID;
@property (strong, nonatomic) NSString *itemDirection;
@property (weak, nonatomic) id <TransactionCellDelegate> delegate;

- (void)loadButtonsWithItemStatus:(NSString *)itemStatus;

- (void)createThumbnailIconWithURL:(NSURL *)imgURL;

@end
