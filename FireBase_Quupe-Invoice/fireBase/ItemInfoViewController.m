//
//  ItemInfoViewController.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ItemInfoViewController.h"

@import Batch;
#import "quupe-Swift.h"

@interface ItemInfoViewController ()
{
    AppDelegate *appDelegate;
    QpTableView *textTableView;
    CGSize currentScrollContentSize;
    
    NSDate *startDate;
    NSDate *endDate;
    int rentDay;
    float rentalPrice;
    
    QpLenderView *lenderView;
    UILabel *infoTitleLabel;
    
    UILabel *reviewerNameLabel;
    UILabel *newestReviewLabel;
    
    BOOL transactable;
    UIButton *reviewBtn;
    NSMutableArray *itemReviews;
}

@end

@implementation ItemInfoViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize nameLabel, infoLabel;
@synthesize lender;
@synthesize lenderUID, itemKey;
@synthesize bookBtn;
@synthesize ref;
@synthesize currentItem;
@synthesize priceView;

- (id)initWithItem:(Item *)item
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        currentItem = item;
        lender = item.lender;
        lenderUID = item.uid;
        itemKey = item.key;
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        ref = [[FIRDatabase database] reference];
        
        self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.scrollEnabled = YES;
        
        [self.view addSubview:scrollView];
        
        imageView = [[QpAsyncImage alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/1.3f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [scrollView addSubview:imageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, imageView.frame.origin.y + imageView.frame.size.height + 10.0f, self.view.frame.size.width - 2*10.0f, 24.0f)];
        nameLabel.text = item.title;
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];//SFUIText-Regular, SFUIText-Medium
        nameLabel.textColor = [UIColor colorWithRed:72.0f/255.0f green:72.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
        [scrollView addSubview:nameLabel];
        
        //In this view, the prices of an item should be read from firebase.
        //For now, since the missing info of prices in many item nodes, using calculation in priceView to make sure prices show properly. Need to rewrite this part later.
        priceView = [[QpPriceView alloc] initWithFrame:CGRectMake(0, self.nameLabel.frame.origin.y+self.nameLabel.frame.size.height + 10, [[UIScreen mainScreen] bounds].size.width, 64)];
        [priceView calculateQuupePriceForItem:item];
        [scrollView addSubview:priceView];
        
        if (![item.uid isEqualToString:appDelegate.currentUser.uid]) {
            lenderView = [[QpLenderView alloc] initWithFrame:CGRectMake(10.0f, priceView.frame.origin.y+priceView.frame.size.height, self.view.frame.size.width - 2*10.0f, 68.0f) LenderName:item.lender LenderUID:item.uid];
            lenderView.delegate = self;
            [lenderView.ratingView roundRating:item.starCount];
            [scrollView addSubview:lenderView];
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SwitchToLenderProfile)];
            tapRecognizer.delegate = self;
            [lenderView addGestureRecognizer:tapRecognizer];
            
            infoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, lenderView.frame.origin.y+lenderView.frame.size.height, self.view.frame.size.width - 2*10.0f, 20.0f)];
            
        }else{
            lenderView = nil;
            infoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, priceView.frame.origin.y+priceView.frame.size.height, self.view.frame.size.width - 2*10.0f, 20.0f)];
        }
        
        infoTitleLabel.text = @"Description";
        infoTitleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        infoTitleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        //infoTitleLabel.backgroundColor = [UIColor greenColor];
        [scrollView addSubview:infoTitleLabel];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, infoTitleLabel.frame.origin.y+infoTitleLabel.frame.size.height, self.view.frame.size.width - 2*10.0f, 0.25f*self.view.frame.size.width)];
        infoLabel.text = item.info;
        infoLabel.numberOfLines = 0;
        infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [infoLabel sizeToFit];
        infoLabel.frame = CGRectMake(infoLabel.frame.origin.x, infoLabel.frame.origin.y, self.view.frame.size.width - 2*10.0f, infoLabel.frame.size.height);
        infoLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        infoLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        //infoLabel.backgroundColor = [UIColor greenColor];
        [scrollView addSubview:infoLabel];
        
        UILabel *newestReviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, infoLabel.frame.origin.y+infoLabel.frame.size.height + 10.0f, [[UIScreen mainScreen] bounds].size.width - 2*10.0f, 20.0f)];
        newestReviewTitleLabel.text = @"Reviews";
        newestReviewTitleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        newestReviewTitleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        [scrollView addSubview:newestReviewTitleLabel];
        
        reviewerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, newestReviewTitleLabel.frame.origin.y+newestReviewTitleLabel.frame.size.height, [[UIScreen mainScreen] bounds].size.width - 2*10.0f, 20.0f)];
        reviewerNameLabel.text = @"";
        reviewerNameLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:14.0f];
        reviewerNameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        [scrollView addSubview:reviewerNameLabel];
        
        newestReviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, reviewerNameLabel.frame.origin.y+reviewerNameLabel.frame.size.height, [[UIScreen mainScreen] bounds].size.width - 2*10.0f, 40.0f)];
        newestReviewLabel.text = @"Loading Reviews...";
        newestReviewLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        newestReviewLabel.textColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0f];
        newestReviewLabel.numberOfLines = 0;
        newestReviewLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [scrollView addSubview:newestReviewLabel];
        
        reviewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, newestReviewLabel.frame.origin.y+newestReviewLabel.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
        reviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        reviewBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        [reviewBtn setTitleColor:[UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
        reviewBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:14.0f];
        [self CountReviews];
        [scrollView addSubview:reviewBtn];
        
        [self DisplayDatePicker];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Item Details";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSLog(@"Item Info Did Load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)DisplayDatePicker
{
    if (![lenderUID isEqualToString:appDelegate.currentUser.uid]){
        textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, reviewBtn.frame.origin.y+reviewBtn.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 44.0*3) Data:[NSArray arrayWithObjects:@[@"Starts", @"", [NSNumber numberWithInteger:HORIZONTAL_DATEPICKER_TYPE]], @[@"Ends", @"", [NSNumber numberWithInteger:HORIZONTAL_DATEPICKER_TYPE]], @[@"Total", @"", [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]], nil]];
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
        
        TextTableCell *totalPriceCell = [textTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        totalPriceCell.contentTextView.editable = NO;
        
        bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y + textTableView.frame.size.height, self.view.frame.size.width, self.view.frame.size.width/7.5f)];
        [bookBtn setTitle:@"BOOK" forState:UIControlStateNormal];
        
    }else{
        bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, reviewBtn.frame.origin.y + reviewBtn.frame.size.height + 10.0f, self.view.frame.size.width, self.view.frame.size.width/7.5f)];
        [bookBtn setTitle:@"EDIT" forState:UIControlStateNormal];
    }
    
    bookBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    bookBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:16.0f];
    [bookBtn addTarget:self action:@selector(SendBookRequest) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bookBtn];
    
    currentScrollContentSize = CGSizeMake(self.view.frame.size.width, bookBtn.frame.origin.y + bookBtn.frame.size.height + 64.0f);
    scrollView.contentSize = currentScrollContentSize;
    
    transactable = NO;
}

