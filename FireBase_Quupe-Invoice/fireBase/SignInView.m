//
//  SignInView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-08.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "SignInView.h"

@implementation SignInView

@synthesize ref;
@synthesize accountTextField, passwordTextField;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        ref = [[FIRDatabase database] reference];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 173)/2, 100, 173, 54)];
        logoView.image = [UIImage imageNamed:@"logoQuupeBlue"];
        [self addSubview:logoView];
        
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
        
        UIButton *signInBtn = [[UIButton alloc] initWithFrame:CGRectMake(passwordTextField.frame.origin.x, passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 10, passwordTextField.frame.size.width, 30)];
        [signInBtn setTitle:@"Sign In" forState:UIControlStateNormal];
        signInBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [signInBtn addTarget:self action:@selector(SignInBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signInBtn];
        
        UIButton *signUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30 - 64, self.frame.size.width, 30)];
        [signUpBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        signUpBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
        [signUpBtn setTitle:@"Don't have an account? Sign up here!" forState:UIControlStateNormal];
        [signUpBtn addTarget:self action:@selector(SignUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signUpBtn];
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

- (IBAction)SignInBtnClicked:(id)sender
{
    [accountTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [[FIRAuth auth] signInWithEmail:accountTextField.text password:passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Fail To Sign In.");
            NSLog(@"Account: %@", accountTextField.text);
            [self.delegate DisplayAlertWithTitle:@"Error" Message:[error localizedDescription]];
        }else{
            NSLog(@"Try Sign In As User: %@", user.uid);
            [self.delegate SwitchToProfileViewWithUID:user.uid];
        }
    }];
}

- (IBAction)SignUpBtnClicked:(id)sender
{
    NSLog(@"Switch To SignUp View");
    [self.delegate SwitchToSignUpView];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
