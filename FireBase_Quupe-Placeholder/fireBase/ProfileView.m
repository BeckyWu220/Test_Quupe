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
        NSLog(@"CURRENT USER ID: %@", appDelegate.currentUser.uid);
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
        imgView.layer.cornerRadius = imgView.frame.size.width / 2;
        imgView.clipsToBounds = YES;
        //imgView.layer.borderWidth = 3.0f;
        //imgView.layer.borderColor = [UIColor grayColor].CGColor;
        [self addSubview:imgView];
        
        NSString *imgURL = appDelegate.currentUser.imgURL;
        
        if (imgURL)
        {
            imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                //NSLog(@"DISPATCH");
                //Background Thread --- Loading images.
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //Run UI Updates
                    //imgView.image = [UIImage imageWithData:imgData];
                    imgView.image = [self thumbnailForImage:imgData];
                    NSLog(@"Profile Loaded.");
                    
                });
            });
        }else{
            imgView.image = [UIImage imageNamed:@"default-profile.jpg"];
        }
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, imgView.frame.origin.y, self.frame.size.width - imgView.frame.size.width - 3*10.0f, 25.0f)];
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
        nameLabel.textColor = [UIColor colorWithRed:72.0f/255.0f green:72.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
        nameLabel.text = appDelegate.currentUser.name;
        [self addSubview:nameLabel];
        
        QpRatingView *ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10.0f, 12.0f*5, 12.0f) Rating:appDelegate.currentUser.rating];
        [self addSubview:ratingView];
        
        bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y + imgView.frame.size.height + 10.0f,self.frame.size.width - 2*imgView.frame.origin.x, 30)];
        bioLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0f];
        bioLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        bioLabel.textAlignment = NSTextAlignmentCenter;
        bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
        bioLabel.numberOfLines = 0;
        bioLabel.text = appDelegate.currentUser.bio;
        [self addSubview:bioLabel];
        
        logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bioLabel.frame.origin.y + bioLabel.frame.size.height + 10.0f, self.frame.size.width, 35.0f)];
        logoutBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [logoutBtn setTitle:@"Log Out" forState:UIControlStateNormal];
        [logoutBtn addTarget:self action:@selector(logOutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:logoutBtn];
        
        tabBtnArray = [[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++) {

            QpTapButton *tabBtn = [[QpTapButton alloc] initWithFrame:CGRectMake(i*self.frame.size.width/3, logoutBtn.frame.origin.y + logoutBtn.frame.size.height, self.frame.size.width/3, 60) Title:@"Test" Number:1];
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
        
        [[[ref child:@"user-items"] child:appDelegate.currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
        }];
        
        CGFloat inventoryPositionY = [[tabBtnArray objectAtIndex:0] frame].origin.y + [[tabBtnArray objectAtIndex:0] frame].size.height;
        
        tabIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, inventoryPositionY-3, self.frame.size.width/3, 3)];
        tabIndicator.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        tabIndicator.layer.cornerRadius = 1.5f;
        [self addSubview:tabIndicator];
        
        inventoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, inventoryPositionY, self.frame.size.width, self.frame.size.height - inventoryPositionY)];
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
        
        
       [[ref child:@"requests"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
           
           NSMutableArray *newBorrows = [[NSMutableArray alloc] init];
           NSMutableArray *newLends = [[NSMutableArray alloc] init];
           
           NSDictionary *retrieveDataDict = snapshot.value;
           
           for (int i=0; i<[retrieveDataDict allValues].count; i++) {
               
               [[[retrieveDataDict allValues] objectAtIndex:i] setObject:[[retrieveDataDict allKeys] objectAtIndex:i] forKey:@"key"];//Add itemKey to item info dictionary.
               
               if ([[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"borrower"] isEqualToString:appDelegate.currentUser.uid]) {
                   
                   [[[retrieveDataDict allValues] objectAtIndex:i] setObject:[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"lender"] forKey:@"targetUID"];
                   
                   [[[retrieveDataDict allValues] objectAtIndex:i] setObject:@"Borrowed" forKey:@"direction"];
                   
                   [newBorrows addObject:[[retrieveDataDict allValues] objectAtIndex:i]];
                   
               }else if ([[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"lender"] isEqualToString:appDelegate.currentUser.uid]){
                   
                   [[[retrieveDataDict allValues] objectAtIndex:i] setObject:[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"borrower"] forKey:@"targetUID"];
                   
                   [[[retrieveDataDict allValues] objectAtIndex:i] setObject:@"Lent" forKey:@"direction"];
                   
                   [newLends addObject:[[retrieveDataDict allValues] objectAtIndex:i]];
               }
           }
           
           borrowTransTable.tableData = newBorrows;
           lendTransTable.tableData = newLends;
           
           [borrowTransTable sortCells];
           [lendTransTable sortCells];
           
           [borrowTransTable reloadData];
           [lendTransTable reloadData];
           [self updateTabButtonNumber];
       }];
    
        
        
    }
    return self;
}

- (UIImage *)thumbnailForImage:(NSData *)imgData
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imgData, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,(NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:300],(NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,});
    CFRelease(source);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
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
    [self createThumbnailIconWithURL:item.photo ForImageView:cell.itemImgView];
    
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
        NSDictionary *retrieveDataDict = snapshot.value;
        NSLog(@"%@", retrieveDataDict);
        
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

- (void)SwitchToReviewView
{
    [self.delegate SwitchToReviewViewFromProfile];
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

- (void)createThumbnailIconWithURL:(NSURL *)imgURL ForImageView:(UIImageView *)imgView
{
    imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Background Thread --- Loading images.
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Run UI Updates
            imgView.image = [self thumbnailForImage:imgData];
        });
    });
}

@end
