//
//  User.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-09-30.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize uid;
@synthesize name, email, phone, address, bio;
@synthesize imgURL;
@synthesize rating;
//@synthesize iBorrow, iLend;

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.name = [dic objectForKey:@"name"];
        self.email = [dic objectForKey:@"email"];
        self.phone = [NSString stringWithFormat:@"%@", [dic objectForKey:@"phone"]];
        self.address = [dic objectForKey:@"address"];
        self.bio = [dic objectForKey:@"text"];
        self.uid = [[dic objectForKey:@"uid"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //self.rating = [[dic objectForKey:@"Rating"] floatValue];
        self.rating = [[[dic objectForKey:@"account"] objectForKey:@"rate"] floatValue];
        NSLog(@"User's Rating: %f", self.rating);
        
        if ([dic objectForKey:@"img"]) {
            self.imgURL = [dic objectForKey:@"img"];
        }else{
            self.imgURL = @"https://firebasestorage.googleapis.com/v0/b/quupe-restore.appspot.com/o/images%2FdefaultUserIcon.png?alt=media&token=38c38519-38af-43e4-9d2e-452db783eec1";
        }
        
    }
    return self;
}

- (id)initWithAnonymousUser
{
    self = [super init];
    if (self) {
        self.name = @"Anonymous User";
        self.email = @"";
        self.phone = @"";
        self.address = @"";
        self.bio = @"";
        self.uid = @"";
        self.rating = 0.0f;
        
        self.imgURL = @"";
        
        NSLog(@"ANONYMOUSE USER");
    }
    return self;
}

@end
