//
//  ProfileView.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-19.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SwitchViewInUserViewControllerDelegate.h"
#import "TextTableCell.h"
#import "QpRatingView.h"
#import "EditProfileViewController.h"
#import "InventoryTableCell.h"
#import "TransactionTableCell.h"
#import "QpTransTableView.h"
#import "QpTapButton.h"
#import "User.h"
#import "QpAsyncImage.h"

#import "AppDelegate.h"
@import Firebase;

@protocol EditProfileDelegate;
@protocol QpTransTableDelegate;
@class QpTransTableView;

@interface ProfileView : UIScrollView <EditProfileDelegate, UITableViewDelegate, UITableViewDataSource, QpTransTableDelegate, QpTabButtonDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) QpAsyncImage *imgView;
@property (strong, nonatomic) UIButton *logoutBtn;
@property (strong, nonatomic) UILabel *bioLabel;
@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) NSString *currentTableTitle;

@property (strong, nonatomic) QpTransTableView *borrowTransTable;
@property (strong, nonatomic) QpTransTableView *lendTransTable;

@property (weak, nonatomic) id <SwitchViewInUserViewControllerDelegate> delegate;

- (void) loadInfoFromUser:(User *)currentUser;

@end
