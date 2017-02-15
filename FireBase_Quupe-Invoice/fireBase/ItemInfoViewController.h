//
//  ItemInfoViewController.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "AppDelegate.h"
#import "ConfirmViewController.h"
#import "LenderProfileViewController.h"
#import "FeedbackViewController.h"

#import "QpPriceView.h"
#import "QpTableView.h"
#import "QpLenderView.h"
#import "QpAsyncImage.h"

@import Firebase;

@interface ItemInfoViewController : UIViewController <QpTableViewDelegate, UIGestureRecognizerDelegate, QpLenderViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) QpAsyncImage *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UIButton *bookBtn;

@property (strong, nonatomic) QpPriceView *priceView;

@property (strong, nonatomic) NSString *lender;
@property (strong, nonatomic) NSString *lenderUID;
@property (strong, nonatomic) NSString *itemKey;

@property (strong, nonatomic) Item *currentItem;
@property (strong, nonatomic) FIRDatabaseReference *ref;

- (id)initWithItem:(Item *)item;
- (void)loadImageFromURL:(NSURL *)photoURL;

@end
