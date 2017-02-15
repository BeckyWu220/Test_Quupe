//
//  ReviewCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-20.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell
@synthesize reviewerName, reviewContent;
@synthesize contentHeight;
@synthesize ratingView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    reviewContent.numberOfLines = 0;
    contentHeight = 20.0f;
    
    ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(reviewerName.frame.origin.x, reviewerName.frame.origin.y + reviewerName.frame.size.height, 10.0f*5, 10.0f) Rating:4.5];
    [self addSubview:ratingView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)calculateCellHeight
{
    CGSize size = [reviewContent sizeThatFits:CGSizeMake(reviewContent.frame.size.width, FLT_MAX)];
    reviewContent.frame = CGRectMake(reviewContent.frame.origin.x, reviewContent.frame.origin.y, reviewContent.frame.size.width, size.height);
    NSLog(@"Review Cell Height: %f", reviewContent.frame.size.height);
    
    contentHeight = reviewContent.frame.size.height;
    if (contentHeight < 20) {
        contentHeight = 20;
    }
    return contentHeight + 45.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
