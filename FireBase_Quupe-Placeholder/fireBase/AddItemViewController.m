//
//  AddItemViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-17.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "AddItemViewController.h"

@interface AddItemViewController ()
{
    QpPriceView *priceView;
    QpTableView *textTableView;
    CGSize currentScrollContentSize;
    UIButton *addBtn;
    
    AppDelegate *appDelegate;
    
    NSString *itemCategory;
    NSString *itemCondition;
    NSString *itemTitle;
    NSString *itemOriginalPrice;
    NSData *itemPhotoData;
    NSURL *itemPhotoDownloadURL;
}

@end

@implementation AddItemViewController

@synthesize currentItem;
@synthesize scrollView;
@synthesize ref, imagesRef;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        appDelegate = [[UIApplication sharedApplication] delegate];
        ref = [[FIRDatabase database] reference];
        imagesRef = [[[FIRStorage storage] referenceForURL:@"gs://quupe-restore.appspot.com"] child:@"images"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Add Item 2";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}

- (void)updateItemInfoWithTitle:(NSString *)title OriginalPrice:(NSString *)oPrice Category:(NSString *)category Condition:(NSString *)condition PhotoData:(NSData *)photoData
{
    [self updatePriceViewWithOriginalPrice:[oPrice floatValue] Category:category];
    itemTitle = title;
    itemOriginalPrice = oPrice;
    itemCategory = category;
    itemCondition = condition;
    itemPhotoData = photoData;
}

- (void)updatePriceViewWithOriginalPrice:(float)oPrice Category:(NSString *)category
{
    NSLog(@"OriginalPrice: %f, Category: %@", oPrice, category);
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    currentScrollContentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height+64.0f + 100.0f);
    scrollView.contentSize = currentScrollContentSize;
    
    [self.view addSubview:scrollView];
    
    priceView = [[QpPriceView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 64)];
    [priceView calculateQuupePriceWithOriginalPrice:oPrice Category:category];
    [scrollView addSubview:priceView];
    
    textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, priceView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - priceView.frame.size.height) Data:[NSArray arrayWithObjects:@[@"Description", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_TEXT_TYPE]], @[@"Preference", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_UIPICKER_TYPE], @[@"Pick Up On Spot", @"Through Mail"]], nil]];
    textTableView.scrollDelegate = self;
    [scrollView addSubview:textTableView];
    
    addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y+textTableView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
    addBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    [addBtn setTitle:@"Add" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addBtn];

}

- (void)clickAddBtn
{
    NSLog(@"Click Add Btn");
    [self addItemAndSaveToFirebase];
}

- (void)back:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addItemAndSaveToFirebase
{
    //upload image photo
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    FIRStorageUploadTask *uploadTask = [[imagesRef child:[NSString stringWithFormat:@"%lld.jpg",(long long)([[NSDate date] timeIntervalSince1970] * 1000.0)]] putData:itemPhotoData metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error){
        if (error){
            NSLog(@"An Error Occurred While Uploading Image to Firebase");
            return;
        }else{
            itemPhotoDownloadURL = metadata.downloadURL;
            NSLog(@"ITEM PHOTO DOWNLOAD URL: %@", itemPhotoDownloadURL);
            [self saveItemInfoToFirebase];
        }
    }];
}

- (void)saveItemInfoToFirebase
{
    //save item info to Firebase
    NSString *key = [[ref child:@"items"] childByAutoId].key;
    NSLog(@"ADD %@", key);
    
    NSString *itemInfo = [[[[textTableView stopEditingAndReturnCellData] objectAtIndex:0] allValues] objectAtIndex:0];
    NSLog(@"Item Info: %@", itemInfo);
    
    NSDictionary *post = @{@"category": itemCategory,
                           @"condition": itemCondition,
                           @"info": itemInfo,
                           @"lender": appDelegate.currentUser.name,
                           @"oPrice": itemOriginalPrice,
                           @"photo": [NSString stringWithFormat:@"%@", itemPhotoDownloadURL],
                           @"rentDay": [NSString stringWithFormat:@"%.2f", priceView.rentalDay],
                           @"starCount": @"default",
                           @"title": itemTitle,
                           @"uid": appDelegate.currentUser.uid};
    
    [[[ref child:@"items"] child:key] setValue:post];
    
    [[[[ref child:@"user-items"] child:appDelegate.currentUser.uid] child:key] setValue:post];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You've post your item successfully" delegate:self cancelButtonTitle:@"Cool" otherButtonTitles:nil];
    [alert show];
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
    
    //Update following UI position
    NSLog(@"Adjust Following Elements.");
    addBtn.frame = CGRectMake(0, textTableView.frame.origin.y+newTableViewHeight, [[UIScreen mainScreen] bounds].size.width, 35.0f);
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
    //Do nothing.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.delegate resetViewController];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
