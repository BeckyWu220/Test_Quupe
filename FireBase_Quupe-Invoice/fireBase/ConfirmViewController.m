//
//  ConfirmViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-23.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ConfirmViewController.h"

@interface ConfirmViewController ()
{
    QpRentInfoView *rentInfoView;
    QpBreakdownView *breakdownView;
    Item *currentItem;
    QpTableView *textTableView;
    CGSize currentScrollContentSize;
    UIButton *confirmBtn;
    AppDelegate *appDelegate;
    
    int itemRentDay;
    float itemRentalPrice;
    NSString *itemRentRange;
    float itemRentalPerDay;
    
    float deliveryFee;
    float insuranceFee;
    
    UIView *doneView;
    UIViewController *doneController;
}

@end

@implementation ConfirmViewController

@synthesize scrollView;
@synthesize ref;

- (id)initWithItem:(Item *)item RentDay:(int)rentDay TotalPrice:(float) rentalPrice RentRange:(NSString *)rentRange RentalPerDay:(float)rentalDay
{
    self = [super init];
    if (self) {
        
        self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        self.view.backgroundColor = [UIColor whiteColor];
        
        currentItem = item;
        itemRentDay = rentDay;
        itemRentalPrice = rentalPrice;
        itemRentRange = rentRange;
        itemRentalPerDay = rentalDay;
        
        deliveryFee = 0.0f;
        insuranceFee = 0.0f;
        
        self.navigationItem.title = @"Order Details";
        
        ref = [[FIRDatabase database] reference];
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        currentScrollContentSize = scrollView.frame.size;
        scrollView.contentSize = currentScrollContentSize;
        [self.view addSubview:scrollView];
        
        rentInfoView = [[QpRentInfoView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80) ItemName:currentItem.title RentalPrice:itemRentalPrice RentRange:itemRentRange];
        [scrollView addSubview:rentInfoView];
        
        textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0,rentInfoView.frame.origin.y+rentInfoView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 44.0*2) Data:[NSArray arrayWithObjects:@[@"Transfer", @"Not Specified", [NSNumber numberWithInteger:HORIZONTAL_UIPICKER_TYPE], @[@"Pick Up", @"Meet Up", @"Delivery"]], @[@"Insurance", @"Not Specified", [NSNumber numberWithInteger:HORIZONTAL_UIPICKER_TYPE], @[@"Yes", @"No"]], nil]];
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
        
        breakdownView = [[QpBreakdownView alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y+textTableView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 25.0f*4) RentalPrice:rentalPrice];
        [scrollView addSubview:breakdownView];
        
        confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, breakdownView.frame.origin.y+breakdownView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
        confirmBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(clickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:confirmBtn];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)clickConfirmBtn
{
    NSLog(@"Click Confirm");
    [self generateRequest];
    
    doneController = [[UIViewController alloc] init];
    doneController.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *doneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done"]];
    doneImgView.frame = CGRectMake((self.view.frame.size.width - 378/2)/2, (self.view.frame.size.height - 346/2)/2 - 100, 378/2, 346/2);
    [doneController.view addSubview:doneImgView];
    
    UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(doneImgView.frame.origin.x, doneImgView.frame.origin.y + doneImgView.frame.size.height + 30.0f, doneImgView.frame.size.width, 30)];
    doneLabel.text = @"All Done!";
    doneLabel.textAlignment = NSTextAlignmentCenter;
    doneLabel.textColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    doneLabel.font = [UIFont fontWithName:@"SFUIDisplay-Bold" size:16.0];
    //doneLabel.backgroundColor = [UIColor yellowColor];
    [doneController.view addSubview:doneLabel];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(doneImgView.frame.origin.x, doneLabel.frame.origin.y + doneLabel.frame.size.height + 20.0f, doneImgView.frame.size.width, 100.0f)];
    tipLabel.text = @"You will receive notification when lender confirmed your request.";
    tipLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
    tipLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 0;
    //tipLabel.backgroundColor = [UIColor yellowColor];
    [doneController.view addSubview:tipLabel];
    
    doneController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:doneController animated:YES completion:^{
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(switchToItemDetailPage) userInfo:nil repeats:NO];
    }];
    
    /*doneView = [[UIView alloc] initWithFrame:self.view.frame];
    doneView.backgroundColor = [UIColor blueColor];
    [UIView transitionFromView:self.view toView:doneView duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:YES];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(switchToItemDetailPage) userInfo:nil repeats:NO];
    }];*/
}

