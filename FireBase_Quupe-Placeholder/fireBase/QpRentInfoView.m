//
//  QpRentInfoView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-26.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpRentInfoView.h"

@implementation QpRentInfoView

- (id)initWithFrame:(CGRect)frame ItemName:(NSString *)itemName RentalPrice:(float)rentalPrice RentRange:(NSString *)rentRange
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width*0.3-5*2, self.frame.size.height - 5*2)];
        imgView.backgroundColor = [UIColor grayColor];
        [self addSubview:imgView];
        
        for (int i=0; i<3; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.3, 20*i+5*(i+1), self.frame.size.width*0.7-5, 20)];
            switch (i) {
                case 0:
                    label.text = itemName;
                    label.font = [UIFont systemFontOfSize:20.0f];
                    break;
                case 1:
                    label.text = [NSString stringWithFormat:@"$%.2f", rentalPrice];
                    label.font = [UIFont systemFontOfSize:14.0f];
                    break;
                case 2:
                    label.text = rentRange;
                    label.font = [UIFont systemFontOfSize:14.0f];
                    break;
                default:
                    break;
            }
            [self addSubview:label];
        }
    }
    return self;
}

@end
