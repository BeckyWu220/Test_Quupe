//
//  SignUpView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-27.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "SignUpView.h"

@implementation SignUpView

@synthesize ref;
@synthesize accountTextField, passwordTextField;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        ref = [[FIRDatabase database] reference];
        
        self.backgroundColor = [UIColor whiteColor];
        
        accountTextField = [[UITextField alloc] initWithFrame:CGRectMake((1-0.75)/2*self.frame.size.width, 200, 0.75 * self.frame.size.width, 30)];
        [self addSubview:accountTextField];
        accountTextField.borderStyle = UITextBorderStyleNone;
        [self createUnderlineForTextField:accountTextField];
        
        accountTextField.font = [UIFont fontWithName:@"SFUIText-Semibold" size:16.0f];
        accountTextField.backgroundColor = [UIColor clearColor];
        accountTextField.delegate = self;
        accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Account" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(accountTextField.frame.origin.x, accountTextField.frame.origin.y + accountTextField.frame.size.height + 10, accountTextField.frame.size.width, accountTextField.frame.size.height)];
        [self addSubview:passwordTextField];
        
        passwordTextField.borderStyle = UITextBorderStyleNone;
        passwordTextField.backgroundColor = [UIColor clearColor];
        [self createUnderlineForTextField:passwordTextField];
        
        passwordTextField.font = [UIFont fontWithName:@"SFUIText-Semibold" size:16.0f];
        passwordTextField.delegate = self;
        passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        passwordTextField.secureTextEntry = YES;
        
        UIButton *signUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(passwordTextField.frame.origin.x, passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 10, passwordTextField.frame.size.width, 30)];
        [signUpBtn setTitle:@"Sign Up" forState:UIControlStateNormal];
        signUpBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [signUpBtn addTarget:self action:@selector(SignUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signUpBtn];
        
        UIButton *signInBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30 - 64, self.frame.size.width, 30)];
        [signInBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        signInBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        [signInBtn setTitle:@"Already a quuper? Sign in here!" forState:UIControlStateNormal];
        [signInBtn addTarget:self action:@selector(SignInBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signInBtn];
        
    }
    return self;
}

- (void)createUnderlineForTextField:(UITextField *)textField
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor colorWithRed:69.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.1f].CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;
}


- (IBAction)SignUpBtnClicked:(id)sender
{
    [accountTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [[FIRAuth auth] createUserWithEmail:accountTextField.text password:passwordTextField.text completion:^(FIRUser *_Nullable user, NSError *_Nullable error){
        if (error) {
            NSLog(@"%@",error.description);
            [self.delegate DisplayAlertWithTitle:@"Error" Message:[error localizedDescription]];
        }else{
            NSLog(@"Create User %@", user.uid);
            [[[ref child:@"users"] child:user.uid] setValue:@{@"username": @"Default Username", @"email": accountTextField.text}];
            [[[ref child:@"users-detail"] child:user.uid] setValue:@{@"Rating": @"0",
                                                                     @"address": @"Default Address",
                                                                     @"email": accountTextField.text,
                                                                     @"iBorrow": @"0",
                                                                     @"iLend": @"0",
                                                                     @"name": @"Default Name",
                                                                     @"phone": @"Default Phone",
                                                                     @"text": @"Default Text",
                                                                     @"uid": user.uid,
                                                                     @"account": @{@"earned": @"0",
                                                                                   @"paid": @"0",
                                                                                   @"rate": @"0",
                                                                                   @"ratings": @"0"}}];
            
            [self.delegate SwitchToProfileViewWithUID:user.uid];
        }
    }];
}

- (IBAction)SignInBtnClicked:(id)sender
{
    NSLog(@"Switch To SignIn View");
    [self.delegate SwitchToSignInView];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
