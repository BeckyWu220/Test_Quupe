//
//  InvoiceViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2017-02-09.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "InvoiceViewController.h"

@interface InvoiceViewController ()
{
    AppDelegate *appDelegate;
    
    NSString *itemDirection;
    NSString *targetUID;
    NSDictionary *itemInfo;
    
    UILabel *itemNameLabel;
    UILabel *rentalPeriodLabel;
    UILabel *itemStatusLabel;
    UILabel *totalPriceLabel;
    
    UIView *btnView;
    QpButton *acceptBtn;
    QpButton *cancelBtn;
    QpButton *payBtn;
    QpButton *rentBtn;
    QpButton *returnBtn;
    QpButton *completeBtn;
    QpButton *reviewBtn;
    
    UILabel *tipLabel;
}

@end

@implementation InvoiceViewController

@synthesize ref;
@synthesize itemKey;

- (id)initWithItemKey:(NSString *)key TargetUID:(NSString *)uid
{
    self = [super init];
    if (self) {
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        ref = [[FIRDatabase database] reference];
        
        self.navigationItem.title = @"Invoice";
        self.view.backgroundColor = [UIColor whiteColor];
        
        rentalPeriodLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 74.0f, self.view.frame.size.width - 2*10.0f, 20.0f)];
        rentalPeriodLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:13.0f];
        rentalPeriodLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        [self.view addSubview:rentalPeriodLabel];
        
        itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, rentalPeriodLabel.frame.origin.y + rentalPeriodLabel.frame.size.height + 10.0f, self.view.frame.size.width - 2*10.0f, 20.0f)];
        itemNameLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        itemNameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        [self.view addSubview:itemNameLabel];
        
        itemStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100.0f, rentalPeriodLabel.frame.origin.y + (rentalPeriodLabel.frame.size.height + itemNameLabel.frame.size.height + 10.0f)/2-10.0f, 100.0f, 20.0f)];
        itemStatusLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        itemStatusLabel.textAlignment = NSTextAlignmentCenter;
        itemStatusLabel.textColor = [UIColor colorWithRed:67.0/255.0 green:169.0/255.0 blue:241.0/255.0 alpha:1.0f];
        [self.view addSubview:itemStatusLabel];
        
        totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, itemNameLabel.frame.origin.y + itemNameLabel.frame.size.height + 10.0f, self.view.frame.size.width - 2*10.0f, 20.0f)];
        totalPriceLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        totalPriceLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        [self.view addSubview:totalPriceLabel];
        
        btnView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, totalPriceLabel.frame.origin.y + totalPriceLabel.frame.size.height + 50.0f, self.view.frame.size.width - 20.0f, 35.0f*2+5.0f)];
        [self.view addSubview:btnView];
        
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnView.frame.size.width, btnView.frame.size.height)];
        tipLabel.text = @"";
        tipLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        tipLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel.numberOfLines = 0;
        [btnView addSubview:tipLabel];
        
        acceptBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Accept"];
        [btnView addSubview:acceptBtn];
        acceptBtn.delegate = self;
        acceptBtn.hidden = YES;
        
        cancelBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Cancel"];
        [btnView addSubview:cancelBtn];
        cancelBtn.delegate = self;
        cancelBtn.hidden = YES;
        
        payBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Pay"];
        [btnView addSubview:payBtn];
        payBtn.delegate = self;
        payBtn.hidden = YES;
        
        rentBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Rented"];
        [btnView addSubview:rentBtn];
        rentBtn.delegate = self;
        rentBtn.hidden = YES;
        
        returnBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Returned"];
        [btnView addSubview:returnBtn];
        returnBtn.delegate = self;
        rentBtn.hidden = YES;
        
        completeBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Complete"];
        [btnView addSubview:completeBtn];
        completeBtn.delegate = self;
        completeBtn.hidden = YES;
        
        reviewBtn = [[QpButton alloc] initWithFrame:CGRectZero Title:@"Review"];
        [btnView addSubview:reviewBtn];
        reviewBtn.delegate = self;
        reviewBtn.hidden = YES;
        
        self.itemKey = key;
        targetUID = uid;
        
        [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:key] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
            if (snapshot.exists) {
                NSDictionary *retrieveDataDict = snapshot.value;
                NSLog(@"Invoice: %@", retrieveDataDict);
                
                itemNameLabel.text = [retrieveDataDict objectForKey:@"iName"];
                rentalPeriodLabel.text = [retrieveDataDict objectForKey:@"period"];
                itemStatusLabel.text = [retrieveDataDict objectForKey:@"status"];
                totalPriceLabel.text = [retrieveDataDict objectForKey:@"rTotal"];
                
                if ([[retrieveDataDict objectForKey:@"borrower"] isEqualToString:appDelegate.currentUser.uid]) {
                    itemDirection = @"Borrowed";
                    
                }else if ([[retrieveDataDict objectForKey:@"lender"] isEqualToString:appDelegate.currentUser.uid]){
                    itemDirection = @"Lent";
                }
                [retrieveDataDict setValue:itemDirection forKey:@"direction"];
                [retrieveDataDict setValue:targetUID forKey:@"targetUID"];
                
                itemInfo = [[NSDictionary alloc] initWithDictionary:retrieveDataDict];
                
                [self loadButtonsWithItemStatus:itemStatusLabel.text];
                
            }else{
                NSLog(@"Snapshot Not Exist in requests->itemKey of InvoiceVC.");
            }
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadButtonsWithItemStatus:(NSString *)itemStatus
{
    tipLabel.text = @"";
    acceptBtn.hidden = YES;
    cancelBtn.hidden = YES;
    payBtn.hidden = YES;
    rentBtn.hidden = YES;
    returnBtn.hidden = YES;
    completeBtn.hidden = YES;
    reviewBtn.hidden = YES;
    
    if ([itemStatus isEqualToString:@"requested"])
    {
        //Show AcceptBtn and CancelBtn to Lender, CancelBtn to Borrower
        if ([itemDirection isEqualToString:@"Lent"])
        {
            acceptBtn.frame = CGRectMake(0, 0, btnView.frame.size.width, 35);
            acceptBtn.hidden = NO;
            
            cancelBtn.frame = CGRectMake(0, acceptBtn.frame.size.height+4, btnView.frame.size.width, 35);
            cancelBtn.hidden = NO;
            
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            cancelBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 35);
            cancelBtn.hidden = NO;
        }
        
    }else if ([itemStatus isEqualToString:@"accepted"])
    {
        //Show PayBtn and CancelBtn to Borrower, CancelBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]) {
            cancelBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 35);
            cancelBtn.hidden = NO;
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            payBtn.frame = CGRectMake(0, 0, btnView.frame.size.width, 35);
            payBtn.hidden = NO;
            
            cancelBtn.frame = CGRectMake(0, payBtn.frame.size.height+4, btnView.frame.size.width, 35);
            cancelBtn.hidden = NO;
        }
        
    }else if ([itemStatus isEqualToString:@"paid"])
    {
        //Show RentBtn to Lender, ReportBtn to Borrower
        if ([itemDirection isEqualToString:@"Lent"]){
            rentBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 35);
            rentBtn.hidden = NO;
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            //ReportBtn
            tipLabel.text = @"Your payment has been received. Please wait for lender to rent this item.";
        }
        
    }else if ([itemStatus isEqualToString:@"rented"])
    {
        //Show ReturnBtn to Borrower, ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            //ReportBtn
            tipLabel.text = @"Please wait for borrower to return this item.";
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            returnBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 35);
            returnBtn.hidden = NO;
        }
        
    }else if ([itemStatus isEqualToString:@"returned"]){
        //Show ReviewBtn to Borrower, CompleteBtn and ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            completeBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 35);
            completeBtn.hidden = NO;
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            
            [self checkReviewToDisplayReviewBtn];
        }
        
    }else if ([itemStatus isEqualToString:@"completed"]){
        //Detect if lender/borrower has reviewed to show rating or reviewBtn.
        [self checkReviewToDisplayReviewBtn];
        
    }else//when itemStatus is "cancelled"
    {
        //Do nothing for now.
    }
}

