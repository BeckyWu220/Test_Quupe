//
//  NotificationViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-05.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()
{
    NSMutableDictionary *userMsgStatusDic;
    NSMutableArray *userInfoArray;
    AppDelegate *appDelegate;
}

@end

@implementation NotificationViewController

@synthesize ref;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.view.backgroundColor = [UIColor yellowColor];
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        self.navigationItem.title = @"Message";
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        ref = [[FIRDatabase database] reference];
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        
        userMsgStatusDic = [[NSMutableDictionary alloc] init];
        userInfoArray = [[NSMutableArray alloc] init];
        
        /*if (![appDelegate.currentUser.uid isEqualToString:@""]) {
            [self loadChatTargets];
        }*/
        self.tableView.layoutMargins = self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.tableFooterView = [[UIView alloc] init];
        
    }
    return self;
}


- (void)loadChatTargets
{
    NSLog(@"RELOAD CHAT");
    
    [[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"noti"] setValue:@"0"];
    
    [[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            NSArray *chatTargetUIDs = [retrieveDataDict allKeys];
            
            NSLog(@"CHATS KEY: %@", chatTargetUIDs);
            
            NSMutableArray *newUserInfoArray = [[NSMutableArray alloc] init];
            
            for (int i=0; i<chatTargetUIDs.count; i++)
            {
                //Find status->seen node
                [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:[chatTargetUIDs objectAtIndex:i]] child:@"status"] child:@"seen"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
                    NSLog(@"%@ SEEN CHANGE: %@", [chatTargetUIDs objectAtIndex:i], snapshot.value);
                    
                    [userMsgStatusDic setObject:[NSString stringWithFormat:@"%@", snapshot.value] forKey:[chatTargetUIDs objectAtIndex:i]];
                    
                    [self.tableView reloadData];
                    //[self.tableView beginUpdates];
                    //[self.tableView endUpdates];
                }];
                
                //Find target user's name and icon with targetUID from users-detail -> targetUID node
                [[[ref child:@"users-detail"] child:[chatTargetUIDs objectAtIndex:i]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    NSDictionary *chatTargetInfo = snapshot.value;
                    
                    NSString *userName = [chatTargetInfo objectForKey:@"name"];
                    NSURL *userIconURL = [NSURL URLWithString:[chatTargetInfo objectForKey:@"img"]];
                    
                    if (!userIconURL) {
                        userIconURL = [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/quupe-restore.appspot.com/o/images%2F1476140364491.jpg?alt=media&token=e83160df-23c3-47c9-8067-413a4425691c"];
                    }
                    
                    NSString *userUID = [chatTargetInfo objectForKey:@"uid"];
                    
                    NSArray *userInfo = [NSArray arrayWithObjects:userName, userIconURL, userUID, nil];//username index=0, userIconURL index=1, userUID index=2
                    
                    [newUserInfoArray addObject:userInfo];
                    
                    [self.tableView reloadData];
                    //[self.tableView beginUpdates];
                    //[self.tableView endUpdates];
                }];
                
            }
            
            userInfoArray = newUserInfoArray;
        }else{
            NSLog(@"Snapshot Not Exist in users-detail->currentUserUID->chats of NotificationVC.");
        }
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW APPEAR");
    if ([appDelegate.currentUser.uid isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please login first to check your private messages." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }else {
        [self loadChatTargets];//The current user has logged in.
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"VIEW DISAPPEAR");
    if (![appDelegate.currentUser.uid isEqualToString:@""]) {
        [[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] removeAllObservers];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTabelCell"];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (userInfoArray.count > 0) {
        cell.userNameLabel.text = [[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:0];
        if ([[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:1])
        {
            [cell createThumbnailIconWithURL:[[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:1]];
        }else{
            cell.userIcon.image = [UIImage imageNamed:@"default-profile.jpg"];
        }
        
        if ([[userMsgStatusDic objectForKey:[[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:2]] isEqualToString:@"1"])
        {
            //The current user has unread message with this target user.
            cell.seenMark.hidden = NO;
        }else{
            cell.seenMark.hidden = YES;
        }
    }
    
    
    NSLog(@"CELL IMAGE SIZE: %@", NSStringFromCGSize(cell.userIcon.image.size));
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageViewController *msgViewController = [MessageViewController messagesViewController];
    
    msgViewController.navigationItem.title = [[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:0];
    msgViewController.targetUID = [[userInfoArray objectAtIndex:indexPath.row] objectAtIndex:2];
    
    MessageTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    msgViewController.targetIcon = cell.userIcon.image;
    
    msgViewController.senderId = appDelegate.currentUser.uid;
    msgViewController.senderDisplayName = appDelegate.currentUser.name;
    NSLog(@"SIZE! MSG H: %f", msgViewController.view.frame.size.height);
    msgViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgViewController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.tabBarController.selectedIndex = 1;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
