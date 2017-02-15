//
//  ViewController.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-01.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ViewController.h"
@import Firebase;
@import Photos;

@interface ViewController ()

@end

@implementation ViewController

@synthesize ref;
@synthesize localFile;
@synthesize storageRef, imagesRef;
@synthesize tableData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ref = [[FIRDatabase database] reference];
    
    //Retrieve username of a user with UID
    [[[[ref child:@"users"] child:@"zokjwwgOvKfDEz9ho7Ocf9NQB0q2"] child:@"username"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *retrieveDataDict = snapshot.value;
        NSLog(@"%@", retrieveDataDict);
    }];
    
    
    [[[ref child:@"items"] child:@"-KOMvce83vdiV03s9JYm"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *retrieveDataDict = snapshot.value;
        //NSLog(@"%@", retrieveDataDict);
        NSLog(@"%@", [retrieveDataDict objectForKey:@"lender"]);
    }];
    
    [[ref child:@"items"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *retrieveDataDict = snapshot.value;
        //NSLog(@"%@", retrieveDataDict);
        NSLog(@"%@", [retrieveDataDict objectForKey:@"-KOMvce83vdiV03s9JYm"]);
        NSLog(@"%@", [[retrieveDataDict allKeys] objectAtIndex:0]);
        //NSLog(@"%@", [[[retrieveDataDict allValues] objectAtIndex:0] objectForKey:@"title"]);
        
        tableData = [NSArray arrayWithArray:[retrieveDataDict allValues]];
        
        
    }];
    
    //Add a user with setValue
    [[[ref child:@"users"] child:@"zokjwwgOvKfDEz9ho7Ocf9NQB0q1"] setValue:@{@"username": @"Wanqiao", @"email": @"wanqiao.wu@gmail.com"}];
    
    //Updating a child without rewriting the entire object
    [[[[ref child:@"users"] child:@"zokjwwgOvKfDEz9ho7Ocf9NQB0q1"] child:@"username"] setValue:@"Wanqiao Wu"];
    
    [[[ref child:@"users"] child:@"zokjwwgOvKfDEz9ho7Ocf9NQB0q1"] removeValue];

    
    storageRef = [[FIRStorage storage] referenceForURL:@"gs://quupe-restore.appspot.com"];
    imagesRef = [storageRef child:@"images"];
    
    //Retrieve image from server storage
    NSString *fileName = @"book.jpg";
    FIRStorageReference *picRef = [imagesRef child:fileName];
    NSLog(@"GET: %@", picRef.fullPath);
    [picRef dataWithMaxSize:1*1024*1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            // Uh-oh, an error occurred!
            NSLog(@"%@", error.description);
        } else {
            // Data for "images/book.jpg" is returned
            UIImage *picImage = [UIImage imageWithData:data];
            //imgView.image = picImage;
        }
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end















