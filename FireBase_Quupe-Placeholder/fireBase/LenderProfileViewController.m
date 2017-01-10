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
    UIImageView *imgView;
    UILabel *nameLabel;
    UILabel *bioLabel;
    NSMutableArray *inventoryItems;
    UITableView *inventoryTable;
}

@end

@implementation LenderProfileViewController

@synthesize ref;

- (id)initWithLenderUID:(NSString *)lenderUID
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 64 + 10, 90, 90)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.cornerRadius = imgView.frame.size.width / 2;
        imgView.clipsToBounds = YES;
        [self.view addSubview:imgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, imgView.frame.origin.y, self.view.frame.size.width - imgView.frame.size.width - 3*10.0f, 25.0f)];
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
        nameLabel.textColor = [UIColor colorWithRed:72.0f/255.0f green:72.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
        [self.view addSubview:nameLabel];
        
        bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 10.0f, nameLabel.frame.size.width, imgView.frame.size.height -  nameLabel.frame.size.height - 10.0f)];
        bioLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        bioLabel.textColor = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        bioLabel.textAlignment = NSTextAlignmentCenter;
        bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
        bioLabel.numberOfLines = 0;
        [self.view addSubview:bioLabel];
        
        ref = [[FIRDatabase database] reference];
        
        [[[ref child:@"users-detail"] child:lenderUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            User *lender = [[User alloc] initWithDictionary:retrieveDataDict];
            NSLog(@"Lender %@'s Profile.", lender.name);
            
            if (lender.imgURL) {
                imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    //NSLog(@"DISPATCH");
                    //Background Thread --- Loading images.
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:lender.imgURL]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //Run UI Updates
                        //imgView.image = [UIImage imageWithData:imgData];
                        imgView.image = [self thumbnailForImage:imgData];
                        NSLog(@"Profile Loaded.");
                        
                    });
                });
            }else{
                imgView.image = [UIImage imageNamed:@"default-profile.jpg"];
            }
            
            nameLabel.text = lender.name;
            bioLabel.text = lender.bio;
            
        }];
        
        UILabel *inventoryTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, bioLabel.frame.origin.y + bioLabel.frame.size.height, self.view.frame.size.width - 2*10.0f, 35)];
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
            NSMutableArray *newInventoryItems = [[NSMutableArray alloc] init];
            
            NSDictionary *retrieveDataDict = snapshot.value;
            
            for (int i=0; i<[[retrieveDataDict allValues] count]; i++) {
                Item *item = [[Item alloc] initWithDictionary:[[retrieveDataDict allValues] objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
                [newInventoryItems addObject:item];
            }
            
            inventoryItems = newInventoryItems;
            [inventoryTable reloadData];
            inventoryTitleLabel.text = [NSString stringWithFormat:@"Inventory (%lu)", inventoryItems.count];
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
    [self createThumbnailIconWithURL:item.photo ForImageView:cell.itemImgView];
    
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

- (void)createThumbnailIconWithURL:(NSURL *)imgURL ForImageView:(UIImageView *)imgView
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

@end