- (void)switchToItemDetailPage
{
    NSLog(@"!!!!!!");
    /*[self.navigationController setNavigationBarHidden:NO];
    [UIView transitionFromView:doneView toView:self.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];*/
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)generateRequest
{
    NSString *key = [[ref child:@"requests"] childByAutoId].key;
    NSLog(@"Generate Request Key: %@", key);
    
    NSDictionary *request = @{@"borrower": appDelegate.currentUser.uid,
                              @"comment": @"0",
                              @"delfee": [NSString stringWithFormat:@"$%.2f", deliveryFee],
                              @"iName": currentItem.title,
                              @"insfee": [NSString stringWithFormat:@"$%.2f", insuranceFee],
                              @"invoice": @"0",
                              @"iPic": [NSString stringWithFormat:@"%@", currentItem.photo],
                              @"itemNo": currentItem.key,
                              @"lender": currentItem.uid,
                              @"payfee": [NSString stringWithFormat:@"$%.2f", itemRentalPrice*0.027f+0.30f],/*payment processing fee for Stripe. 2.7% of total plus 30 cents.*/
                              @"payment": @"Pending",/*default value = @"Pending", will be changed into @"Paid using Credit Card" after the request has been paid.*/
                              @"perDay": [NSString stringWithFormat:@"$%.2f",itemRentalPerDay],
                              @"period": itemRentRange,
                              @"pref": @"None",/*defaulty @"None", might change to @"Added delivery", @"Added insurance", or@"Added delivery and insurance"*/
                              @"rating": @"0",
                              @"rCalDays": [NSString stringWithFormat:@"%d", itemRentDay],
                              @"rDay": [NSString stringWithFormat:@"%d", itemRentDay],
                              @"review": @"0",/*0 means a user hasn't give review yet.*/
                              @"rTotal": [NSString stringWithFormat:@"$%.2f", itemRentalPrice],/*how much the borrower need to pay.*/
                              @"serfee":[NSString stringWithFormat:@"$%.2f", itemRentalPrice*0.20f],/*Quupe service fee. 20% of total.*/
                              @"status": @"requested",
                              @"subtotal": [NSString stringWithFormat:@"$%.2f", itemRentalPrice-itemRentalPrice*0.20f-itemRentalPrice*0.027f-0.30f],/*how much a lender is getting after paying service fee and payment processing fee for Stripe.*/
                              @"time": [FIRServerValue timestamp],
                              @"token": @"0",/*payment token from Stripe*/
                              @"transaction": @"0"/*0 means a use hasn't pay yet. Will switch to 1 after payment.*/};
    
    [[[ref child:@"requests"] child:key] setValue:request withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Error: Fail To Store Request. %@", error.description);
        }else{
            
            [self generateTransactionWithKey:key Value:request];
            [self generateMessage];
            [self sendBatchNotification];
        }
    }];
}

- (void)generateTransactionWithKey:(NSString *)key Value:(NSDictionary *)value
{
    [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:currentItem.uid] child:@"items"] child:key] setValue:value];
    [[[[[[[ref child:@"users-detail"] child:currentItem.uid] child:@"chats"] child:appDelegate.currentUser.uid] child:@"items"] child:key] setValue:value];
}

- (void)generateMessage
{
    NSString *key = [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:currentItem.uid] child:@"messages"] childByAutoId].key;
    NSLog(@"Generate Message Key: %@", key);
    
    NSDictionary *msgDic = @{@"name": appDelegate.currentUser.name,
                             @"photoUrl": appDelegate.currentUser.imgURL,
                             @"text": [NSString stringWithFormat:@"Hi! I want to borrow your %@.", currentItem.title],
                             @"time": [FIRServerValue timestamp]};
    
    
    
    //This might have problems because the key is the same in both nodes, but the key is generated as the rule of lender's uid using childByAutoId method.
    [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:currentItem.uid] child:@"messages"] child:key] setValue:msgDic];
    
    [[[[[[[ref child:@"users-detail"] child:currentItem.uid] child:@"chats"] child:appDelegate.currentUser.uid] child:@"messages"] child:key] setValue:msgDic];
    
    [[[[[[[ref child:@"users-detail"] child:currentItem.uid] child:@"chats"] child:appDelegate.currentUser.uid] child:@"status"] child:@"seen"] setValue:@"1"];
    //set seen node to 1 means the target user has an unread message.
    
}

