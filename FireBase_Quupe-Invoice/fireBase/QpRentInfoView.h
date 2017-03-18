//
//  QpRentInfoView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-26.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QpAsyncImage.h"

@interface QpRentInfoView : UIView

- (id)initWithFrame:(CGRect)frame ItemName:(NSString *)itemName ItemKey:(NSString *)itemKey RentalPrice:(float)rentalPrice RentRange:(NSString *)rentRange PhotoURL:(NSURL *)photoURL;

@end
