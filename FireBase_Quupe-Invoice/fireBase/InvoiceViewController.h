//
//  InvoiceViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2017-02-09.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "QpButton.h"
#import "PaymentViewController.h"
#import "ReviewViewController.h"

@import Firebase;
@import Batch;
#import "quupe-Swift.h"

@interface InvoiceViewController : ViewController <QpButtonDelegate, PaymentViewControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *itemKey;

- (id)initWithItemKey:(NSString *)key;

@end
