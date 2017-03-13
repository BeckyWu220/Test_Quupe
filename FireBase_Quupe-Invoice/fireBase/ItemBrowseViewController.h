//
//  ItemBrowseViewController.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-11.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@import Firebase;
@import Batch;

@interface ItemBrowseViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *itemArray;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) UIImage *defaultImg;


@end
