//
//  MessageViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-10.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import "AppDelegate.h"
#import "TransactionViewController.h"

@import Firebase;
@import Batch;
#import "quupe-Swift.h"

@interface MessageViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *targetUID;
@property (strong, nonatomic) UIImage *targetIcon;

- (void)loadMessageFromUserWithUID:(NSString *)uid;

@end
