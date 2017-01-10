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
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/1.3f)];
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
        
        if (![item.uid isEqualToString:appDelegate.currentUser.uid]){
            textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, infoLabel.frame.origin.y+infoLabel.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 44.0*3) Data:[NSArray arrayWithObjects:@[@"Starts", @"", [NSNumber numberWithInteger:HORIZONTAL_DATEPICKER_TYPE]], @[@"Ends", @"", [NSNumber numberWithInteger:HORIZONTAL_DATEPICKER_TYPE]], @[@"Total", @"", [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]], nil]];
            textTableView.scrollDelegate = self;
            [scrollView addSubview:textTableView];
            
            bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y + textTableView.frame.size.height, self.view.frame.size.width, self.view.frame.size.width/7.5f)];
            [bookBtn setTitle:@"BOOK" forState:UIControlStateNormal];
            
        }else{
            bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, infoLabel.frame.origin.y + infoLabel.frame.size.height + 10.0f, self.view.frame.size.width, self.view.frame.size.width/7.5f)];
            [bookBtn setTitle:@"EDIT" forState:UIControlStateNormal];
        }
        
        bookBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        bookBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:16.0f];
        [bookBtn addTarget:self action:@selector(SendBookRequest) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:bookBtn];
        
        currentScrollContentSize = CGSizeMake(self.view.frame.size.width, bookBtn.frame.origin.y + bookBtn.frame.size.height + 64.0f);
        scrollView.contentSize = currentScrollContentSize;
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

//Need to load item image in this view
- (void)loadImageFromURL:(NSURL *)photoURL
{
    imageView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //Background Thread --- Loading images.
        NSData *imgData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Run UI Updates
            imageView.image = [self thumbnailForImage:imgData];
            
        });
    });
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


- (void)SendBookRequest{
    
    if ([lenderUID isEqualToString: appDelegate.currentUser.uid])
    {
        [bookBtn setTitle:@"EDIT" forState:UIControlStateNormal];
        NSLog(@"EDIT ITEM.");
    }else{
        [bookBtn setTitle:@"BOOK" forState:UIControlStateNormal];
        NSLog(@"BOOK %@ FROM %@!", nameLabel.text, lender);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d MMM yyyy"];
        NSString *rentRange = [NSString stringWithFormat:@"%@ to %@", [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]];
        NSLog(@"RENT RANGE: %@", rentRange);
        
        ConfirmViewController *confirmController = [[ConfirmViewController alloc] initWithItem:self.currentItem RentDay:rentDay TotalPrice:rentalPrice RentRange:rentRange];
        [self.navigationController pushViewController:confirmController animated:YES];
    }
}

- (void)SwitchToLenderProfile
{
    LenderProfileViewController *lenderProfileController = [[LenderProfileViewController alloc] initWithLenderUID:currentItem.uid];
    [self.navigationController pushViewController:lenderProfileController animated:YES];
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
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
            rentDay = components.day;
            rentalPrice = components.day *priceView.rentalDay;
            NSLog(@"Rent for :%d Days", rentDay);
            NSLog(@"Rent Total: %f", rentalPrice);
            
            TextTableCell *totalPriceCell = [textTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            totalPriceCell.contentTextView.text = [NSString stringWithFormat:@"$ %.2f", components.day * priceView.rentalDay];
            [totalPriceCell textViewDidChange:totalPriceCell.contentTextView];
        }else{
            NSLog(@"No startDate or endDate");
        }
    }
    
}

@end
