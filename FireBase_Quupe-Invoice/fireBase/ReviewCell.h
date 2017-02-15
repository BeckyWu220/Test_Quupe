//
//  ReviewCell.h
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-20.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QpRatingView.h"

@interface ReviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reviewerName;
@property (weak, nonatomic) IBOutlet UILabel *reviewContent;
@property (weak, nonatomic) IBOutlet UILabel *reviewDate;
@property (nonatomic, strong) QpRatingView *ratingView;

@property CGFloat contentHeight;

- (CGFloat)calculateCellHeight;

@end
