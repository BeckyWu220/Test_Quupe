//
//  LenderProfileViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "LenderProfileViewController.h"

@interface LenderProfileViewController ()
{
    QpAsyncImage *imgView;
    UILabel *nameLabel;
    UILabel *bioLabel;
    NSMutableArray *inventoryItems;
    UITableView *inventoryTable;
    NSString *userID;
}

@end

@implementation LenderProfileViewController

@synthesize ref;

- (id)initWithLenderUID:(NSString *)lenderUID
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        ref = [[FIRDatabase database] reference];
        
        userID = lenderUID;
        
        imgView = [[QpAsyncImage alloc] initWithFrame:CGRectMake(10, 64 + 10, 90, 90)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.cornerRadius = imgView.frame.size.width / 2;
        imgView.clipsToBounds = YES;
        [self.view addSubview:imgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, imgView.frame.origin.y, self.view.frame.size.width - imgView.frame.size.width - 3*10.0f, 25.0f)];
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
        nameLabel.textColor = [UIColor colorWithRed:72.0f/255.0f green:72.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
        [self.view addSubview:nameLabel];
        
        QpRatingView *ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10.0f, 12.0f*5, 12.0f) Rating:0.0];
        [self.view addSubview:ratingView];
        
        bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10.0f, nameLabel.frame.size.width, imgView.frame.size.height -  nameLabel.frame.size.height - 10.0f)];
        bioLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        bioLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        bioLabel.textAlignment = NSTextAlignmentLeft;
        bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
        bioLabel.numberOfLines = 0;
        [self.view addSubview:bioLabel];
        
        [[[ref child:@"users-detail"] child:lenderUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if (snapshot.exists) {
                NSDictionary *retrieveDataDict = snapshot.value;
                
                User *lender = [[User alloc] initWithDictionary:retrieveDataDict];
                NSLog(@"Lender %@'s Profile.", lender.name);
                
                if (lender.imgURL) {
                    [imgView loadImageFromURL:[NSURL URLWithString:lender.imgURL]];
                }
                
                nameLabel.text = lender.name;
                bioLabel.text = lender.bio;
                
                [ratingView roundRating:lender.rating];
            }else{
                NSLog(@"Snapshot Not Exist in users-detail->LenderUID of LenderProfileVC.");
            }
            
        }];
        
        UIButton *reviewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bioLabel.frame.origin.y+bioLabel.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
        reviewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        reviewBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        [reviewBtn setTitleColor:[UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
        reviewBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:14.0f];
        [[[[[ref child:@"users-detail"] child:userID] child:@"reviews"] child:@"incoming"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                [reviewBtn setTitle:[NSString stringWithFormat:@"See All Reviews (%lu)", (unsigned long)snapshot.childrenCount] forState:UIControlStateNormal];
                [reviewBtn addTarget:self action:@selector(SwitchToLoadReviews) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:reviewBtn];
            }
        }];
        
        UILabel *inventoryTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, reviewBtn.frame.origin.y + reviewBtn.frame.size.height, self.view.frame.size.width - 2*10.0f, 35)];
        inventoryTitleLabel.text = @"Inventory";
        inventoryTitleLabel.font =[UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        inventoryTitleLabel.textColor =[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        [self.view addSubview:inventoryTitleLabel];
        
        inventoryItems = [[NSMutableArray alloc] init];
        inventoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, inventoryTitleLabel.frame.origin.y + inventoryTitleLabel.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (inventoryTitleLabel.frame.origin.y + inventoryTitleLabel.frame.size.height))];
        inventoryTable.delegate = self;
        inventoryTable.dataSource = self;
        [self.view addSubview:inventoryTable];
        
        [[[ref child:@"user-items"] child:lenderUID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if (snapshot.exists) {
                NSMutableArray *newInventoryItems = [[NSMutableArray alloc] init];
                
                NSDictionary *retrieveDataDict = snapshot.value;
                
                for (int i=0; i<[[retrieveDataDict allValues] count]; i++) {
                    Item *item = [[Item alloc] initWithDictionary:[[retrieveDataDict allValues] objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
                    [newInventoryItems addObject:item];
                }
                
                inventoryItems = newInventoryItems;
                [inventoryTable reloadData];
                inventoryTitleLabel.text = [NSString stringWithFormat:@"Inventory (%lu)", inventoryItems.count];
            }else{
                NSLog(@"Snapshot Not Exist in users-detail->lenderUID of LenderProfileVC.");
            }
            
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Lender Profile";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inventoryItems.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [inventoryItems objectAtIndex:indexPath.row];
    
    InventoryTableCell *cell = (InventoryTableCell *)[tableView dequeueReusableCellWithIdentifier:@"InventoryTableCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InventoryTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.itemNameLabel.text = item.title;
    cell.itemRentLabel.text = [NSString stringWithFormat:@"$%.2f/Day", item.rentDay];//This need to be changed to rent per day later.
    cell.itemTransNumberLabel.text = @"ItemTransactionCount";
    [cell.itemImgView loadImageFromURL:item.photo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did Select Inventory Cell At Row: %d", indexPath.row);
    
    Item *item = [inventoryItems objectAtIndex:indexPath.row];
    
    ItemInfoViewController *itemInfoController = [[ItemInfoViewController alloc] initWithItem:item];
    [itemInfoController loadImageFromURL:item.photo];
    
    [self.navigationController pushViewController:itemInfoController animated:YES];
}

- (void)SwitchToLoadReviews
{
    NSLog(@"Load More Reviews of Lender");
    FeedbackViewController *feedbackController = [[FeedbackViewController alloc] initWithUserUID:userID];
    [self.navigationController pushViewController:feedbackController animated:YES];
}

@end
