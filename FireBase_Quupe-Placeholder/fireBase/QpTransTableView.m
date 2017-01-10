//
//  QpTransTableView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-02.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpTransTableView.h"

@interface QpTransTableView ()
{
    AppDelegate *appDelegate;
    NSMutableArray *completedTrans;
    NSMutableArray *progressTrans;
}

@end

@implementation QpTransTableView

@synthesize ref;
@synthesize tableData;
@synthesize controllerDelegate;
@synthesize simplified;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        
        ref = [[FIRDatabase database] reference];
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        tableData = [[NSMutableArray alloc] init];
        simplified = NO;
        
        self.layoutMargins = self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)sortCells
{
    completedTrans = [[NSMutableArray alloc] init];
    progressTrans = [[NSMutableArray alloc] init];
    
    for (int i=0; i<tableData.count; i++) {
        if ([[[tableData objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"completed"] || [[[tableData objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"cancelled"]) {
            [completedTrans addObject:[tableData objectAtIndex:i]];
        }else{
            [progressTrans addObject:[tableData objectAtIndex:i]];
        }
    }
}

#pragma TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return progressTrans.count;
    }else{
        return completedTrans.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"In Progress (%lu)", progressTrans.count];
    }else{
        return [NSString stringWithFormat:@"Completed (%lu)", completedTrans.count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(10, 5, self.frame.size.width - 2*10, 20);
    headerLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
    headerLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (simplified) {
        return 90;
    }else{
        return 100;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TransactionTableCell1";
    if (simplified) {
        cellIdentifier = @"TransactionTableCell2";
    }
    
    TransactionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (indexPath.section == 0) {
        if ([[progressTrans objectAtIndex:indexPath.row] objectForKey:@"iPic"]) {
            [cell createThumbnailIconWithURL:[[NSURL alloc] initWithString:[[progressTrans objectAtIndex:indexPath.row] objectForKey:@"iPic"]]];
        }else{
            cell.imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
        }
        
        cell.itemName.text = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"iName"];
        cell.itemDirection = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"direction"];
        cell.directionLabel.text = cell.itemDirection;
        cell.itemPrice.text = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"rTotal"];
        cell.itemKey = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"key"];
        cell.targetUID = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"targetUID"];
        cell.itemRentRange.text = [[progressTrans objectAtIndex:indexPath.row] objectForKey:@"period"];
        cell.delegate = self;
        
        [cell loadButtonsWithItemStatus:[[progressTrans objectAtIndex:indexPath.row] objectForKey:@"status"]];
    }else{
        if ([[completedTrans objectAtIndex:indexPath.row] objectForKey:@"iPic"]) {
            [cell createThumbnailIconWithURL:[[NSURL alloc] initWithString:[[completedTrans objectAtIndex:indexPath.row] objectForKey:@"iPic"]]];
        }else{
            cell.imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
        }
        
        cell.itemName.text = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"iName"];
        cell.itemDirection = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"direction"];
        cell.directionLabel.text = cell.itemDirection;
        NSLog(@"%@, %@", cell.itemName.text, cell.directionLabel.text);
        cell.itemPrice.text = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"rTotal"];
        cell.itemKey = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"key"];
        cell.targetUID = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"targetUID"];
        cell.itemRentRange.text = [[completedTrans objectAtIndex:indexPath.row] objectForKey:@"period"];
        cell.delegate = self;
        
        [cell loadButtonsWithItemStatus:[[completedTrans objectAtIndex:indexPath.row] objectForKey:@"status"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"SELECT ROW %ld IN TRANS.", indexPath.row);
}


- (void)paymentSucceededForItem:(NSDictionary *)itemInfo Token:(NSString *)token
{
    NSLog(@"PAYMENT SUCCEEDED!");
    [self SetItemStatusTo:@"paid" ItemKey:[itemInfo objectForKey:@"key"] TargetUID:[itemInfo objectForKey:@"targetUID"]];
    
    NSString *key = [[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"transactions"] child:@"incoming"] childByAutoId].key;
    NSDictionary *transDic = @{@"borrower": appDelegate.currentUser.uid,
                               @"iDays": @"Default Days",
                               @"iID": [itemInfo objectForKey:@"itemNo"],
                               @"iName": [itemInfo objectForKey:@"iName"],
                               @"iPrice": @"$0",
                               @"id": token,
                               @"key": key,
                               @"lender": [itemInfo objectForKey:@"targetUID"],
                               @"time": [FIRServerValue timestamp]};//Need to check with Zeeshan about the "id".
    
    //current user is borrower, add node under transaction->incoming
    [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"transactions"] child:@"incoming"] child:key] setValue:transDic];
    //target user is lender, add node under transaction->outgoing
    [[[[[[ref child:@"users-detail"] child:[itemInfo objectForKey:@"targetUID"]] child:@"transactions"] child:@"outgoing"] child:key] setValue:transDic];
    
    [[[ref child:@"transactions"] child:key] setValue:transDic];
    
    [self SetItemStatusTo:@"paid" ItemKey:[itemInfo objectForKey:@"key"]TargetUID:[itemInfo objectForKey:@"targetUID"]];
}

