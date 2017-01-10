//
//  UserViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-23.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewInUserViewControllerDelegate.h"

#import "ProfileView.h"
#import "AppDelegate.h"
#import "SignUpView.h"
#import "SignInView.h"

#import "EditProfileViewController.h"
#import "ReviewViewController.h"
#import "PaymentViewController.h"
#import "ItemInfoViewController.h"

@import Firebase;

@interface UserViewController : UIViewController <SwitchViewInUserViewControllerDelegate, PaymentViewControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) UIView *currentView;

- (void)SwitchToProfileViewWithUID: (NSString *)uid;

@end
