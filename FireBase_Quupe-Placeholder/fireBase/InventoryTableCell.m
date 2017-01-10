//
//  InventoryTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-30.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "InventoryTableCell.h"

@implementation InventoryTableCell

@synthesize itemImgView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    itemImgView.layer.cornerRadius = 4.0f;
    itemImgView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
