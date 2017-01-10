//
//  TransactionViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-14.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CAAnimation.h>

#import "TransactionTableCell.h"
#import "AppDelegate.h"
#import "PaymentViewController.h"
#import "ReviewViewController.h"

#import "QpTransTableView.h"

#import <Stripe/Stripe.h>

@import Firebase;
@import Batch;
#import "quupe-Swift.h"

@protocol QpTransTableDelegate;

@interface TransactionViewController : UIViewController <PaymentViewControllerDelegate, QpTransTableDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSString *targetUID;


@end
