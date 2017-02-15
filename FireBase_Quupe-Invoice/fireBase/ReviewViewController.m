//
//  ReviewViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ReviewViewController.h"

@interface ReviewViewController ()
{
    AppDelegate *appDelegate;
    
    UIScrollView *scrollView;
    CGSize currentScrollContentSize;
    
    UILabel *titleLabel;
    QpTableView *textTableView;
    QpRatingView *ratingView;
    UIButton *submitBtn;
    
    UIViewController *doneController;
    UILabel *doneLabel;
    UILabel *tipLabel;
    
    NSString *comment;
}

@end

@implementation ReviewViewController

@synthesize ref;
@synthesize targetUID;
@synthesize itemKey;

-(id)initWithTargetUID:(NSString *)targetUserUID ForItem:(NSString *)itemKey
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.targetUID = targetUserUID;
        self.itemKey = itemKey;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.scrollEnabled = YES;
        currentScrollContentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height+64.0f + 100.0f);
        scrollView.contentSize = currentScrollContentSize;
        [self.view addSubview:scrollView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40.0f,scrollView.frame.size.width, 60)];
        titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:18.0f];
        titleLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.text = @"How is your experience about \nthis transaction?";
        [scrollView addSubview:titleLabel];
        
        ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 40.0f*5)/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 40.0f, 40.0f*5, 40.0f) Interval:10.0f];
        [scrollView addSubview:ratingView];
        
        textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, ratingView.frame.origin.y + ratingView.frame.size.height + 50, self.view.frame.size.width, 100.0f) Data:[NSArray arrayWithObject:@[@"Comment", @"", [NSNumber numberWithInteger:VERTICAL_TEXT_TYPE]]]];
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
        
        comment = @"";
        
        submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, textTableView.frame.origin.y + textTableView.frame.size.height + 10.0f, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
        submitBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(clickSubmitBtn) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:submitBtn];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Review";
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    ref = [[FIRDatabase database] reference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickSubmitBtn
{
    if ([comment isEqualToString:@""] || [comment isEqualToString:@"Not Specified"]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Please write down your comment and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    
    }else {
        
        doneController = [[UIViewController alloc] init];
        doneController.view.backgroundColor = [UIColor whiteColor];
        
        UIImageView *doneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"complete"]];
        doneImgView.frame = CGRectMake((self.view.frame.size.width - 414/2)/2, (self.view.frame.size.height - 348/2)/2 - 100, 414/2, 348/2);
        [doneController.view addSubview:doneImgView];
        
        doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(doneImgView.frame.origin.x, doneImgView.frame.origin.y + doneImgView.frame.size.height + 30.0f, doneImgView.frame.size.width, 30)];
        doneLabel.text = @"Thank You!";
        doneLabel.textAlignment = NSTextAlignmentCenter;
        doneLabel.textColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        doneLabel.font = [UIFont fontWithName:@"SFUIDisplay-Bold" size:16.0];
        //doneLabel.backgroundColor = [UIColor yellowColor];
        [doneController.view addSubview:doneLabel];
        
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(doneImgView.frame.origin.x, doneLabel.frame.origin.y + doneLabel.frame.size.height + 20.0f, doneImgView.frame.size.width, 100.0f)];
        tipLabel.text = @"Quupe thanks for your review.";
        tipLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        tipLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel.numberOfLines = 0;
        //tipLabel.backgroundColor = [UIColor yellowColor];
        [doneController.view addSubview:tipLabel];
        
        doneController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:doneController animated:YES completion:^{
            [self saveReviewToFirebase];
        }];

    }
    
}

- (void)saveReviewToFirebase
{
    NSString *key = [[ref child:@"reviews"] childByAutoId].key;
    NSLog(@"Review Key: %@", key);
    
    NSArray *cellData = [textTableView stopEditingAndReturnCellData];
    comment = [[[cellData objectAtIndex:0] allValues] objectAtIndex:0];
    
    
    NSDictionary *review = @{@"by": appDelegate.currentUser.uid,
                             @"comments": comment,
                             @"forItem": self.itemKey,
                             @"key": key,
                             @"stars": [NSString stringWithFormat:@"%d", (int)ratingView.currentRating],
                             @"time": [FIRServerValue timestamp],
                             @"to": self.targetUID};
    
    [[[ref child:@"reviews"] child:key] setValue:review];
    [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"reviews"] child:@"outgoing"] child:key] setValue:review];
    [[[[[[ref child:@"users-detail"] child:targetUID] child:@"reviews"] child:@"incoming"] child:key] setValue:review];
    
    [[[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:self.itemKey] child:@"comment"] setValue:comment];
    [[[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] child:self.itemKey] child:@"rating"] setValue:[NSString stringWithFormat:@"%d", (int)ratingView.currentRating]];
    
    [[[[ref child:@"requests"] child:self.itemKey] child:@"comment"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            int currentCommentAmount = [snapshot.value intValue];
            currentCommentAmount += 1;
            [[[[ref child:@"requests"] child:self.itemKey] child:@"comment"] setValue: [NSString stringWithFormat:@"%d", currentCommentAmount]];
        }else {
            NSLog(@"Snapshot Not Exist in requests->itemKey->commment in ReviewVC.");
            [[[[ref child:@"requests"] child:self.itemKey] child:@"comment"] setValue:@"1"];
        }
    }];
    
    __block float currentUserRate = 0.0;
    __block int currentRatingAmount = 0;
    [[[[ref child:@"users-detail"] child:targetUID] child:@"account"] observeSingleEventOfType:FIRDataEventTypeValue withBlock: ^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            currentUserRate = [[snapshot.value objectForKey:@"rate"] floatValue];
            currentRatingAmount = [[snapshot.value objectForKey:@"ratings"] integerValue];
            
            [[[[[ref child:@"users-detail"] child:targetUID] child:@"account"] child:@"rate"] setValue: [NSString stringWithFormat:@"%.2f", (currentUserRate*currentRatingAmount + ratingView.currentRating)/(currentRatingAmount + 1)]];
            [[[[[ref child:@"users-detail"] child:targetUID] child:@"account"] child:@"ratings"] setValue: [NSString stringWithFormat:@"%d", currentRatingAmount + 1]];
        }else {
            NSLog(@"Snapshot Not Exist in users-detail->uid->account in ReviewVC.");
            NSLog(@"Create account node under uid.");
            [[[[ref child:@"users-detail"] child:targetUID] child:@"account"] setValue:@{@"earned": @"0",
                           @"paid": @"0",
                           @"rate": [NSString stringWithFormat:@"%d", (int)ratingView.currentRating],
                           @"ratings": @"1"}];
        }
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissReviewView) userInfo:nil repeats:NO];
}

- (void)dismissReviewView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
    submitBtn.frame = CGRectMake(0, textTableView.frame.origin.y + textTableView.frame.size.height + 10.0f, [[UIScreen mainScreen] bounds].size.width, 35.0f);
    
    NSArray *cellData = [textTableView stopEditingAndReturnCellData];
    comment = [[[cellData objectAtIndex:0] allValues] objectAtIndex:0];

    NSLog(@"Comment: %@", comment);
}

@end
