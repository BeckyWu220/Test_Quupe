//
//  Item.h
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (strong, nonatomic) NSString *key;

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSString *featr;//Not sure what does this represent?
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *lender;
@property (strong, nonatomic) NSString *live;//Not sure what does this represent?
@property (strong, nonatomic) NSString *oPrice;
@property (strong, nonatomic) NSURL *photo;
@property float rentDay;
@property int rentWeek;//Not sure what does this represent?
@property float starCount;
@property (strong, nonatomic) NSArray *stars;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *uid;//lender's uid

@property int transCount;

- (id)initWithDictionary:(NSDictionary *)dic Key:(NSString *)k;

@end
