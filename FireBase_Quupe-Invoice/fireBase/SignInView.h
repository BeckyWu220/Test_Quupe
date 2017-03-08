//
//  SignInView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-08.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewInUserViewControllerDelegate.h"
#import "AppDelegate.h"

@import Firebase;

@interface SignInView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) UITextField *accountTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@property (weak, nonatomic) id <SwitchViewInUserViewControllerDelegate> delegate;

@end