#pragma TransactionCellDelegate
- (void)SetItemStatusTo:(NSString *)itemStatus ItemKey:(NSString *)key TargetUID:(NSString *)targetUID
{
    [[[[ref child:@"requests"] child:key] child:@"status"] setValue:itemStatus];
    
    [[[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:key] child:@"status"] setValue:itemStatus];
    [[[[[[[[ref child:@"users-detail"] child:targetUID] child:@"chats"] child:appDelegate.currentUser.uid] child:@"items"] child:key] child:@"status"] setValue:itemStatus];
    
    [self sendBatchNotificationWithItemStatus:itemStatus TargetUID:targetUID];
}

- (void)SwitchToCheckoutViewWithCell:(TransactionTableCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSDictionary *currentItemInfo;
    
    if (indexPath.section == 0) {
        currentItemInfo = [progressTrans objectAtIndex:indexPath.row];
    }else{
        currentItemInfo = [completedTrans objectAtIndex:indexPath.row];
    }
    
    NSString *price = [[[[currentItemInfo objectForKey:@"rTotal"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""];
    NSLog(@"PAYMENT AMOUNT: %@", price);
    
    [self.controllerDelegate SwitchToCheckoutViewWithPrice:[NSDecimalNumber decimalNumberWithString:price] ItemInfo:currentItemInfo];
}

- (void)SwitchToReviewView
{
    [self.controllerDelegate SwitchToReviewView];
}

- (void)sendBatchNotificationWithItemStatus:(NSString *)itemStatus TargetUID:(NSString *)targetUID
{
    BatchClientPush * clientPush = [[BatchClientPush alloc] initWithApiKey:@"57E3E842BC993832AEFFDFDE25ED4D" restKey:@"7df47add057c4e0b181c4c0676faf69c"];
    clientPush.sandbox = NO;
    clientPush.customPayload = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"content-available", nil], @"aps", nil];
    clientPush.deeplink = appDelegate.currentUser.uid;
    clientPush.groupId = @"tests";
    clientPush.message.title = @"Item Status Update";
    clientPush.message.body = @"";
    
    if ([itemStatus isEqualToString:@"accepted"]) {
        //Your request for Keyboard has been accepted by Becky. Please make the payment before the lender can rent it out to you.
        clientPush.message.body = [NSString stringWithFormat:@"Your request has been accepted by %@. Please make the payment before the lender can rent it out to you.", appDelegate.currentUser.name];
    }
    else if ([itemStatus isEqualToString:@"cancelled"]){
        clientPush.message.body = [NSString stringWithFormat:@"Your request has been cancelled by %@.", appDelegate.currentUser.name];
    }
    else if ([itemStatus isEqualToString:@"paid"]){
        clientPush.message.body = [NSString stringWithFormat:@"Request from %@ has been paid. Please prepare to rent it out.", appDelegate.currentUser.name];
    }
    else if ([itemStatus isEqualToString:@"rented"]){
        //Becky's Keyboard has been rented to you for 3 days. Enjoy!
        clientPush.message.body = [NSString stringWithFormat:@"%@ has rented to you.", appDelegate.currentUser.name];
    }
    else if ([itemStatus isEqualToString:@"returned"]){
        clientPush.message.body = [NSString stringWithFormat:@"%@ has returned your staff.", appDelegate.currentUser.name];
    }
    else if ([itemStatus isEqualToString:@"completed"]){
        //Your rental for Keyboard has been completed. You borrowed it from Becky for 3 days and $0!
        clientPush.message.body = [NSString stringWithFormat:@"Your rental from %@ has been completed.", appDelegate.currentUser.name];
    }
    clientPush.recipients.customIds = @[targetUID];
    
    [clientPush sendWithCompletionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Batch Push Error %@", error.description);
        }else{
            NSLog(@"Batch Send Item Status Change %@", response);
            NSLog(@"LenderUID: %@", targetUID);
        }
    }];
}

@end
