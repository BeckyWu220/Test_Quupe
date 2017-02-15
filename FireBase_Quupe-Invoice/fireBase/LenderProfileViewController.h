//
//  LenderProfileViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "User.h"
#import "Item.h"
#import "InventoryTableCell.h"
#import "ItemInfoViewController.h"
#import "QpAsyncImage.h"
#import "FeedbackViewController.h"

@import Firebase;

@interface LenderProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *ref;

- (id)initWithLenderUID:(NSString *)lenderUID;

@end
