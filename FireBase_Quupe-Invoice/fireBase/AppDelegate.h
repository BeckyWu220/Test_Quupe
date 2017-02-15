//
//  AppDelegate.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-01.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "ItemBrowseViewController.h"
#import "UserViewController.h"
#import "PostItemViewController.h"
#import "NotificationViewController.h"
#import "TransactionViewController.h"

#import "ItemInfoViewController.h"

#import "User.h"

#import <Stripe/Stripe.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
{
    User *currentUser;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *currentUser;

- (void)customizeBatchToken;
- (void)resetBatchToken;
- (void)saveToUserDefaults:(NSDictionary *)userDic;

@end

