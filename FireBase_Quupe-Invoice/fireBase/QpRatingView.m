//
//  QpRatingView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-29.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpRatingView.h"

@interface QpRatingView ()
{
    NSMutableArray *starBtnArray;
}

@end

@implementation QpRatingView
@synthesize currentRating;

//Initialization to show a user's rating. Not interactable.
- (id)initWithFrame:(CGRect)frame Rating:(float)rating
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        self.currentRating = rating;
        [self roundRating:rating];
        
    }
    return self;
}

- (void)roundRating:(float)rating
{
    float rate = 0.0f;
    int flooredRating = rating;
    
    for (int i=0; i<5; i++) {
        UIImageView *starImgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.frame.size.width/5.0f, 0, self.frame.size.width/5.0f, self.self.frame.size.width/5.0f)];
        
        if (i < flooredRating) {
            starImgView.image = [UIImage imageNamed:@"selectedStar"];
        }else if (i == flooredRating){
            if ((rating - flooredRating) > 0.5f) {
                rate = flooredRating + 1.0f;
                starImgView.image = [UIImage imageNamed:@"selectedStar"];
            }else if ((rating - flooredRating) == 0.5f){
                rate = flooredRating + 0.5f;
                starImgView.image = [UIImage imageNamed:@"halfSelectedStar"];
            }else{
                rate = flooredRating;
                starImgView.image = [UIImage imageNamed:@"unselectedStar"];
            }
        }else{
            starImgView.image = [UIImage imageNamed:@"unselectedStar"];
        }
        
        [self addSubview:starImgView];
    }
    //NSLog(@"Rounded %f to %f", rating, rate);
}

//Initialization of Rating in ReviewViewController. Interactable.
- (id)initWithFrame:(CGRect)frame Interval:(CGFloat)interval
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(frame.origin.x - 2*interval, frame.origin.y, frame.size.width + 4*interval, frame.size.height);
        
        self.currentRating = 0;
        
        starBtnArray = [[NSMutableArray alloc] init];
        
        for (int i=0; i<5; i++) {
            UIButton *starBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*frame.size.width/5.0f + i*interval, 0, frame.size.width/5.0f, frame.size.width/5.0f)];
            [starBtn setImage:[UIImage imageNamed:@"unselectedStar"] forState:UIControlStateNormal];
            [starBtn setImage:[UIImage imageNamed:@"selectedStar"] forState:UIControlStateSelected];
            [starBtn addTarget:self action:@selector(changeStarStatus:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:starBtn];
            [starBtnArray addObject:starBtn];
        }
    }
    return self;
}

- (void)changeStarStatus:(id)sender
{
    int currentSelectedStarIndex = 0;
    
    for (int i=0; i<5; i++) {
        UIButton *star = [starBtnArray objectAtIndex:i];
        star.selected = NO;
        if (sender == [starBtnArray objectAtIndex:i]) {
            currentSelectedStarIndex = i;
        }
    }
    
    for (int j=0; j<=currentSelectedStarIndex; j++) {
        UIButton *star = [starBtnArray objectAtIndex:j];
        star.selected = YES;
    }
    
    self.currentRating = currentSelectedStarIndex + 1;
    NSLog(@"Rate %d", (int)self.currentRating);
}

@end