//Need to load item image in this view
- (void)loadImageFromURL:(NSURL *)photoURL
{
    [imageView loadImageFromURL:photoURL];
}


- (void)SendBookRequest{
    
    if ([lenderUID isEqualToString: appDelegate.currentUser.uid])
    {
        [bookBtn setTitle:@"EDIT" forState:UIControlStateNormal];
        NSLog(@"EDIT ITEM.");
    }else{
        
        if (transactable) {
            [bookBtn setTitle:@"BOOK" forState:UIControlStateNormal];
            NSLog(@"BOOK %@ FROM %@!", nameLabel.text, lender);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"d MMM yyyy"];
            NSString *rentRange = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]];
            NSLog(@"RENT RANGE: %@", rentRange);
            
            ConfirmViewController *confirmController = [[ConfirmViewController alloc] initWithItem:self.currentItem RentDay:rentDay TotalPrice:rentalPrice RentRange:rentRange RentalPerDay:priceView.rentalDay];
            
            [self.navigationController pushViewController:confirmController animated:YES];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Your rental info contains errors or is not completed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)SwitchToLenderProfile
{
    LenderProfileViewController *lenderProfileController = [[LenderProfileViewController alloc] initWithLenderUID:currentItem.uid];
    [self.navigationController pushViewController:lenderProfileController animated:YES];
}

- (void)SwitchToLoadReviews
{
    NSLog(@"Load More Reviews");
    FeedbackViewController *feedbackController = [[FeedbackViewController alloc] initWithItemKey:self.itemKey];
    feedbackController.itemReviews = itemReviews;
    [self.navigationController pushViewController:feedbackController animated:YES];
}

- (void)CountReviews
{
    [[[[[ref child:@"users-detail"] child:lenderUID] child:@"reviews"] child:@"incoming"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            NSArray *reviews = [retrieveDataDict allValues];
            
            itemReviews = [[NSMutableArray alloc] init];
            
            for (int i=0; i<reviews.count; i++) {
                NSString *requestKey = [[reviews objectAtIndex:i] objectForKey:@"forItem"];
                
                [[ref child:@"requests"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    if (snapshot.exists) {
                        NSArray *requestKeys = [snapshot.value allKeys];
                        
                        int j=0;
                        
                        while (![[requestKeys objectAtIndex:j] isEqualToString:requestKey] && j<requestKeys.count-1) {
                            j++;
                        }
                        
                        NSString *itemNo = [[[snapshot.value allValues] objectAtIndex:j] objectForKey:@"itemNo"];
                        if ([itemNo isEqualToString:self.itemKey]) {
                            [itemReviews addObject:[reviews objectAtIndex:i]];
                        }
                        if (itemReviews.count > 0) {
                            [reviewBtn setTitle: [NSString stringWithFormat:@"See All Reviews (%lu)", (unsigned long)itemReviews.count] forState:UIControlStateNormal];
                            [reviewBtn addTarget:self action:@selector(SwitchToLoadReviews) forControlEvents:UIControlEventTouchUpInside];
                            
                            [self DisplayNewestReview];
                        }
                        
                    }
                    
                }];
            }
            
        } else {
            newestReviewLabel.text = @"No Reviews.";
            NSLog(@"Snapshot Not Exist in users-detail->uid->reviews->incoming in ItemInfoVC");
        }
    }];
}

