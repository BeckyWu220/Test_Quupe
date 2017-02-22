//
//  ProfileView.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-19.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ProfileView.h"

#import "UserViewController.h"

#import "User.h"

@interface ProfileView ()
{
    AppDelegate *appDelegate;
    NSIndexPath *currentIndexPath;
    UITableView *inventoryTable;
    NSMutableArray *inventoryItems;
    NSMutableArray *tabBtnArray;
    UIImageView *tabIndicator;
}
@end

@implementation ProfileView

@synthesize ref;
@synthesize imgView, logoutBtn, bioLabel, nameLabel;
@synthesize currentTableTitle;
@synthesize borrowTransTable, lendTransTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = frame;
        
        [self removeConstraints:self.constraints];
        
        self.showsVerticalScrollIndicator = YES;
        self.scrollEnabled = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        ref = [[FIRDatabase database] reference];
        
        //Retrieve name of a user with UID
        appDelegate = [[UIApplication sharedApplication] delegate];
        //NSLog(@"CURRENT USER ID: %@", appDelegate.currentUser.uid);
        
        //[self loadInfoFromUser:appDelegate.currentUser];
        
    }
    return self;
}

- (void) loadInfoFromUser:(User *)currentUser
{
    imgView = [[QpAsyncImage alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.clipsToBounds = YES;
    //imgView.layer.borderWidth = 3.0f;
    //imgView.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:imgView];
    
    NSString *imgURL = currentUser.imgURL;
    
    if (imgURL)
    {
        [imgView loadImageFromURL:[NSURL URLWithString:imgURL]];
    }
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, imgView.frame.origin.y, self.frame.size.width - imgView.frame.size.width - 3*10.0f, 25.0f)];
    nameLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
    nameLabel.textColor = [UIColor colorWithRed:72.0f/255.0f green:72.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
    nameLabel.text = currentUser.name;
    [self addSubview:nameLabel];
    
    QpRatingView *ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10.0f, 12.0f*5, 12.0f) Rating:currentUser.rating];
    [self addSubview:ratingView];
    
    UIButton *reviewBtn = [[UIButton alloc] initWithFrame:CGRectMake(ratingView.frame.origin.x + ratingView.frame.size.width + 10.0f, ratingView.frame.origin.y, self.frame.size.width - ratingView.frame.size.width - ratingView.frame.origin.x, ratingView.frame.size.height)];
    reviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [reviewBtn setTitleColor:[UIColor colorWithRed:145.0/255.0f green:144.0/255.0f blue:144.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    reviewBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0f];
    [[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"reviews"] child:@"incoming"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            [reviewBtn setTitle:[NSString stringWithFormat:@"%lu Reviews", (unsigned long)snapshot.childrenCount] forState:UIControlStateNormal];
            [reviewBtn addTarget:self action:@selector(switchToFeedback) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [reviewBtn setTitle:@"0 Reviews" forState:UIControlStateNormal];
        }
    }];
    [self addSubview:reviewBtn];
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y + imgView.frame.size.height,self.frame.size.width - 2*imgView.frame.origin.x, 10)];
    bioLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0f];
    bioLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
    bioLabel.textAlignment = NSTextAlignmentCenter;
    bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
    bioLabel.numberOfLines = 0;
    bioLabel.text = currentUser.bio;
    [self addSubview:bioLabel];
    
    logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bioLabel.frame.origin.y + bioLabel.frame.size.height + 10.0f, self.frame.size.width, 35.0f)];
    logoutBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    [logoutBtn setTitle:@"Log Out" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logOutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoutBtn];
    
    tabBtnArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<3; i++) {
        
        QpTapButton *tabBtn = [[QpTapButton alloc] initWithFrame:CGRectMake(i*self.frame.size.width/3, logoutBtn.frame.origin.y + logoutBtn.frame.size.height, self.frame.size.width/3, 60) Title:@"Test" Number:0];
        tabBtn.delegate = self;
        
        switch (i) {
            case 0:
                tabBtn.titleLabel.text = @"Inventory";
                [tabBtn setStatusToSelected];
                break;
            case 1:
                tabBtn.titleLabel.text = @"Borrowed";
                [tabBtn setStatusToUnselected];
                break;
            case 2:
                tabBtn.titleLabel.text = @"Lent";
                [tabBtn setStatusToUnselected];
                break;
                
            default:
                break;
        }
        [self addSubview:tabBtn];
        [tabBtnArray addObject:tabBtn];
    }
    
    inventoryItems = [[NSMutableArray alloc] init];
    
    [[[ref child:@"user-items"] child:currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            NSMutableArray *newInventoryItems = [[NSMutableArray alloc] init];
            NSDictionary *retrieveDataDict = snapshot.value;
            for (int i=0; i<[[retrieveDataDict allValues] count]; i++) {
                Item *item = [[Item alloc] initWithDictionary:[[retrieveDataDict allValues] objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
                [newInventoryItems addObject:item];
            }
            
            inventoryItems = newInventoryItems;
            [inventoryTable reloadData];
            [self countTransactionNum];
            [self updateTabButtonNumber];
        }else{
            NSLog(@"Snapshot Not Exist in users-items of ProfileView.");
        }
    }];
    
    CGFloat inventoryPositionY = [[tabBtnArray objectAtIndex:0] frame].origin.y + [[tabBtnArray objectAtIndex:0] frame].size.height;
    
    tabIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, inventoryPositionY-3, self.frame.size.width/3, 3)];
    tabIndicator.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    tabIndicator.layer.cornerRadius = 1.5f;
    [self addSubview:tabIndicator];
    
    inventoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, inventoryPositionY, self.frame.size.width, self.frame.size.height - inventoryPositionY - 65.0f)];
    inventoryTable.delegate = self;
    inventoryTable.dataSource = self;
    inventoryTable.layoutMargins = inventoryTable.separatorInset = UIEdgeInsetsZero;
    [self addSubview:inventoryTable];
    currentTableTitle = @"Inventory";
    
    borrowTransTable = [[QpTransTableView alloc] initWithFrame:inventoryTable.frame];
    borrowTransTable.backgroundColor = [UIColor whiteColor];
    borrowTransTable.controllerDelegate = self;
    borrowTransTable.simplified = YES;
    
    lendTransTable = [[QpTransTableView alloc] initWithFrame:inventoryTable.frame];
    lendTransTable.backgroundColor = [UIColor whiteColor];
    lendTransTable.controllerDelegate = self;
    lendTransTable.simplified = YES;
    
    [[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        
        if (snapshot.exists){
            
            NSMutableArray *newBorrows = [[NSMutableArray alloc] init];
            NSMutableArray *newLends = [[NSMutableArray alloc] init];
            
            NSDictionary *retrieveDataDict = snapshot.value;
            
            NSLog(@"all targetUsers: %@", retrieveDataDict.allKeys);
            
            for (int i=0; i<retrieveDataDict.allKeys.count; i++) {
                [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:[retrieveDataDict.allKeys objectAtIndex:i]] child:@"items"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
                    if (snapshot.exists) {
                        NSDictionary *requestDic = snapshot.value;
                        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:requestDic.allValues];
                        for (int j=0; j<requests.count; j++) {
                            NSMutableDictionary *request = [requests objectAtIndex:j];
                            [request setObject:[requestDic.allKeys objectAtIndex:j] forKey:@"key"];
                            
                            if ([[request objectForKey:@"borrower"] isEqualToString:appDelegate.currentUser.uid]) {
                                [request setValue:[request objectForKey:@"lender"] forKey:@"targetUID"];
                                [request setValue:@"Borrowed" forKey:@"direction"];
                                [newBorrows addObject:request];
                                NSLog(@"???%@",request);
                            }else if ([[request objectForKey:@"lender"] isEqualToString:appDelegate.currentUser.uid]){
                                [request setObject:[request objectForKey:@"borrower"] forKey:@"targetUID"];
                                [request setObject:@"Lent" forKey:@"direction"];
                                [newLends addObject:request];
                                NSLog(@"###%@",request);
                            }
                            
                        }
                        
                        NSLog(@"New Borrows: %@", newBorrows);
                        NSLog(@"New Lends: %@", newLends);
                        
                        borrowTransTable.tableData = newBorrows;
                        lendTransTable.tableData = newLends;
                        
                        [borrowTransTable sortCells];
                        [lendTransTable sortCells];
                        
                        [borrowTransTable reloadData];
                        [lendTransTable reloadData];
                        [self updateTabButtonNumber];
                        
                    }
                    
                }];
            }
            
        }else{
             NSLog(@"Snapshot Not Exist in chats of ProfileView.");
        }
    }];
    
}

