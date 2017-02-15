//
//  MessageTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-10.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "MessageTableCell.h"

@implementation MessageTableCell

@synthesize userIcon;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    userIcon.layer.cornerRadius = userIcon.frame.size.height/2;
    userIcon.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createThumbnailIconWithURL:(NSURL *)imgURL
{
    [userIcon loadImageFromURL:imgURL];
}

@end
