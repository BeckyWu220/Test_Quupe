//
//  QpButton.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-15.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QpButtonDelegate <NSObject>

@required

- (void) ClickQpButtonWithTitle:(NSString *)title;

@optional

@end

@interface QpButton : UIButton

@property (strong, nonatomic) NSString *titleText;

@property (weak, nonatomic) id <QpButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Title:(NSString *)title;

@end
