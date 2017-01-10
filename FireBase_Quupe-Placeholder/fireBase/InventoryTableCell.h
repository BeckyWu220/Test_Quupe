//
//  InventoryTableCell.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-30.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemRentLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTransNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImgView;

@end
