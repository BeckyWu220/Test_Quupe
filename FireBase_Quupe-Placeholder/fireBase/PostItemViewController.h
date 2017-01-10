//
//  PostItemViewController.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-13.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Item.h"
#import "AddItemViewController.h"
#import "QpTableView.h"
@import Firebase;
@import Photos;

#import "AppDelegate.h"

@interface PostItemViewController : UIViewController <UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, QpTableViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *imagesRef;


@property (weak, nonatomic) IBOutlet UIButton *albumBtn;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) UIImagePickerController *imgPickerController;

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *condition;

@property (strong, nonatomic) UIScrollView *scrollView;

@end
