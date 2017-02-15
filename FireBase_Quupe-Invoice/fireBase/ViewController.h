//
//  ViewController.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-01.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemTableCell.h"
@import Firebase;

@interface ViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;




@property (strong, nonatomic) NSURL *localFile;

@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) FIRStorageReference *imagesRef;

@property (strong, nonatomic) NSArray *tableData;

@end

