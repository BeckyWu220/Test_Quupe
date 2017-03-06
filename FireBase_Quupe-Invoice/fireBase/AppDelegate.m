//
//  AppDelegate.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-01.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "AppDelegate.h"

@import UIKit;
@import Firebase;
@import Batch;

@interface AppDelegate ()
{
    UITabBarController *tabBarController;
    
    UINavigationController *itemNavController;
    UINavigationController *msgNavController;
    UINavigationController *userNavController;
    UINavigationController *postNavController;
    
    ItemBrowseViewController *itemBrowser;
    UserViewController *userController;
    PostItemViewController *postItemController;
    NotificationViewController *notificationController;
    TransactionViewController *transactionController;
}

@end

@implementation AppDelegate

@synthesize currentUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"APPLICATION LAUNCH");
    
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@"pk_test_H1qAwtQOB1lBwdAm2FVD7ei2"];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"CurrentUser"])
    {
        currentUser = [[User alloc] initWithDictionary:[standardUserDefaults objectForKey:@"CurrentUser"]];
    }else{
        currentUser = [[User alloc] initWithAnonymousUser];
    }
    NSLog(@"CURRENTUSER: %@", currentUser.uid);
    
    //[Batch startWithAPIKey:@"DEV57E3E842BCD84019798EB679681"];//dev api key
    // TODO : switch to live api key before store release
    [Batch startWithAPIKey:@"57E3E842BC993832AEFFDFDE25ED4D"]; // live
    
    [BatchPush registerForRemoteNotifications];
    
    [FIRApp configure];
    
    NSLog(@"BATCH INSTALLATION ID: %@", [BatchUser installationID]);
    
    //tabBarController
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    tabBarController = [[UITabBarController alloc] init];
    [tabBarController.tabBar setTintColor:[UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f]];
    NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    itemBrowser = [[ItemBrowseViewController alloc] initWithStyle:UITableViewStylePlain];
    itemNavController = [[UINavigationController alloc] initWithRootViewController:itemBrowser];
    //itemNavController.tabBarItem.title = @"Browser";
    itemNavController.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    itemNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [self setNavBarStyleForNavController:itemNavController];
    
    userController = [[UserViewController alloc] init];
    userNavController = [[UINavigationController alloc] initWithRootViewController:userController];
    //userNavController.tabBarItem.title = @"Profile";
    userNavController.tabBarItem.image = [UIImage imageNamed:@"me.png"];
    userNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self setNavBarStyleForNavController:userNavController];
    
    if (![currentUser.uid isEqualToString:@""])//With user logged in.
    {
        [[[[[FIRDatabase database] reference] child:@"users-detail"] child:currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
            if (snapshot.exists) {
                [userController SwitchToProfileViewWithUID:currentUser.uid];
            } else {
                NSLog(@"There's no matched data in database under this authenticated user.");
            }
        }];
    }
    
    postItemController = [[PostItemViewController alloc] init];
    postNavController = [[UINavigationController alloc] initWithRootViewController:postItemController];
    //postNavController.tabBarItem.title = @"Add";
    postNavController.tabBarItem.image = [UIImage imageNamed:@"add.png"];
    postNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [self setNavBarStyleForNavController:postNavController];
    
    notificationController = [[NotificationViewController alloc] initWithStyle:UITableViewStylePlain];
    msgNavController = [[UINavigationController alloc] initWithRootViewController:notificationController];
    //msgNavController.tabBarItem.title = @"Message";
    msgNavController.tabBarItem.image = [UIImage imageNamed:@"noti.png"];
    msgNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    [self setNavBarStyleForNavController:msgNavController];
    
    [viewControllerArray addObject:itemNavController];//index=0
    [viewControllerArray addObject:userNavController];//index=1
    [viewControllerArray addObject:postNavController];//index=2
    [viewControllerArray addObject:msgNavController];//index=3
    
    tabBarController.viewControllers = viewControllerArray;
    tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"aps"])
    {
        NSLog(@"LAUNCH FROM NOTIFICATION");
    }
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    
    return YES;
}

- (void)setNavBarStyleForNavController:(UINavigationController *)navController
{
    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //[navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"goldCrown"] forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar setTranslucent:YES];
    
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:72.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1.0f], NSForegroundColorAttributeName, [UIFont fontWithName:@"SFUIDisplay-Bold" size:17.0], NSFontAttributeName, nil]];
    [navController.navigationBar setTintColor:[UIColor colorWithRed:67.0/255.0 green:169.0/255.0 blue:242.0/255.0 alpha:1.0f]];
}

- (void)customizeBatchToken
{
    if (![currentUser.uid isEqualToString:@""])//With user logged in.
    {
        BatchUserDataEditor *editor = [BatchUser editor];
        [editor setIdentifier:currentUser.uid];
        [editor save];
        NSLog(@"Customize Batch Token to :%@", currentUser.uid);
    }
}

- (void)resetBatchToken
{
    BatchUserDataEditor *editor = [BatchUser editor];
    [editor setIdentifier:nil];
    [editor save];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"CurrentUser"])
    {
        [standardUserDefaults removeObjectForKey:@"CurrentUser"];
        [standardUserDefaults synchronize];
    }
    
    currentUser = [[User alloc] initWithAnonymousUser];
    NSLog(@"Reset Batch Token.");
}

- (void)saveToUserDefaults:(NSDictionary *)userDic
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
    {
        [standardUserDefaults setObject:userDic forKey:@"CurrentUser"];
        [standardUserDefaults synchronize];
    }
}

// With "FirebaseAppDelegateProxyEnabled": NO
/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}*/

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"DID REGISTER");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"REGISTER REMOTE WITH DEVICE TOKEN: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"FAIL TO REGISTER: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    NSLog(@"HAHA");
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [BatchPush dismissNotifications];
    
    NSLog(@"USERINFO %@", userInfo);
    
    NSString *receivedUID = [BatchPush deeplinkFromUserInfo:userInfo];
    NSLog(@"Receive Request: %@", receivedUID);
    
    if (application.applicationState == UIApplicationStateInactive){
        NSLog(@"APPLICATION INACTIVE");

        tabBarController.selectedIndex = 3;
        
        completionHandler(UIBackgroundFetchResultNoData);
        
    }else if (application.applicationState == UIApplicationStateBackground){
        NSLog(@"APPLICATION BACKGROUND");
        //Refresh the local model
        completionHandler(UIBackgroundFetchResultNoData);
    }else{
        NSLog(@"APPLICATION ACTIVE");
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    //Called when a notification is delivered while Quupe is running in the foreground,
    NSLog(@"Will Present User Info: %@", notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    //Called to let your app know which action was selected by the user for a given notification.
    //Deal with both local notifications and remote notifications.
    NSLog(@"Did Receive User Info: %@", response.notification.request.content.userInfo);
    tabBarController.selectedIndex = 3;
    completionHandler();
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"PERFORM FETCH");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"APPLICATION ENTER BACKGROUND");
    //[self resetBatchToken];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"APPLICATION WILL TERMINATE");
    
    //When user force quit this app by doule clicking home and swipe up, this function is called.
    //[self resetBatchToken];
}

@end
