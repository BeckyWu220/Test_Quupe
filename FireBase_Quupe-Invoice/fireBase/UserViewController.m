//
//  UserViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-23.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()
{
    AppDelegate *appDelegate;
    ProfileView *profileView;
    SignInView *signInView;
    SignUpView *signUpView;
}

@end

@implementation UserViewController

@synthesize ref;
@synthesize currentView;

- (id)init
{
    self = [super init];
    if (self){
        self.view.backgroundColor = [UIColor whiteColor];
        
        appDelegate = [[UIApplication sharedApplication] delegate];
        ref = [[FIRDatabase database] reference];

        signInView = [[SignInView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        signInView.delegate = self;
        [self.view addSubview:signInView];
        
        currentView = signInView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma SwitchViewInUserViewControllerDelegate
- (void)SwitchToProfileViewWithUID:(NSString *)uid
{
    NSLog(@"LOG CALL SWITCH PROFILE %@", uid);
    self.navigationItem.title = @"Profile";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(SwitchToEditProfileView)];
    
    profileView = [[ProfileView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    profileView.delegate = self;
    NSLog(@"SIGNIN VIEW SIZE: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
    [UIView transitionFromView:currentView toView:profileView duration:1.0f options:UIViewAnimationOptionCurveEaseInOut completion:^(BOOL finished) {
        currentView = profileView;
    }];
    
    
    ref = [[FIRDatabase database] reference];
    
    [[[ref child:@"users-detail"] child:uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            NSDictionary *retrieveDataDict = snapshot.value;
            
            appDelegate.currentUser = [[User alloc] initWithDictionary:retrieveDataDict];
            NSLog(@"Rating: %d", appDelegate.currentUser.rating);
            [appDelegate customizeBatchToken];
            [appDelegate saveToUserDefaults:retrieveDataDict];
            
            NSLog(@"TEST: %@", appDelegate.currentUser.name);
            
            [profileView loadInfoFromUser:appDelegate.currentUser];
        }else{
            NSLog(@"Snapshot Not Exist in users-detail->currentUserUID of UserVC.");
        }
        
    }];
}

- (void)SwitchToSignInView
{
    NSLog(@"Switch To SignIn View");
    self.navigationItem.title = @"Sign In";
    self.navigationItem.rightBarButtonItem = nil;
    
    signInView = [[SignInView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    signInView.delegate = self;
    
    [UIView transitionFromView:currentView toView:signInView duration:1.0f options:UIViewAnimationOptionCurveEaseInOut completion:^(BOOL finished) {
        currentView = signInView;
    }];
}

- (void)SwitchToSignUpView
{
    NSLog(@"Switch To SignUp View");
    self.navigationItem.title = @"Sign Up";
    self.navigationItem.rightBarButtonItem = nil;
    
    signUpView = [[SignUpView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    signUpView.delegate = self;
    
    [UIView transitionFromView:currentView toView:signUpView duration:1.0f options:UIViewAnimationOptionCurveEaseInOut completion:^(BOOL finished) {
        currentView = signUpView;
    }];
}

- (void)SwitchToEditProfileView
{
    NSLog(@"Switch To Edit Profile");
    
    EditProfileViewController *editProfileController = [[EditProfileViewController alloc] init];
    editProfileController.delegate = profileView;
    editProfileController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editProfileController animated:YES];
}

- (void)SwitchToReviewViewFromProfileForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID
{
    NSLog(@"Switch From Profile To Review");
    ReviewViewController *reviewController = [[ReviewViewController alloc] initWithTargetUID:targetUID ForItem:itemKey];
    [self.navigationController pushViewController:reviewController animated:YES];
}

- (void)SwitchToCheckoutViewFromProfileWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo
{
    NSLog(@"Switch From Profile To Payment.");
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithItemInfo:itemInfo Price:price];
    paymentViewController.delegate = self;
    
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

- (void)SwitchToInvoiceViewFromProfileForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID
{
    NSLog(@"Switch From Profile to Invoice.");
    InvoiceViewController *invoiceController = [[InvoiceViewController alloc] initWithItemKey:itemKey TargetUID:targetUID];
    [self.navigationController pushViewController:invoiceController animated:YES];
}

- (void)SwitchToItemInfoFromProfileWithItem:(Item *)item
{
    NSLog(@"Switch From Profile to Item Info.");
    ItemInfoViewController *itemInfoController = [[ItemInfoViewController alloc] initWithItem:item];
    [itemInfoController loadImageFromURL:item.photo];
    
    [self.navigationController pushViewController:itemInfoController animated:YES];
}

- (void)SwitchToFeedbackView
{
    FeedbackViewController *feedbackController = [[FeedbackViewController alloc] initWithUserUID:appDelegate.currentUser.uid];
    [self.navigationController pushViewController:feedbackController animated:YES];
}

- (void)DisplayAlertWithTitle:(NSString *)title Message:(NSString *)message
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title   message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma PaymentViewControllerDelegate
- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (error) {
                [self presentError:error];
            } else {
                if ([profileView.currentTableTitle isEqualToString:@"BorrowTrans"]) {
                    [profileView.borrowTransTable paymentSucceededForItem:controller.itemInfo Token:controller.paymentToken.tokenId];
                }else if ([profileView.currentTableTitle isEqualToString:@"LendTrans"]){
                    [profileView.lendTransTable paymentSucceededForItem:controller.itemInfo Token:controller.paymentToken.tokenId];
                }
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


@end
