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

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#import "ImageOperations.h"

@class Reachability;


@interface ItemBrowseViewController ()
{
    AppDelegate *appDelegate;
    NSMutableArray *itemImageRecords;
    ImageOperations *pendingOperations;
}

@end

@implementation ItemBrowseViewController

@synthesize itemArray;
@synthesize ref;
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
        itemImageRecords = [[NSMutableArray alloc] init];
        pendingOperations = [[ImageOperations alloc] init];
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

- (void)viewDidLoad {
    
    NSLog(@"ItemBrowserDidLoad");
    
    ref = [[FIRDatabase database] reference];
    
    self.itemArray = [[NSMutableArray alloc] init];
    
    picDic = [[NSMutableDictionary alloc] init];
    defaultImg = [UIImage imageNamed:@"default-thumbnail.jpg"];
    
    [super viewDidLoad];
    //self.tableView.hidden = YES;
    
    //Check Internet Reachability
    Reachability *internetReachable;
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        NSLog(@"Internet Not Reachable");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your Internet connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else {
        //Internet Reachable
        if (internetStatus == ReachableViaWiFi){
            NSLog(@"Internet Via WIFI");
        }else if (internetStatus == ReachableViaWWAN){
            NSLog(@"Internet Via WWAN");
        }
        
        //Check Firebase Reachability
        /*[ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if ([snapshot.value boolValue]) {
                NSLog(@"Firebase Connected");
            }else {
                NSLog(@"Firebase Not Connected.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"The Quupe mobile service encountered a problem. Please try again shortly" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];*/
    }
    
    [[[[ref child:@"items"] queryOrderedByChild:@"time"] queryLimitedToLast:50] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"EventListener!");
        
        NSMutableArray *newItemArray = [[NSMutableArray alloc] init];
        
        if (snapshot.exists)
        {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            for (int i=0; i<[retrieveDataDict allValues].count; i++) {
                Item *item = [[Item alloc] initWithDictionary:[[retrieveDataDict allValues] objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
                [newItemArray addObject:item];
            }
            
            self.itemArray = newItemArray;
            [self.tableView reloadData];
        }else{
            NSLog(@"Snapshot Not Exist in items of ItemBrowseVC.");
        }
        
        for (int j=0; j<self.itemArray
             .count; j++)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                //Background Thread --- Loading images.
                if (! picDic[[[self.itemArray objectAtIndex:j] key]])
                {
                    NSData *imgData = [NSData dataWithContentsOfURL:[[self.itemArray objectAtIndex:j] photo]];
                    if (imgData) {
                        UIImage *thumbnail = [self thumbnailForImage:imgData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            //Run UI Updates
                            if (thumbnail) {
                                [picDic setObject:thumbnail forKey:[[self.itemArray objectAtIndex:j] key]];
                                [self.tableView reloadData];
                            }else {
                                NSLog(@"Fail to generate thumbnail for %@", [[self.itemArray objectAtIndex:j] title]);
                            }
                        });
                    }else{
                        NSLog(@"Fail to get image data for %@", [[self.itemArray objectAtIndex:j] title]);
                    }
                }
            });
        }
    
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemArray count];
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
    
    cell.nameLabel.text = [[itemArray objectAtIndex:indexPath.row] title];
    cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f/Day", [[itemArray objectAtIndex:indexPath.row] rentDay]];
    [cell.ratingView roundRating:[[itemArray objectAtIndex:indexPath.row] starCount]];
    
    if(picDic[[[itemArray objectAtIndex:indexPath.row] key]])
    {
        cell.thumbnailImageView.image = [picDic objectForKey:[[itemArray objectAtIndex:indexPath.row] key]];
    }else{
        cell.thumbnailImageView.image = defaultImg;
    }
    
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemInfoViewController *itemInfoController = [[ItemInfoViewController alloc] initWithItem:[itemArray objectAtIndex:indexPath.row]];
    
    if (! picDic[[[self.itemArray objectAtIndex:indexPath.row] key]])
    {
        Item *item = [itemArray objectAtIndex:indexPath.row];
        [itemInfoController loadImageFromURL:item.photo];
    }else{
        itemInfoController.imageView.image = [picDic objectForKey:[[itemArray objectAtIndex:indexPath.row] key]];
    }
        
    itemInfoController.hidesBottomBarWhenPushed = YES;
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
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //remove a node from database
        [[[ref child:@"items"] child:[[itemArray objectAtIndex:indexPath.row] key]] removeValue];
        
        // Delete the row from the data source
        [itemArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        
    } 
}*/

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
