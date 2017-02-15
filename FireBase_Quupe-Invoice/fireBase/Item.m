//
//  Item.m
//  fireBase
//
//  Created by Wanqiao Wu on 2016-09-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize key;
@synthesize category,condition,info, lender, oPrice, photo, starCount, stars, title, uid;
@synthesize transCount;
@synthesize rentDay;
//@synthesize featr, live, rentWeek;

- (id)initWithDictionary:(NSDictionary *)dic Key:(NSString *)k
{
    self = [super init];
    if (self){
        
        self.key = k;
        
        self.category = [dic objectForKey:@"category"];
        self.condition = [dic objectForKey:@"condition"];
        //self.featr
        self.info = [dic objectForKey:@"info"];
        self.lender = [dic objectForKey:@"lender"];
        //self.live
        self.oPrice = [dic objectForKey:@"oPrice"];
        self.photo = [NSURL URLWithString:[dic objectForKey:@"photo"]];
        self.rentDay = [[dic objectForKey:@"rentDay"] floatValue];
        //self.rentDay
        //self.rentWeek
        self.starCount = [[dic objectForKey:@"starCount"] floatValue];
        //self.stars = [[NSArray alloc] initWithArray:[dic objectForKey:@"stars"]];
        self.title = [dic objectForKey:@"title"];
        self.uid = [[dic objectForKey:@"uid"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        transCount = 0;
    }
    return self;
}

@end
