//
//  FeedbackViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-19.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReviewCell.h"

@import Firebase;

@interface FeedbackViewController : UITableViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *itemReviews;
@property (strong, nonatomic) NSString *itemKey;
@property (strong, nonatomic) NSString *userUID;

- (id)initWithItemKey:(NSString *)key;
- (id)initWithUserUID:(NSString *)uid;
@end
