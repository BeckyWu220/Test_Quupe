//
//  User.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-30.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *bio; //text in database

@property (strong, nonatomic) NSString *imgURL;

@property float rating;
/*@property int iBorrow;
@property int iLend;*/

- (id)initWithDictionary:(NSDictionary *)dic;
- (id)initWithAnonymousUser;

@end
