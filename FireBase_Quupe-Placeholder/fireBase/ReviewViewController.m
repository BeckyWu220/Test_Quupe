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
    UIScrollView *scrollView;
    CGSize currentScrollContentSize;
}

@end

@implementation ReviewViewController

-(id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.scrollEnabled = YES;
        currentScrollContentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height+64.0f + 100.0f);
        scrollView.contentSize = currentScrollContentSize;
        [self.view addSubview:scrollView];
        
        QpRatingView *ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 40.0f*5)/2, 50, 40.0f*5, 40.0f)];
        [scrollView addSubview:ratingView];
        
        QpTableView *textTableView = [[QpTableView alloc] initWithFrame:CGRectMake(0, ratingView.frame.origin.y + ratingView.frame.size.height + 50, self.view.frame.size.width, self.view.frame.size.height) Data:[NSArray arrayWithObject:@[@"Comment", @"", [NSNumber numberWithInteger:VERTICAL_TEXT_TYPE]]]];
        textTableView.scrollDelegate = self;
        [scrollView addSubview:textTableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Review";
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
