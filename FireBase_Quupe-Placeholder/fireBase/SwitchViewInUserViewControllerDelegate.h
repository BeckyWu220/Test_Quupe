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

- (void)SwitchToReviewViewFromProfile;
- (void)SwitchToCheckoutViewFromProfileWithPrice:(NSDecimalNumber *)price ItemInfo:(NSDictionary *)itemInfo;

- (void)SwitchToItemInfoFromProfileWithItem:(Item *)item;

@optional

@end
