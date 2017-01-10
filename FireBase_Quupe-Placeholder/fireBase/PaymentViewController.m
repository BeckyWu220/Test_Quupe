//
//  PaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//


#import "ViewController.h"

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

@synthesize itemInfo;
@synthesize submitBtn;
@synthesize paymentToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Payment";
    self.totalPriceLabel.text = [itemInfo objectForKey:@"rTotal"];
    //[NSString stringWithFormat:@"$%@", self.amount];
    self.itemNameLabel.text = [itemInfo objectForKey:@"iName"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Setup cancel button
    submitBtn.enabled = NO;
    submitBtn.backgroundColor = [UIColor grayColor];

    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.backgroundColor = [UIColor whiteColor];
    NSLog(@"TEXT FIELD SIZE: %@", NSStringFromCGRect(paymentTextField.frame));
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor grayColor];
    self.paymentTextField = paymentTextField;
    [self.view addSubview:paymentTextField];
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.color = [UIColor grayColor];
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 15;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.paymentTextField.frame = CGRectMake(padding, 100, width, 44);

    self.activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    submitBtn.enabled = textField.isValid;
    if (submitBtn.enabled) {
        submitBtn.backgroundColor = [UIColor colorWithRed:16.0f/255.0f green:147.0f/255.0f blue:255.0f/255.0f alpha:1.0];
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
    [self.activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams completion:^(STPToken *token, NSError *error)
     {
         [self.activityIndicator stopAnimating];
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