- (void)switchToFeedback
{
    [self.delegate SwitchToFeedbackView];
}

- (void)logOutBtnClicked
{
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (!error)
    {
        NSLog(@"LOG OUT");
        [appDelegate resetBatchToken];
        [self.delegate SwitchToSignInView];
        //[self removeFromSuperview];
    }else{
        [self.delegate DisplayAlertWithTitle:@"Error" Message:[error localizedDescription]];
    }
}

#pragma EditProfileDelegate
- (void)updateProfileView
{
    bioLabel.text = appDelegate.currentUser.bio;
    nameLabel.text = appDelegate.currentUser.name;
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inventoryItems.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [inventoryItems objectAtIndex:indexPath.row];
    
    InventoryTableCell *cell = (InventoryTableCell *)[tableView dequeueReusableCellWithIdentifier:@"InventoryTableCell"];
    
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InventoryTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.itemNameLabel.text = item.title;
    cell.itemRentLabel.text = [NSString stringWithFormat:@"$%.2f/Day", item.rentDay];//This need to be changed to rent per day later.
    cell.itemTransNumberLabel.text = [NSString stringWithFormat:@"Transactions: %d", item.transCount];
    [cell.itemImgView loadImageFromURL:item.photo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did Select Inventory Cell At Row: %d", indexPath.row);
    
    Item *item = [inventoryItems objectAtIndex:indexPath.row];
    [self.delegate SwitchToItemInfoFromProfileWithItem:item];
}

- (void)inventoryBtnClicked
{
    if (![inventoryTable isDescendantOfView:self]) {
        [self addSubview:inventoryTable];
    }else{
        [self bringSubviewToFront:inventoryTable];
    }
    currentTableTitle = @"Inventory";
    [self highlightTabButtonWithIndex:0];
}

- (void)borrowTransBtnClicked
{
    if (![borrowTransTable isDescendantOfView:self]) {
        [self addSubview:borrowTransTable];
    }else{
        [self bringSubviewToFront:borrowTransTable];
    }
    currentTableTitle = @"BorrowTrans";
    [self highlightTabButtonWithIndex:1];
}

- (void)lendTransBtnClicked
{
    if (![lendTransTable isDescendantOfView:self]) {
        [self addSubview:lendTransTable];
    }else{
        [self bringSubviewToFront:lendTransTable];
    }
    currentTableTitle = @"LendTrans";
    [self highlightTabButtonWithIndex:2];
}

- (void)highlightTabButtonWithIndex:(int)index
{
    for (int i=0; i<tabBtnArray.count; i++) {
        QpTapButton *tabBtn = [tabBtnArray objectAtIndex:i];
        if (i == index) {
            [tabBtn setStatusToSelected];
            tabIndicator.frame = CGRectMake(tabBtn.frame.origin.x, tabIndicator.frame.origin.y, tabIndicator.frame.size.width, tabIndicator.frame.size.height);
        }else{
            [tabBtn setStatusToUnselected];
        }
        
    }
}

- (void)countTransactionNum
{
    [[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"transactions"] child:@"outgoing"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            NSLog(@"!%@", retrieveDataDict);
            
            for (int i=0; i<[retrieveDataDict allValues].count; i++) {
                NSString *itemID = [[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"iID"];
                for (int j=0; j<inventoryItems.count; j++) {
                    Item *item = [inventoryItems objectAtIndex:j];
                    if ([itemID isEqualToString:item.key]) {
                        item.transCount += 1;
                        NSLog(@"%@", itemID);
                    }
                }
            }
        }else{
            NSLog(@"Snapshot Not Exist in users-detail->currentUserUID->transactions->outgoing of ProfileView.");
        }
        
    }];
}

