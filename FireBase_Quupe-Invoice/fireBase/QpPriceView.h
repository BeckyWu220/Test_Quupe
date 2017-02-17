//
//  QpPriceView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-17.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface QpPriceView : UIView

@property float rentalDay;
@property float rentalWeek;
@property float rentalMonth;

- (void)calculateQuupePriceForItem:(Item *)item;
- (void)calculateQuupePriceWithOriginalPrice:(float)oPrice Category:(NSString *)category;

@end
