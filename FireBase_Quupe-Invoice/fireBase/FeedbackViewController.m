//
//  FeedbackViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-19.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()
@end

@implementation FeedbackViewController

@synthesize ref;
@synthesize itemReviews;
@synthesize itemKey;
@synthesize userUID;

- (id)initWithItemKey:(NSString *)key
{
    self = [super init];
    if (self) {
        self.itemKey = key;
        self.userUID = @"";
    }
    return self;
}

- (id)initWithUserUID:(NSString *)uid
{
    self = [super init];
    if (self) {
        self.itemKey = @"";
        self.userUID = uid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Reviews";
    
    ref = [[FIRDatabase database] reference];
    
    if (![self.itemKey isEqualToString:@""]) {
        if (!itemReviews) {
            [self loadReviewsForItem];
        }
    }else if (![self.userUID isEqualToString:@""]){
        [self loadReviewsForUser];
    }else {
        NSLog(@"No Reviews Need to be Loaded.");
    }
    
    
}

- (void)loadReviewsForItem
{
    [[ref child:@"reviews"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
                            NSLog(@"Reviews of Item %@: %@", self.itemKey, [reviews objectAtIndex:i]);
                            
                        }
                    }
                    
                    [self.tableView reloadData];
                }];
            }
            
        }
    }];
    
}

- (void)loadReviewsForUser
{
    [[[[[ref child:@"users-detail"] child:self.userUID] child:@"reviews"] child:@"incoming"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            NSArray *reviews = [retrieveDataDict allValues];
            itemReviews = [[NSMutableArray alloc] initWithArray:reviews];
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemReviews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 65.0f;
    
    if ([itemReviews objectAtIndex:indexPath.row]) {
        cellHeight = [[[itemReviews objectAtIndex:indexPath.row] objectForKey:@"cellHeight"] floatValue];
        
    }
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewCell *cell = (ReviewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReviewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    cell.reviewContent.text = [[itemReviews objectAtIndex:indexPath.row] objectForKey:@"comments"];
    NSString *reviewerUID = [[itemReviews objectAtIndex:indexPath.row] objectForKey:@"by"];
    
    NSString *time = [[itemReviews objectAtIndex:indexPath.row] objectForKey:@"time"];
    NSTimeInterval timeInterval = [time doubleValue] / 1000.0f;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd,yyyy"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    
    cell.reviewDate.text = [dateFormat stringFromDate:date];
    
    [[[[ref child:@"users-detail"] child:reviewerUID] child:@"name"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        if (snapshot.exists) {
            cell.reviewerName.text = snapshot.value;
        }else {
            NSLog(@"Snapshot Not Exist in users-detail->reviewer in FeedbackVC");
        }
    }];
    
    [cell.ratingView roundRating:[[[itemReviews objectAtIndex:indexPath.row] objectForKey:@"stars"] floatValue]];
    
    CGFloat cellHeight = [cell calculateCellHeight];
    [[itemReviews objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:cellHeight] forKey:@"cellHeight"];
    
    return cell;
}


@end