- (void)updateTabButtonNumber
{
    for (int i=0; i<tabBtnArray.count; i++) {
        QpTapButton *tabBtn = [tabBtnArray objectAtIndex:i];
        if (i == 0) {
            [tabBtn setNumber:inventoryItems.count];
        }else if (i == 1){
            [tabBtn setNumber:borrowTransTable.tableData.count];
        }else if (i == 2){
            [tabBtn setNumber:lendTransTable.tableData.count];
        }
        
    }
}

#pragma QpTransTableDelegate
- (void)SwitchToCheckoutViewWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo
{
    [self.delegate SwitchToCheckoutViewFromProfileWithPrice:price ItemInfo:itemInfo];
}

- (void)SwitchToReviewViewForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID
{
    [self.delegate SwitchToReviewViewFromProfileForItem:itemKey TargetUID:targetUID];
}

- (void)SwitchToInvoiceViewForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID
{
    [self.delegate SwitchToInvoiceViewFromProfileForItem:itemKey TargetUID:targetUID];
}

#pragma QpTabButtonDelegate
- (void)ClickQpTabButton:(QpTapButton *)button
{
    if (button == [tabBtnArray objectAtIndex:0]) {
        [self inventoryBtnClicked];
    }else if (button == [tabBtnArray objectAtIndex:1]) {
        [self borrowTransBtnClicked];
    }else{
        [self lendTransBtnClicked];
    }
}

@end