#pragma QpButtonDelegate
- (void)ClickQpButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Accept"])
    {
        [self SetItemStatusTo:@"accepted"];
    }
    else if ([title isEqualToString:@"Cancel"])
    {
        [self SetItemStatusTo:@"cancelled"];
    }
    else if ([title isEqualToString:@"Pay"])
    {
        [self SwitchToCheckoutView];
    }
    else if ([title isEqualToString:@"Rented"])
    {
        [self SetItemStatusTo:@"rented"];
    }
    else if ([title isEqualToString:@"Returned"])
    {
        [self SetItemStatusTo:@"returned"];
    }
    else if ([title isEqualToString:@"Complete"])
    {
        [self SetItemStatusTo:@"completed"];
    }
    else if ([title isEqualToString:@"Review"])
    {
        [self SwitchToReviewView];
    }
}

- (void)checkReviewToDisplayReviewBtn
{
    [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:itemKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            if (![retrieveDataDict objectForKey:@"review"] || [[retrieveDataDict objectForKey:@"review"] isEqualToString:@"0"]) {
                //User didn't review for this item yet.
                reviewBtn.frame = CGRectMake(0, 15, btnView.frame.size.width, 35);
                reviewBtn.hidden = NO;
                NSLog(@"Not Reviewed Yet. - Invoice View");
            }else{
                NSLog(@"Already Reviewed.");
                reviewBtn.hidden = YES;
                tipLabel.text = @"You've reviewed this item. - Invoice View";
            }
            
        }else{
            NSLog(@"snapshot doesn't exist in users-detail->uid->chats->targetUID->items");
        }
    }];
}

