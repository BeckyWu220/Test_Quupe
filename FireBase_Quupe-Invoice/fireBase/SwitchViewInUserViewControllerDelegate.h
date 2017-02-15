//
//  SwitchViewInUserViewControllerDelegate.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-08.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@protocol SwitchViewInUserViewControllerDelegate <NSObject>

@required

- (void)SwitchToProfileViewWithUID: (NSString *)uid;
- (void)SwitchToSignInView;
- (void)SwitchToSignUpView;

- (void)SwitchToReviewViewFromProfileForItem:(NSString *)itemKey TargetUID:(NSString *)targetUID;
- (void)SwitchToCheckoutViewFromProfileWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo;
- (void)SwitchToInvoiceViewFromProfileForItem:(NSString *)itemKey;

- (void)SwitchToItemInfoFromProfileWithItem:(Item *)item;

- (void)SwitchToFeedbackView;

@optional

- (void)DisplayAlertWithTitle:(NSString *)title Message:(NSString *)message;

@end
