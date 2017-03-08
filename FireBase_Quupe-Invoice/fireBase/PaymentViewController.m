//
//  PaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//


#import "PaymentViewController.h"

@interface PaymentViewController ()
{
    UILabel *totalPriceLabel;
    UILabel *priceTitleLabel;
    
    UILabel *itemTitleLabel;
    UILabel *itemNameLabel;
    
    UIButton *submitBtn;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation PaymentViewController

@synthesize itemInfo;
@synthesize paymentToken;

- (id)initWithItemInfo:(NSDictionary *)info Price:(NSDecimalNumber *)price
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.navigationItem.title = @"Payment";
        
        self.itemInfo = info;
        self.amount = price;
        
        itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 74.0f, 50.0f, 20.0f)];
        itemTitleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        itemTitleLabel.text = @"Name: ";
        itemTitleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        //itemTitleLabel.backgroundColor = [UIColor greenColor];
        [self.view addSubview:itemTitleLabel];
        
        itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemTitleLabel.frame.origin.x + itemTitleLabel.frame.size.width, 74.0f, self.view.frame.size.width - 70.0f, 20.0f)];
        itemNameLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        itemNameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        //itemNameLabel.backgroundColor = [UIColor greenColor];
        [self.view addSubview:itemNameLabel];
        
        
        priceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, itemTitleLabel.frame.origin.y + itemTitleLabel.frame.size.height + 10.0f, 50.0f, 20.0f)];
        priceTitleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        priceTitleLabel.text = @"Total: ";
        priceTitleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        //priceTitleLabel.backgroundColor = [UIColor greenColor];
        [self.view addSubview:priceTitleLabel];
        
        totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceTitleLabel.frame.origin.x + priceTitleLabel.frame.size.width, priceTitleLabel.frame.origin.y, self.view.frame.size.width - 70.0f, 20.0f)];
        totalPriceLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
        totalPriceLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        //totalPriceLabel.backgroundColor = [UIColor greenColor];
        [self.view addSubview:totalPriceLabel];

        
        totalPriceLabel.text = [itemInfo objectForKey:@"rTotal"];
        itemNameLabel.text = [itemInfo objectForKey:@"iName"];
        
        // Setup payment view
        STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
        paymentTextField.backgroundColor = [UIColor whiteColor];
        NSLog(@"TEXT FIELD SIZE: %@", NSStringFromCGRect(paymentTextField.frame));
        paymentTextField.delegate = self;
        paymentTextField.cursorColor = [UIColor grayColor];
        self.paymentTextField = paymentTextField;
        [self.view addSubview:paymentTextField];
        
        CGFloat padding = 15;
        CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
        self.paymentTextField.frame = CGRectMake(padding, totalPriceLabel.frame.origin.y +
                                                 totalPriceLabel.frame.size.height + 10.0f, width, 44);
        
        submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, paymentTextField.frame.origin.y+paymentTextField.frame.size.height + 10.0f, [[UIScreen mainScreen] bounds].size.width, 35.0f)];
        submitBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
        [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(SubBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:submitBtn];
        
        // Setup cancel button
        submitBtn.enabled = NO;
        submitBtn.backgroundColor = [UIColor grayColor];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.color = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    [self.view addSubview:activityIndicator];
    
    activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    submitBtn.enabled = textField.isValid;
    if (submitBtn.enabled) {
        submitBtn.backgroundColor = [UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f];
    }
}

- (IBAction)SubBtnClicked:(id)sender
{
    if (![self.paymentTextField isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain code:STPInvalidRequestError userInfo:@{
                                                                                                      NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"}];
        [self.delegate paymentViewController:self didFinish:error];
        return;
    }
    submitBtn.hidden = YES;
    [self.paymentTextField resignFirstResponder];
    self.paymentTextField.enabled = NO;
    [activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams completion:^(STPToken *token, NSError *error)
     {
         [activityIndicator stopAnimating];
         if (error) {
             [self.delegate paymentViewController:self didFinish:error];
         }
         
         [self createBackendChargeWithToken:token completion:^(STPBackendChargeResult result, NSError *error)
          {
              if (error) {
                  [self.delegate paymentViewController:self didFinish:error];
                  return;
              }
              paymentToken = token;
              NSLog(@"Payment Token:%@, %@", paymentToken.tokenId, paymentToken);
              [self.delegate paymentViewController:self didFinish:nil];
          }];
     }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion
{
    NSString *BackendChargeURLString = @"https://quupetest.herokuapp.com";
    if (!BackendChargeURLString)
    {
        NSError *error = [NSError errorWithDomain:StripeDomain code:STPInvalidRequestError userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "@"instructions in the README to set up an example backend, or use this "@"token to manually create charges at dashboard.stripe.com .",token.tokenId]}];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *urlString = [BackendChargeURLString stringByAppendingPathComponent:@"charge_card"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"stripe_token=%@&amount=%@", token.tokenId, @1000];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode != 200) {
            error = [NSError errorWithDomain:StripeDomain
                                        code:STPInvalidRequestError
                                    userInfo:@{NSLocalizedDescriptionKey: @"There was an error connecting to your payment backend."}];
        }
        if (error) {
            completion(STPBackendChargeResultFailure, error);
        } else {
            completion(STPBackendChargeResultSuccess, nil);
        }
    }];
    
    [uploadTask resume];
}



@end
