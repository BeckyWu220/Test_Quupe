//
//  QpTapButton.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-28.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpTapButton.h"

@implementation QpTapButton

@synthesize titleLabel, numLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame Title:(NSString *)title Number:(int)num
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/5, self.frame.size.width, self.frame.size.height/5*2)];
        numLabel.text = [NSString stringWithFormat:@"%d", num];
        numLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:186.0/255.0 alpha:1.0f];
        [self addSubview:numLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/5*3, self.frame.size.width, self.frame.size.height/5*1.5)];
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:13.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:186.0/255.0 alpha:1.0f];
        [self addSubview:titleLabel];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beClicked)];
        tapRecognizer.delegate = self;
        [self addGestureRecognizer:tapRecognizer];
        
    }
    return self;
}

- (void)beClicked
{
    numLabel.textColor = [UIColor colorWithRed:67.0f/255.0f green:169.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    titleLabel.textColor = numLabel.textColor;
    
    [self.delegate ClickQpTabButton:self];
}

- (void)setStatusToSelected
{
    numLabel.textColor = [UIColor colorWithRed:67.0f/255.0f green:169.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    titleLabel.textColor = numLabel.textColor;
}

- (void)setStatusToUnselected
{
    numLabel.textColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:186.0/255.0 alpha:1.0f];
    titleLabel.textColor = numLabel.textColor;
}

- (void)setNumber:(int)num
{
    numLabel.text = [NSString stringWithFormat:@"%d", num];
}

@end
