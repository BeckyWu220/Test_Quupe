//
//  SignUpView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-27.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewInUserViewControllerDelegate.h"

@import Firebase;

@interface SignUpView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) UITextField *accountTextField;
@property (weak, nonatomic) UITextField *passwordTextField;

@property (weak, nonatomic) id <SwitchViewInUserViewControllerDelegate> delegate;

@end
