//
//  EditProfileViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()
{
    AppDelegate *appDelegate;
    UIScrollView *scrollView;
    CGSize currentScrollContentSize;
    QpTableView *textTableView;
}

@end

@implementation EditProfileViewController

@synthesize ref;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        
        ref = [[FIRDatabase database] reference];
        
        //Retrieve name of a user with UID
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.scrollEnabled = YES;
        currentScrollContentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height+64.0f + 100.0f);
        scrollView.contentSize = currentScrollContentSize;
        
        [self.view addSubview:scrollView];
        
        textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2) Data:[NSArray arrayWithObjects:@[@"Name", appDelegate.currentUser.name, [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]],
                                                                                                                                                             @[@"Email", appDelegate.currentUser.email, [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]],
                                                                                                                                                             @[@"Phone", appDelegate.currentUser.phone, [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]],
                                                                                                                                                             @[@"Address", appDelegate.currentUser.address, [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]],
                                                                                                                                                             @[@"Bio", appDelegate.currentUser.bio, [NSNumber numberWithInteger:HORIZONTAL_TEXT_TYPE]],nil]];
        
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Edit Profile";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(SaveEditedProfile)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)SaveEditedProfile
{
    NSLog(@"Save Profile");
    //username index=0; email index=1; phone index=2; address index=3; bio index=4;
    NSArray *cellData = [textTableView stopEditingAndReturnCellData];
    
    for (int i=0; i<cellData.count; i++) {
        NSString *key = [[[[cellData objectAtIndex:i] allKeys] objectAtIndex:0] lowercaseString];
        if ([key isEqualToString:@"bio"]) {
            key = @"text";
        }
        NSString *value = [[[cellData objectAtIndex:i] allValues] objectAtIndex:0];
        [[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:key] setValue:value];
    }
    
    [self updateCurrentUserInfo];
}

- (void)updateCurrentUserInfo
{
    [[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *retrieveDataDict = snapshot.value;
        
        appDelegate.currentUser = [[User alloc] initWithDictionary:retrieveDataDict];
        [appDelegate saveToUserDefaults:retrieveDataDict];
        [self.delegate updateProfileView];
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
    //do nothing.
    
}

@end
