//
//  PostItemViewController.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-13.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "PostItemViewController.h"

@interface PostItemViewController ()
{
    NSArray *conditionPickerData;
    AppDelegate *appDelegate;
    NSURL *referenceUrl;
    NSData *imgData;
    
    QpTableView *textTableView;
    CGSize currentScrollContentSize;
    UIButton *calculateBtn;
    NSArray *originalTextTableData;
}
@end

@implementation PostItemViewController

@synthesize albumBtn, imgPickerController;
@synthesize imgView;
@synthesize ref,imagesRef;
@synthesize condition, category;
@synthesize scrollView;

- (id)init
{
    self = [super init];
    if (self) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Add Item";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    currentScrollContentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+64.0f);
    scrollView.contentSize = currentScrollContentSize;
    [self.view addSubview:scrollView];
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*245/375)];
    imgView.image = [UIImage imageNamed:@"default-upload"];
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPicture)];
    tapRecognizer.delegate = self;
    [imgView addGestureRecognizer:tapRecognizer];
    [scrollView addSubview:imgView];
    
    originalTextTableData = [NSArray arrayWithObjects:@[@"Name", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_TEXT_TYPE]], @[@"Price", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_MONEY_TYPE]],  @[@"Condition", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_UIPICKER_TYPE], @[@"New", @"Fair", @"Old"]], @[@"Category", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_UIPICKER_TYPE], @[@"Electronics", @"Fun and Recreation", @"Outdoor and Adventure", @"Home, Garden and Tools", @"Others"]], @[@"Bought In", @"Not Specified", [NSNumber numberWithInteger:VERTICAL_UIPICKER_TYPE], @[@"2017", @"2016", @"2015", @"2014", @"2013", @"2012", @"2011", @"2010", @"2009", @"2008", @"2007", @"2006", @"Older"]], nil];
    
    textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, imgView.frame.origin.y+imgView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - imgView.frame.size.height) Data: originalTextTableData];
    textTableView.scrollDelegate = self;
    [scrollView addSubview:textTableView];
    
    calculateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y + textTableView.frame.size.height, self.view.frame.size.width, 35.0f)];
    [calculateBtn setTitle:@"Calculate" forState:UIControlStateNormal];
    calculateBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    [calculateBtn addTarget:self action:@selector(calculateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:calculateBtn];
    
    ref = [[FIRDatabase database] reference];
    imagesRef = [[[FIRStorage storage] referenceForURL:@"gs://quupe-restore.appspot.com"] child:@"images"];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSLog(@"SCROLLVIEW: %f", scrollView.contentInset.top);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectPicture
{
    NSLog(@"Image Pick");
    
    imgPickerController = [[UIImagePickerController alloc] init];
    imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPickerController.delegate = self;
    
    [self presentViewController:imgPickerController animated:YES completion:nil];
}

- (IBAction)calculateBtn:(id)sender {
    
    if ([appDelegate.currentUser.uid isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please login first to post your items." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }else
    {
        NSArray *cellData = [textTableView stopEditingAndReturnCellData];
        
        NSString *itemName = [[[cellData objectAtIndex:0] allValues] objectAtIndex:0];
        NSString *itemPrice = [[[cellData objectAtIndex:1] allValues] objectAtIndex:0];
        NSString *itemCondition = [[[cellData objectAtIndex:2] allValues] objectAtIndex:0];
        NSLog(@"Item Condition: %@", itemCondition);
        NSString *itemCategory = [[[cellData objectAtIndex:3] allValues] objectAtIndex:0];
        
        if ([itemName isEqualToString:@""] || [itemName isEqualToString:@"Not Specified"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please input the item name." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
            [alert show];
        }else if ([itemPrice isEqualToString:@""] || [itemPrice isEqualToString:@"Not Specified"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please input the item price." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
            [alert show];
        }else if ([itemCondition isEqualToString:@"Not Specified"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please input the item condition." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
            [alert show];
        }else if ([itemCategory isEqualToString:@"Not Specified"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please input the item category." delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
            [alert show];
        }else{
            NSLog(@"Calculate and switch to new view.");
            AddItemViewController *addItemViewController = [[AddItemViewController alloc] init];
            addItemViewController.delegate = self;
            [addItemViewController updateItemInfoWithTitle:itemName OriginalPrice:itemPrice Category:itemCategory Condition:itemCondition PhotoData:imgData];
            
            [self.navigationController pushViewController:addItemViewController animated:YES];
        }

    }
    
}

#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    referenceUrl = info[UIImagePickerControllerReferenceURL];
    
    // if it's a photo from the library, not an image from the camera
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = [assets firstObject];
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            imgView.image = result;
            imgData = UIImageJPEGRepresentation(result, 1.0);
        }];
    }
}

#pragma AddItemViewControllerDelegate
- (void)resetViewController
{
    NSLog(@"Reset PostItemViewController");
    if (textTableView) {
        textTableView = nil;
        textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, imgView.frame.origin.y+imgView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - imgView.frame.size.height) Data: originalTextTableData];
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
    }
    imgView.image = [UIImage imageNamed:@"default-upload"];
}

#pragma QpTableViewDelegate
- (void)changeScrollViewContentSizeBy:(CGFloat)tableViewChangedHeight NewTableHeight:(CGFloat)newTableViewHeight
{
    currentScrollContentSize = CGSizeMake(currentScrollContentSize.width, currentScrollContentSize.height - tableViewChangedHeight);
    scrollView.contentSize = currentScrollContentSize;
    
    //Update following UI position
    NSLog(@"Adjust Following Elements.");
    calculateBtn.frame = CGRectMake(0, textTableView.frame.origin.y+newTableViewHeight, [[UIScreen mainScreen] bounds].size.width, 35.0f);
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
    //do nothing.
    
}

@end
