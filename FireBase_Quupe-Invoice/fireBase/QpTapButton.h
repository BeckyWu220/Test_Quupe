//
//  QpTapButton.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-28.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QpTapButton;

@protocol QpTabButtonDelegate <NSObject>

@required
- (void)ClickQpTabButton:(QpTapButton *)button;

@end

@interface QpTapButton : UIView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *numLabel;

@property (weak, nonatomic) id <QpTabButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Title:(NSString *)title Number:(int)num;
- (void)setStatusToSelected;
- (void)setStatusToUnselected;
- (void)setNumber:(int)num;

@end
