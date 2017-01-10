//
//  QpBreakdownView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-24.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BreakdownTableCell.h"

@interface QpBreakdownView : UITableView <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame RentalPrice:(float)itemRentalPrice;

- (void)setDeliveryPrice:(float)price;
- (void)setInsurancePrice:(float)price;

@end