- (void)SwitchToCheckoutView
{
    NSLog(@"Switch From Invoice to Payment.");
    
    NSString *price = [[[[itemInfo objectForKey:@"rTotal"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""];
    NSLog(@"PAYMENT AMOUNT: %@", price);
    
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithItemInfo:itemInfo Price:[NSDecimalNumber decimalNumberWithString:price]];
    paymentViewController.delegate = self;
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

- (void)SwitchToReviewView
{
    NSLog(@"Switch From Invoice to Review.");
    
    ReviewViewController *reviewController = [[ReviewViewController alloc] initWithTargetUID:targetUID ForItem:itemKey];
    [self.navigationController pushViewController:reviewController animated:YES];
}

- (void)SetItemStatusTo:(NSString *)itemStatus
{
    [[[[ref child:@"requests"] child:itemKey] child:@"status"] setValue:itemStatus];
    
    [[[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:itemKey] child:@"status"] setValue:itemStatus];
    [[[[[[[[ref child:@"users-detail"] child:targetUID] child:@"chats"] child:appDelegate.currentUser.uid] child:@"items"] child:itemKey] child:@"status"] setValue:itemStatus];
    
    [self sendBatchNotificationWithItemStatus:itemStatus];
}

- (void)sendBatchNotificationWithItemStatus:(NSString *)itemStatus
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

#pragma PaymentViewControllerDelegate
- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (error) {
                [self presentError:error];
            } else {
                [self paymentSucceededForItem:controller.itemInfo Token:controller.paymentToken.tokenId];
                [self presentSuccess];
                
            }
        }];
        [self.navigationController popToViewController:self animated:YES];
        [CATransaction commit];
    });
}

- (void)presentSuccess
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Success" message:@"Payment successfully created!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)presentError:(NSError *)error
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)paymentSucceededForItem:(NSDictionary *)itemInfo Token:(NSString *)token
{
    NSLog(@"PAYMENT SUCCEEDED!");
    [self SetItemStatusTo:@"paid"];
    
    NSString *key = [[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"transactions"] child:@"incoming"] childByAutoId].key;
    NSDictionary *transDic = @{@"borrower": appDelegate.currentUser.uid,
                               @"iDays": [itemInfo objectForKey:@"rDay"],
                               @"iID": [itemInfo objectForKey:@"itemNo"],
                               @"iName": [itemInfo objectForKey:@"iName"],
                               @"iPrice": [itemInfo objectForKey:@"rTotal"],
                               @"id": token,
                               @"key": key,
                               @"lender": [itemInfo objectForKey:@"targetUID"],
                               @"time": [FIRServerValue timestamp]};//Need to check with Zeeshan about the "id".
    
    //current user is borrower, add node under transaction->incoming
    [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"transactions"] child:@"incoming"] child:key] setValue:transDic];
    //target user is lender, add node under transaction->outgoing
    [[[[[[ref child:@"users-detail"] child:[itemInfo objectForKey:@"targetUID"]] child:@"transactions"] child:@"outgoing"] child:key] setValue:transDic];
    
    //Update requests node under lender and borrower's chats->items node, and parent requests node.
    NSMutableArray *requestRefs = [[NSMutableArray alloc] init];
    
    FIRDatabaseReference *requestRef_1 = [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:[itemInfo objectForKey:@"targetUID"]] child:@"items"] child:self.itemKey];
    [requestRefs addObject:requestRef_1];
    
    FIRDatabaseReference *requestRef_2 = [[[[[[ref child:@"users-detail"] child:[itemInfo objectForKey:@"targetUID"]] child:@"chats"] child:appDelegate.currentUser.uid] child:@"items"] child:self.itemKey];
    [requestRefs addObject:requestRef_2];
    
    FIRDatabaseReference *requestRef_3 = [[ref child:@"requests"] child:self.itemKey];
    [requestRefs addObject:requestRef_3];
    
    for (int i=0; i<3; i++) {
        [[[requestRefs objectAtIndex:i] child:@"payment"] setValue:@"Paid using Credit Card"];
        [[[requestRefs objectAtIndex:i] child:@"transaction"] setValue:@"1"];
        [[[requestRefs objectAtIndex:i] child:@"token"] setValue:token];
    }
    
    [[[ref child:@"transactions"] child:key] setValue:transDic];
    
    [self SetItemStatusTo:@"paid"];
}

@end
