//
//  NotificationViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-05.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageTableCell.h"
#import "AppDelegate.h"
#import "Item.h"
#import "MessageViewController.h"

@import Firebase;

@interface NotificationViewController : UITableViewController 

@property (strong, nonatomic) FIRDatabaseReference *ref;

- (void)loadChatTargets;

@end
