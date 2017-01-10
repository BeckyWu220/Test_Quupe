//
//  ItemTableCell.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-03.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "ItemTableCell.h"

@implementation ItemTableCell

@synthesize nameLabel, priceLabel, thumbnailImageView;
@synthesize ratingView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    thumbnailImageView.layer.cornerRadius = 6.0f;
    thumbnailImageView.clipsToBounds = YES;

    ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(10.0f, priceLabel.frame.origin.y + priceLabel.frame.size.height, 12.0f*5, 12.0f) Rating:4.5];
    [self addSubview:ratingView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
