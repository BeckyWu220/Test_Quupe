//
//  QpLenderView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-06.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QpRatingView.h"
#import "User.h"
#import "QpAsyncImage.h"

@import Firebase;

@protocol QpLenderViewDelegate <NSObject>

- (void)messageLenderWithName:(NSString *)lenderName Icon:(UIImage *)lenderIcon;

@end

@interface QpLenderView : UIView

@property (strong, nonatomic) QpRatingView *ratingView;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) id<QpLenderViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame LenderName:(NSString *)lenderName LenderUID:(NSString *)lenderUID;

@end
