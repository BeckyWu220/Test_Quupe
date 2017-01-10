//
//  TransactionViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-14.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "TransactionViewController.h"

@interface TransactionViewController ()
{
    AppDelegate *appDelegate;
    int currentSelectedRow;
    
    QpTransTableView *transTable;
}

@end

@implementation TransactionViewController

@synthesize ref;
@synthesize targetUID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Transaction";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    ref = [[FIRDatabase database] reference];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    transTable = [[QpTransTableView alloc] initWithFrame:self.view.frame];
    transTable.controllerDelegate = self;
    [self.view addSubview:transTable];
    
    [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"items"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableArray *newItemInfoArray = [[NSMutableArray alloc] init];
        
        if (snapshot.exists)
        {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            for (int i=0; i<[retrieveDataDict allValues].count; i++) {
                
                [[[retrieveDataDict allValues] objectAtIndex:i] setObject:[[retrieveDataDict allKeys] objectAtIndex:i] forKey:@"key"];//Add itemKey to item info dictionary.
                
                [[[retrieveDataDict allValues] objectAtIndex:i] setObject:targetUID forKey:@"targetUID"];
                
                if ([[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"borrower"] isEqualToString:appDelegate.currentUser.uid]) {
                    [[[retrieveDataDict allValues] objectAtIndex:i] setObject:@"Borrowed" forKey:@"direction"];
                }else if ([[[[retrieveDataDict allValues] objectAtIndex:i] objectForKey:@"lender"] isEqualToString:appDelegate.currentUser.uid]) {
                    [[[retrieveDataDict allValues] objectAtIndex:i] setObject:@"Lent" forKey:@"direction"];
                }
                
                [newItemInfoArray addObject:[[retrieveDataDict allValues] objectAtIndex:i]];
            }
            
            transTable.tableData = newItemInfoArray;
            [transTable sortCells];
            [transTable reloadData];
        }else
        {
            NSLog(@"NO ITEMS NODE YET");
        }
    
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (error) {
                [self presentError:error];
            } else {
                [transTable paymentSucceededForItem:controller.itemInfo Token:controller.paymentToken.tokenId];
                [self presentSuccess];
                
            }
        }];
        [self.navigationController popToViewController:self animated:YES];
        [CATransaction commit];
    });

}

- (void)presentSuccess
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Success" message:@"Payment successfully created!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)presentError:(NSError *)error
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma QpTransTableDelegate
- (void)SwitchToCheckoutViewWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo
{
    NSLog(@"Switch To Payment.");
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:@"PaymentViewController" bundle:[NSBundle mainBundle]];
    paymentViewController.itemInfo = itemInfo;
    paymentViewController.amount = price;
    paymentViewController.delegate = self;
    
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

- (void)SwitchToReviewView
{
    NSLog(@"Switch To Review");
    ReviewViewController *reviewController = [[ReviewViewController alloc] init];
    [self.navigationController pushViewController:reviewController animated:YES];
}


@end
