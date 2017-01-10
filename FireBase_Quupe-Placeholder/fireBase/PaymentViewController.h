//
//  PaymentViewController.h
//  Stripe
//
//  Created by Alex MacCaw on 3/4/13.
//
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>

@class PaymentViewController;

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPTokenSubmissionHandler)(STPBackendChargeResult status, NSError *error);


@protocol PaymentViewControllerDelegate<NSObject>

- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error;

@end

@interface PaymentViewController : UIViewController <STPPaymentCardTextFieldDelegate>

@property (strong, nonatomic) NSDictionary *itemInfo;

@property (nonatomic) NSDecimalNumber *amount;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (nonatomic, weak) id<PaymentViewControllerDelegate> delegate;

@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) STPToken *paymentToken;

@end
