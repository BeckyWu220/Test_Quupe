//
//  TransactionTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-05.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "TransactionTableCell.h"

@interface TransactionTableCell()
{
    QpButton *acceptBtn;
    QpButton *cancelBtn;
    QpButton *payBtn;
    QpButton *rentBtn;
    QpButton *returnBtn;
    QpButton *completeBtn;
    QpButton *reviewBtn;
}

@end

@implementation TransactionTableCell

@synthesize delegate;
@synthesize btnView;
@synthesize itemName, itemDirection, directionLabel;
@synthesize itemKey;
@synthesize imgView;
@synthesize targetUID;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    itemName.frame = CGRectMake(itemName.frame.origin.x, itemName.frame.origin.y, 150, 20);
    directionLabel.text = @"";
    //[itemName sizeToFit];
    
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.frame.size.height);
    
    imgView.layer.cornerRadius = 4.0f;
    imgView.clipsToBounds = YES;

    btnView.backgroundColor = [UIColor clearColor];
}

- (void)loadButtonsWithItemStatus:(NSString *)itemStatus
{
    [acceptBtn removeFromSuperview];
    [cancelBtn removeFromSuperview];
    [payBtn removeFromSuperview];
    [rentBtn removeFromSuperview];
    [returnBtn removeFromSuperview];
    [completeBtn removeFromSuperview];
    [reviewBtn removeFromSuperview];
    
    if ([itemStatus isEqualToString:@"requested"])
    {
        //Show AcceptBtn and CancelBtn to Lender, CancelBtn to Borrower
        if ([itemDirection isEqualToString:@"Lent"])
        {
            acceptBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 0, btnView.frame.size.width, 28) Title:@"Accept"];
            acceptBtn.delegate = self;
            [btnView addSubview:acceptBtn];
            
            cancelBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, acceptBtn.frame.size.height+4, btnView.frame.size.width, 28) Title:@"Cancel"];
            cancelBtn.delegate = self;
            [btnView addSubview:cancelBtn];
            
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            cancelBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Cancel"];
            cancelBtn.delegate = self;
            [btnView addSubview:cancelBtn];
        }
        
    }else if ([itemStatus isEqualToString:@"accepted"])
    {
        //Show PayBtn and CancelBtn to Borrower, CancelBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]) {
            cancelBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Cancel"];
            cancelBtn.delegate = self;
            [btnView addSubview:cancelBtn];
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            payBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 0, btnView.frame.size.width, 28) Title:@"Pay"];
            payBtn.delegate = self;
            [btnView addSubview:payBtn];
            
            cancelBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, payBtn.frame.size.height+4, btnView.frame.size.width, 28) Title:@"Cancel"];
            cancelBtn.delegate = self;
            [btnView addSubview:cancelBtn];
        }
        
    }else if ([itemStatus isEqualToString:@"paid"])
    {
        //Show RentBtn to Lender, ReportBtn to Borrower
        if ([itemDirection isEqualToString:@"Lent"]){
            rentBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Rented"];
            rentBtn.delegate = self;
            [btnView addSubview:rentBtn];
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            //ReportBtn
        }
        
    }else if ([itemStatus isEqualToString:@"rented"])
    {
        //Show ReturnBtn to Borrower, ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            //ReportBtn
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            returnBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Returned"];
            returnBtn.delegate = self;
            [btnView addSubview:returnBtn];
        }

    }else if ([itemStatus isEqualToString:@"returned"]){
        //Show ReviewBtn to Borrower, CompleteBtn and ReportBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            completeBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Complete"];
            completeBtn.delegate = self;
            [btnView addSubview:completeBtn];
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            reviewBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Review"];
            reviewBtn.delegate = self;
            [btnView addSubview:reviewBtn];
        }
        
    }else if ([itemStatus isEqualToString:@"completed"]){
        //Show ReviewBtn to Lender
        if ([itemDirection isEqualToString:@"Lent"]){
            reviewBtn = [[QpButton alloc] initWithFrame:CGRectMake(0, 15, btnView.frame.size.width, 28) Title:@"Review"];
            reviewBtn.delegate = self;
            [btnView addSubview:reviewBtn];
        }else if ([itemDirection isEqualToString:@"Borrowed"]) {
            //Detect if the borrower has reviewed to show rating or reviewBtn. Need to implement later.
        }
        
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
        [self.delegate SwitchToReviewView];
    }
}

- (void)createThumbnailIconWithURL:(NSURL *)imgURL
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

- (UIImage *)thumbnailForImage:(NSData *)imgData
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imgData, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,(NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:60],(NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,});
    CFRelease(source);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

@end
