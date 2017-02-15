//
//  ReviewViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "QpRatingView.h"
#import "QpTableView.h"

@import Firebase;

@interface ReviewViewController : UIViewController <QpTableViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *targetUID;
@property (strong, nonatomic) NSString *itemKey;

-(id)initWithTargetUID:(NSString *)targetUserUID ForItem:(NSString *)itemKey;

@end
