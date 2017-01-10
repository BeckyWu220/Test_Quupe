//
//  ItemBrowseViewController.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-11.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ItemBrowseViewController.h"

#import "ItemInfoViewController.h"

#import "ItemTableCell.h"

#import "Item.h"

#import "PostItemViewController.h"

#import "ProfileView.h"
#import "UserViewController.h"


@interface ItemBrowseViewController ()
{
    AppDelegate *appDelegate;
}

@end

@implementation ItemBrowseViewController

@synthesize listOfCells;
@synthesize ref;
@synthesize tableData;
@synthesize picDic;
@synthesize defaultImg;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.view.backgroundColor = [UIColor yellowColor];
        
        self.navigationItem.title = @"Item Browse";
        
        //Set backBarButton's title that would be shown in the ItemInfoView.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

- (void)viewDidLoad {
    
    NSLog(@"ItemBrowserDidLoad");
    
    ref = [[FIRDatabase database] reference];
    
    self.listOfCells = [[NSMutableArray alloc] init];
    
    picDic = [[NSMutableDictionary alloc] init];
    defaultImg = [UIImage imageNamed:@"default-thumbnail.jpg"];
    
    [super viewDidLoad];
    //self.tableView.hidden = YES;
    
    //remove a node from database
    [[[ref child:@"users"] child:@"zokjwwgOvKfDEz9ho7Ocf9NQB0q2"] removeValue];
    
    [[[ref child:@"items"] queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"EventListener!");
        
        NSDictionary *retrieveDataDict = snapshot.value;
        //NSLog(@"%@", retrieveDataDict);
        NSLog(@"%@", [retrieveDataDict objectForKey:@"-KOMvce83vdiV03s9JYm"]);
        NSLog(@"%@", [[retrieveDataDict allKeys] objectAtIndex:0]);
        //NSLog(@"%@", [[[retrieveDataDict allValues] objectAtIndex:0] objectForKey:@"title"]);
        
        tableData = [NSArray arrayWithArray:[retrieveDataDict allValues]];
        
        [self.listOfCells removeAllObjects];
        
        for (int i=0; i<tableData.count; i++)
        {
            Item *item = [[Item alloc] initWithDictionary:[tableData objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
            [self.listOfCells addObject:item];
            //[picDic setObject:defaultImg forKey:item.key];
        
            //[picArray addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[[self.listOfCells objectAtIndex:i] photo]]]];
        }
        
        for (int j=0; j<tableData.count; j++)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                //Background Thread --- Loading images.
                if (! picDic[[[self.listOfCells objectAtIndex:j] key]])
                {
                    NSData *imgData = [NSData dataWithContentsOfURL:[[self.listOfCells objectAtIndex:j] photo]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //Run UI Updates
                        //NSLog(@"Load Completed: %@", [[self.listOfCells objectAtIndex:j] title]);
                        //[picDic setObject:[UIImage imageWithData:imgData] forKey:[[self.listOfCells objectAtIndex:j] key]];
                        [picDic setObject:[self thumbnailForImage:imgData] forKey:[[self.listOfCells objectAtIndex:j] key]];
                        [self.tableView reloadData];
                    });
                }
            });
        }
        
        [self.tableView reloadData];
    
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [listOfCells count];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listOfCells count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellTableIdentifier = @"ItemTableCell";
    ItemTableCell *cell = (ItemTableCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    
    
    if (cell == nil)
    {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItemTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [[listOfCells objectAtIndex:indexPath.row] title];
    cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f/Day", [[listOfCells objectAtIndex:indexPath.row] rentDay]];
    [cell.ratingView roundRating:[[listOfCells objectAtIndex:indexPath.row] starCount]];
    
    if(picDic[[[listOfCells objectAtIndex:indexPath.row] key]])
    {
        cell.thumbnailImageView.image = [picDic objectForKey:[[listOfCells objectAtIndex:indexPath.row] key]];
    }else{
        cell.thumbnailImageView.image = defaultImg;
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemInfoViewController *itemInfoController = [[ItemInfoViewController alloc] initWithItem:[listOfCells objectAtIndex:indexPath.row]];
    
    if (! picDic[[[self.listOfCells objectAtIndex:indexPath.row] key]])
    {
        Item *item = [listOfCells objectAtIndex:indexPath.row];
        [itemInfoController loadImageFromURL:item.photo];
    }else{
        itemInfoController.imageView.image = [picDic objectForKey:[[listOfCells objectAtIndex:indexPath.row] key]];
    }
        
    
    [self.navigationController pushViewController:itemInfoController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 280;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //remove a node from database
        [[[ref child:@"items"] child:[[listOfCells objectAtIndex:indexPath.row] key]] removeValue];
        
        // Delete the row from the data source
        [listOfCells removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        
    } 
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