- (void)sendBatchNotification
{
    BatchClientPush * clientPush = [[BatchClientPush alloc] initWithApiKey:@"57E3E842BC993832AEFFDFDE25ED4D" restKey:@"7df47add057c4e0b181c4c0676faf69c"];
    clientPush.sandbox = NO;
    clientPush.customPayload = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"content-available", nil], @"aps", nil];
    clientPush.deeplink = appDelegate.currentUser.uid;
    clientPush.groupId = @"tests";
    clientPush.message.title = @"New Book Request";
    //Wanqiao is looking for your Keyboard from 18 Oct to 20 Oct (3 days) for $0!
    clientPush.message.body = [NSString stringWithFormat:@"%@ is looking for your %@.", appDelegate.currentUser.name ,currentItem.title];
    clientPush.recipients.customIds = @[currentItem.uid];
    //[[NSArray alloc] initWithObjects:@"wuwanqiao220", nil];
    //clientPush.recipients.tokens = [[NSArray alloc] init];
    //clientPush.recipients.tokens = [[NSArray alloc] initWithObjects:@"7b88b6d817d07754b61ade709302bd782a5e4dd2bb59de547b95d445f96df667", @"b49ecb57b56a245ca76a1f5d85215b3224e1bed78028a7c4bf0ccc9b47da9047", nil];//iPad Air 2 token
    
    [clientPush sendWithCompletionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Batch Push Error %@", error.description);
        }else{
            NSLog(@"Batch Push Send : %@", response);
            NSLog(@"LenderUID: %@", currentItem.uid);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma QpTableViewDelegate
- (void)changeScrollViewContentSizeBy:(CGFloat)tableViewChangedHeight NewTableHeight:(CGFloat)newTableViewHeight
{
    currentScrollContentSize = CGSizeMake(currentScrollContentSize.width, currentScrollContentSize.height - tableViewChangedHeight);
    scrollView.contentSize = currentScrollContentSize;
    
    //Update following UI position.
    breakdownView.frame = CGRectMake(0, textTableView.frame.origin.y+newTableViewHeight, [[UIScreen mainScreen] bounds].size.width, 30.0f*4+44.0f);
    confirmBtn.frame = CGRectMake(0, breakdownView.frame.origin.y+breakdownView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 35.0f);
}

- (void)setScrollViewContentYOffset:(CGFloat)yOffset WithKeyboardHeight:(CGFloat)keyboardHeight
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + yOffset);
    scrollView.contentInset = contentInsets;
    scrollView.contentOffset = CGPointMake(0, yOffset+64.0f);
    scrollView.scrollIndicatorInsets = contentInsets;
    scrollView.scrollEnabled = YES;
}

- (void)resetScrollViewContentOffset
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.contentOffset = CGPointZero;
    scrollView.scrollIndicatorInsets = contentInsets;
    scrollView.contentSize = currentScrollContentSize;
}

- (void)updateRelatedElementsInScrollViewWithCell:(TextTableCell *)cell
{
    //Update insurance and delivery fee in breakdownView.
    //TextTableCell *cell = [textTableView cellForRowAtIndexPath:textTableView.currentIndexPath];
    if (cell.type == VERTICAL_UIPICKER_TYPE || cell.type == HORIZONTAL_UIPICKER_TYPE) {
        NSString *currentOption = cell.contentTextView.text;
        if ([textTableView indexPathForCell:cell].row == 0) {
            //delivery
            if ([currentOption isEqualToString:@"Pick Up"]) {
                deliveryFee = 0.0f;
            }else if ([currentOption isEqualToString:@"Meet Up"]){
                deliveryFee = 0.0f;
            }else if ([currentOption isEqualToString:@"Delivery"]){
                deliveryFee = 10.0f;
            }
            [breakdownView setDeliveryPrice:deliveryFee];
            
        }else if ([textTableView indexPathForCell:cell].row == 1){
            //insurance
            //[@"Yes", @"No"
            if ([currentOption isEqualToString:@"Yes"]){
                insuranceFee = 5.0f;
            }else{
                insuranceFee = 0.0f;
            }
            [breakdownView setInsurancePrice:insuranceFee];
        }
    }
    
}


@end
