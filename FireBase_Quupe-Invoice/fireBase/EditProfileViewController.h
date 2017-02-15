//
//  EditProfileViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QpTableView.h"

#import "AppDelegate.h"
@import Firebase;

@protocol EditProfileDelegate <NSObject>

@required
- (void)updateProfileView;

@end

@interface EditProfileViewController : UIViewController <QpTableViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) id<EditProfileDelegate> delegate;

@end