- (void)DisplayNewestReview
{
    NSMutableArray *reviewDates = [[NSMutableArray alloc] init];
    for (int i=0; i<itemReviews.count; i++) {
        NSString *time = [[itemReviews objectAtIndex:i] objectForKey:@"time"];
        NSTimeInterval timeInterval = [time doubleValue] / 1000.0f;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
        [reviewDates addObject:date];
    }
    NSLog(@"Review Dates: %@", reviewDates);
    //Arrange the dates in time order.
    int newestReviewIndex = 0;
    for (int j=1; j<reviewDates.count; j++) {
        NSDate *date1 = [reviewDates objectAtIndex:0];
        NSDate *date2 = [reviewDates objectAtIndex:j];
        if ([date1 compare:date2] == NSOrderedAscending) {
            [reviewDates exchangeObjectAtIndex:0 withObjectAtIndex:j];
            newestReviewIndex = j;
        }
    }
    NSLog(@"Ordered Review Dates: %@", reviewDates);
    
    newestReviewLabel.text = [[itemReviews objectAtIndex:newestReviewIndex] objectForKey:@"comments"];
    
    NSString *reviewerUID = [[itemReviews objectAtIndex:newestReviewIndex] objectForKey:@"by"];
    [[[[ref child:@"users-detail"] child:reviewerUID] child:@"name"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            reviewerNameLabel.text = snapshot.value;
        }else {
            NSLog(@"Snapshot Not Exist in users-detail->reviewer in ItemInfoVC");
        }
    }];
    
}

#pragma QpTableViewDelegate
- (void)changeScrollViewContentSizeBy:(CGFloat)tableViewChangedHeight NewTableHeight:(CGFloat)newTableViewHeight
{
    currentScrollContentSize = CGSizeMake(currentScrollContentSize.width, currentScrollContentSize.height - tableViewChangedHeight);
    scrollView.contentSize = currentScrollContentSize;
    
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
    if (cell.type == VERTICAL_DATEPICKER_TYPE || cell.type == HORIZONTAL_DATEPICKER_TYPE) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d (EEE), yyyy"];
        
        NSDate *date = [dateFormatter dateFromString:cell.contentTextView.text];
        NSLog(@"DATE: %@", date);
        
        if ([textTableView indexPathForCell:cell].row == 0) {
            startDate = date;
            NSLog(@"Set Start Date: %@", startDate);
        }else if ([textTableView indexPathForCell:cell].row == 1){
            endDate = date;
            NSLog(@"Set End Date: %@", endDate);
        }else{
            NSLog(@"No Setting for cell index %ld", (long)textTableView.currentIndexPath.row);
        }
        
        if (startDate && endDate) {
            
            if ([startDate compare:endDate] == NSOrderedAscending) {
                //startDate is earlier than endDate
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
                rentDay = components.day;
                rentalPrice = components.day *priceView.rentalDay;
                NSLog(@"Rent for :%d Days", rentDay);
                NSLog(@"Rent Total: %f", rentalPrice);
                
                TextTableCell *totalPriceCell = [textTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                totalPriceCell.contentTextView.text = [NSString stringWithFormat:@"$ %.2f", components.day * priceView.rentalDay];
                totalPriceCell.contentTextView.editable = NO;
                [totalPriceCell textViewDidChange:totalPriceCell.contentTextView];
                
                transactable = YES;
                
            }else {
                if ([startDate compare:endDate] == NSOrderedDescending) {
                    //startDate is later than endDate
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Your rental start date couldn't later than end date." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
                    [alert show];
                }else {
                    //startDate and endDate are the same day.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Your rental start date and end date are the same day. Please ensure that you are borrowing items for at least one day." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
                    [alert show];
                }
                
                rentDay = 0;
                rentalPrice = 0.0f;
                
                TextTableCell *totalPriceCell = [textTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                totalPriceCell.contentTextView.text = @"";
                totalPriceCell.contentTextView.editable = NO;
                [totalPriceCell textViewDidChange:totalPriceCell.contentTextView];
                
                transactable = NO;
            }
            
        }else{
            NSLog(@"No startDate or endDate");
        }
    }
    
}

#pragma QpLenderViewDelegate
- (void)messageLenderWithName:(NSString *)lenderName Icon:(UIImage *)lenderIcon
{
    MessageViewController *msgViewController = [MessageViewController messagesViewController];
    
    msgViewController.navigationItem.title = lenderName;
    msgViewController.targetUID = lenderUID;
    msgViewController.targetIcon = lenderIcon;
    
    msgViewController.senderId = appDelegate.currentUser.uid;
    msgViewController.senderDisplayName = appDelegate.currentUser.name;
    
    msgViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgViewController animated:YES];
}

@end
