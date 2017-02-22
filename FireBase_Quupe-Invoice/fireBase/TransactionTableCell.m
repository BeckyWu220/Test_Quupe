//
//  TransactionTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-05.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "TransactionTableCell.h"
#import "AppDelegate.h"

@interface TransactionTableCell()
{
    QpButton *acceptBtn;
    QpButton *cancelBtn;
    QpButton *payBtn;
    QpButton *rentBtn;
    QpButton *returnBtn;
    QpButton *completeBtn;
    QpButton *reviewBtn;
    
    AppDelegate *appDelegate;
}

@end

@implementation TransactionTableCell

@synthesize delegate;
@synthesize btnView;
@synthesize itemName, itemDirection, directionLabel;
@synthesize itemKey;
@synthesize imgView;
@synthesize targetUID;
@synthesize ref;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    itemName.frame = CGRectMake(itemName.frame.origin.x, itemName.frame.origin.y, 150, 20);
    directionLabel.text = @"";
    //[itemName sizeToFit];
    
    ref = [[FIRDatabase database] reference];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.frame.size.height);
    
    imgView.layer.cornerRadius = 4.0f;
    imgView.clipsToBounds = YES;

    btnView.backgroundColor = [UIColor clearColor];
    
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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)loadButtonsWithItemStatus:(NSString *)itemStatus
{
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
            acceptBtn.frame = CGRectMake(0, 0, btnView.frame.size.width, 28);
            acceptBtn.hidden = NO;
            
            cancelBtn.frame = CGRectMake(0, acceptBtn.frame.size.height+4, btnView.frame.size.width, 28);
            cancelBtn.hidden = NO;
            
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            cancelBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 28);
            cancelBtn.hidden = NO;
        }
        
    }else if ([itemStatus isEqualToString:@"accepted"])
    {
        //Show PayBtn and CancelBtn to Borrower, CancelBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]) {
            cancelBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 28);
            cancelBtn.hidden = NO;
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            payBtn.frame = CGRectMake(0, 0, btnView.frame.size.width, 28);
            payBtn.hidden = NO;
            
            cancelBtn.frame = CGRectMake(0, payBtn.frame.size.height+4, btnView.frame.size.width, 28);
            cancelBtn.hidden = NO;
        }
        
    }else if ([itemStatus isEqualToString:@"paid"])
    {
        //Show RentBtn to Lender, ReportBtn to Borrower
        if ([itemDirection isEqualToString:@"Lent"]){
            rentBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 28);
            rentBtn.hidden = NO;
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            //ReportBtn
        }
        
    }else if ([itemStatus isEqualToString:@"rented"])
    {
        //Show ReturnBtn to Borrower, ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            //ReportBtn
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            returnBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 28);
            returnBtn.hidden = NO;
        }

    }else if ([itemStatus isEqualToString:@"returned"]){
        //Show ReviewBtn to Borrower, CompleteBtn and ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            completeBtn.frame = CGRectMake(0, 20, btnView.frame.size.width, 28);
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//QpButtonDelegate
- (void)ClickQpButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Accept"])
    {
        [self.delegate SetItemStatusTo:@"accepted" ItemKey:itemKey TargetUID:targetUID];
    }
    else if ([title isEqualToString:@"Cancel"])
    {
        [self.delegate SetItemStatusTo:@"cancelled" ItemKey:itemKey TargetUID:targetUID];
    }
    else if ([title isEqualToString:@"Pay"])
    {
        [self.delegate SwitchToCheckoutViewWithCell:self];
    }
    else if ([title isEqualToString:@"Rented"])
    {
        [self.delegate SetItemStatusTo:@"rented" ItemKey:itemKey TargetUID:targetUID];
    }
    else if ([title isEqualToString:@"Returned"])
    {
        [self.delegate SetItemStatusTo:@"returned" ItemKey:itemKey TargetUID:targetUID];
    }
    else if ([title isEqualToString:@"Complete"])
    {
        [self.delegate SetItemStatusTo:@"completed" ItemKey:itemKey TargetUID:targetUID];
    }
    else if ([title isEqualToString:@"Review"])
    {
        [self.delegate SwitchToReviewViewForItem:itemKey TargetUID:targetUID];
    }
}

- (void)createThumbnailIconWithURL:(NSURL *)imgURL
{
    [imgView loadImageFromURL:imgURL];
}

- (void)checkReviewToDisplayReviewBtn
{
    [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:itemKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            if (![retrieveDataDict objectForKey:@"review"] || [[retrieveDataDict objectForKey:@"review"] isEqualToString:@"0"]) {
                //User didn't review for this item yet.
                reviewBtn.frame = CGRectMake(0, 15, btnView.frame.size.width, 28);
                reviewBtn.hidden = NO;
                NSLog(@"Not Reviewed Yet. - TransTable");
            }else{
                NSLog(@"Already Reviewed. - TransTable");
                reviewBtn.hidden = YES;
            }
            
        }else{
            NSLog(@"snapshot doesn't exist in users-detail->uid->chats->targetUID->items");
        }
    }];
}

@end
