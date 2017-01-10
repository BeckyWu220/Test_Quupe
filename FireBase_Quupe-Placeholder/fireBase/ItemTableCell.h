//
//  ItemTableCell.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-03.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QpRatingView.h"

@interface ItemTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) QpRatingView *ratingView;

@end
