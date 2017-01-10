//
//  QpLenderView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-06.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "QpRatingView.h"
#import "User.h"


@import Firebase;

@interface QpLenderView : UIView

@property (strong, nonatomic) QpRatingView *ratingView;

@property (strong, nonatomic) FIRDatabaseReference *ref;

- (id)initWithFrame:(CGRect)frame LenderName:(NSString *)lenderName LenderUID:(NSString *)lenderUID;

@end
