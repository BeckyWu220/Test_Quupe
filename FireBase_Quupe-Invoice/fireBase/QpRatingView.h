//
//  QpRatingView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QpRatingView : UIView

@property float currentRating;

- (id)initWithFrame:(CGRect)frame Rating:(float)rating;
- (id)initWithFrame:(CGRect)frame Interval:(CGFloat)interval;
- (void)roundRating:(float)rating;

@end
