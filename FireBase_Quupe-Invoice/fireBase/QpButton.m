//
//  QpButton.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-15.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpButton.h"

@implementation QpButton

@synthesize titleText;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame Title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:[UIColor colorWithRed:67.0/255.0 green:169.0/255.0 blue:242.0/255.0 alpha:1.0f].CGColor];
        self.layer.cornerRadius = 4.0f;
        self.clipsToBounds = YES;
        
        [self setTitle:title forState:UIControlStateNormal];
        titleText = title;
        
        [self setTitleColor:[UIColor colorWithRed:67.0/255.0 green:169.0/255.0 blue:242.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        
        self.titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:13.0f];
        
        [self addTarget:self.delegate action:@selector(ButtonIsClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)ButtonIsClicked
{
    [self.delegate ClickQpButtonWithTitle:titleText];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
