//
//  MessageTableCell.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-10.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface MessageTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seenMark;

- (void)createThumbnailIconWithURL:(NSURL *)imgURL;


@end
