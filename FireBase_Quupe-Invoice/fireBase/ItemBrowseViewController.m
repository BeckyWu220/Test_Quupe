//
//  ItemBrowseViewController.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-11.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ItemBrowseViewController.h"

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
    ItemInfoViewController *currentItemInfoVC;
}

@end

@implementation ItemBrowseViewController

@synthesize itemArray;
@synthesize ref;
@synthesize defaultImg;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.view.backgroundColor = [UIColor yellowColor];
        
        self.navigationItem.title = @"Item Browse";
        
        //Set backBarButton's title that would be shown in the ItemInfoView.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:nil action:nil];
        
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
    
    [[[ref child:@"items"] queryOrderedByChild:@"time"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"EventListener!");
        
        NSMutableArray *newItemArray = [[NSMutableArray alloc] init];
        
        if (snapshot.exists)
        {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            for (int i=[retrieveDataDict allValues].count-1; i>0; i--) {
                Item *item = [[Item alloc] initWithDictionary:[[retrieveDataDict allValues] objectAtIndex:i] Key:[[retrieveDataDict allKeys] objectAtIndex:i]];
                [newItemArray addObject:item];
            }
            
            self.itemArray = newItemArray;
            
            for (int j=0; j<self.itemArray
                 .count; j++)
            {
                Item *item = [self.itemArray objectAtIndex:j];
                ImageRecord *imgRecord = [[ImageRecord alloc] initWithName:item.title URL:item.photo];
                [itemImageRecords addObject:imgRecord];
        
            }
            
            [self.tableView reloadData];
        }else{
            NSLog(@"Snapshot Not Exist in items of ItemBrowseVC.");
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
    
    ImageRecord *imgRecord = [itemImageRecords objectAtIndex:indexPath.row];
    cell.thumbnailImageView.image = imgRecord.image;
    
    if (imgRecord.state == New) {
        [self startDownloadForRecord:imgRecord IndexPath:indexPath];
    }else if (imgRecord.state == Downloaded) {
        [self startScaleForRecord:imgRecord IndexPath:indexPath];
    }
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [itemArray objectAtIndex:indexPath.row];
    
    currentItemInfoVC = [[ItemInfoViewController alloc] initWithItem:item];
    
    [currentItemInfoVC loadImageFromURL:item.photo];
    
    currentItemInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:currentItemInfoVC animated:YES];
    currentItemInfoVC = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 280;
}

#pragma UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //Suspend all operations
    [pendingOperations.downloadQueue setSuspended:true];
    [pendingOperations.scaleQueue setSuspended:true];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //When users stopped dragging the tableview. Resume suspended operations.
        [self loadImagesForOnscreenCells];
        [pendingOperations.downloadQueue setSuspended:false];
        [pendingOperations.scaleQueue setSuspended:false];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenCells];
    [pendingOperations.downloadQueue setSuspended:false];
    [pendingOperations.scaleQueue setSuspended:false];
}

- (void)loadImagesForOnscreenCells
{
    NSArray *visibleIndexPaths = self.tableView.indexPathsForVisibleRows;
    if (visibleIndexPaths) {
        NSMutableSet *allPendingOperations = [[NSMutableSet alloc] initWithArray:pendingOperations.downloadsInProgress.allKeys];
        [allPendingOperations unionSet:[[NSSet alloc] initWithArray:pendingOperations.scalesInProgress.allKeys]];
        
        NSMutableSet *toBeCancelled = allPendingOperations;
        [toBeCancelled minusSet:[[NSSet alloc] initWithArray:visibleIndexPaths]];
        
        for (NSIndexPath *indexPath in toBeCancelled) {
            NSOperation *downloadOperation = pendingOperations.downloadsInProgress[indexPath];
            if (downloadOperation) {
                [downloadOperation cancel];
            }
            [pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
            
            NSOperation *scaleOperation = pendingOperations.scalesInProgress[indexPath];
            if (scaleOperation) {
                [scaleOperation cancel];
            }
            [pendingOperations.scalesInProgress removeObjectForKey:indexPath];
        }
        
        NSMutableSet *toBeStarted = [[NSMutableSet alloc] initWithArray:visibleIndexPaths];
        
        for (NSIndexPath *indexPath in toBeStarted) {
            ImageRecord *imgRecord = itemImageRecords[indexPath.row];
            if (imgRecord.state == New) {
                [self startDownloadForRecord:imgRecord IndexPath:indexPath];
            }else if (imgRecord.state == Downloaded) {
                [self startScaleForRecord:imgRecord IndexPath:indexPath];
            }
        }
    }
}

- (void)startDownloadForRecord:(ImageRecord *)imgRecord IndexPath:(NSIndexPath *)indexPath
{
    if (pendingOperations.downloadsInProgress[indexPath]) {
        return;
    }
    ImageDownloader *downloader = [[ImageDownloader alloc] initWithImageRecord:imgRecord];
    if (downloader) {
        __weak ImageDownloader *weakDownloader = downloader;
        weakDownloader.completionBlock = ^{
            if (weakDownloader.isCancelled) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        };
        
        pendingOperations.downloadsInProgress[indexPath] = downloader;
        [pendingOperations.downloadQueue addOperation:downloader];
    }
}

- (void)startScaleForRecord:(ImageRecord *)imgRecord IndexPath:(NSIndexPath *)indexPath
{
    if (pendingOperations.scalesInProgress[indexPath]) {
        return;
    }
    ImageScaler *scaler = [[ImageScaler alloc] initWithImageRecord:imgRecord];
    __weak ImageScaler *weakScaler = scaler;
    weakScaler.completionBlock = ^{
        if (weakScaler.isCancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [pendingOperations.scalesInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    };
    
    pendingOperations.scalesInProgress[indexPath] = scaler;
    [pendingOperations.scaleQueue addOperation:scaler];
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
