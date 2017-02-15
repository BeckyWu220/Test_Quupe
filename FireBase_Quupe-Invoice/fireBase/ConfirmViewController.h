//
//  ConfirmViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-23.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QpTableView.h"
#import "AppDelegate.h"
#import "QpBreakdownView.h"
#import "QpRentInfoView.h"

@import Firebase;

@interface ConfirmViewController : UIViewController <QpTableViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) FIRDatabaseReference *ref;

- (id)initWithItem:(Item *)item RentDay:(int)rentDay TotalPrice:(float) rentalPrice RentRange:(NSString *)rentRange;

@end
