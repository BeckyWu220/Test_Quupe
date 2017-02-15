//
//  AddItemViewController.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-17.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "QpPriceView.h"
#import "QpTableView.h"
#import "TextTableCell.h"

@import Firebase;

@protocol AddItemViewControllerDelegate <NSObject>

@required
- (void)resetViewController;

@end

@interface AddItemViewController : UIViewController <QpTableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *imagesRef;

@property (weak, nonatomic) id<AddItemViewControllerDelegate> delegate;

@property (strong, nonatomic) Item *currentItem;
@property (strong, nonatomic) UIScrollView *scrollView;

- (void)updateItemInfoWithTitle:(NSString *)title OriginalPrice:(NSString *)oPrice Category:(NSString *)category Condition:(NSString *)condition PhotoData:(NSData *)photoData;

@end
