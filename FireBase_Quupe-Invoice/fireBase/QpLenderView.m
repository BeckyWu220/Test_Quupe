//
//  QpLenderView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-12-06.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpLenderView.h"

@interface QpLenderView ()
{
    UILabel *nameLabel;
    QpAsyncImage *imgView;
    UIButton *msgBtn;
    
    NSString *targetUID;
}

@end

@implementation QpLenderView

@synthesize ratingView;
@synthesize ref;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame LenderName:(NSString *)lenderName LenderUID:(NSString *)lenderUID
{
    self = [super initWithFrame:frame];
    if (self) {
        targetUID = lenderUID;
        
        imgView = [[QpAsyncImage alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 48.0f, 48.0f)];
        imgView.imgName = lenderUID;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.cornerRadius = imgView.frame.size.width/2;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, 10.0f, self.frame.size.width - (imgView.frame.origin.x + imgView.frame.size.width + 10.0f) - 10.0f, 25.0f)];
        nameLabel.text = lenderName;
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:16.0f];
        nameLabel.textColor = [UIColor colorWithRed:109.0f/255.0f green:109.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
        [self addSubview:nameLabel];
        
        msgBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height*0.3 -10.0f, self.frame.size.height*0.35, self.frame.size.height*0.3, self.frame.size.height*0.3)];
        [msgBtn setImage:[UIImage imageNamed:@"msgIcon"] forState:UIControlStateNormal];
        [msgBtn addTarget:self action:@selector(msgBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:msgBtn];
        
        ref = [[FIRDatabase database] reference];
        
        [[[ref child:@"users-detail"] child:lenderUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
            
            if (snapshot.exists) {
                NSDictionary *retrieveDataDict = snapshot.value;
                User *lender = [[User alloc] initWithDictionary:retrieveDataDict];
                NSLog(@"LENDER: %@, Rating: %f", lender.name, lender.rating);
                
                [imgView loadImageFromURL:[NSURL URLWithString:lender.imgURL]];
                
                ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5.0f, 12.0f*5, 12.0f) Rating:lender.rating];
                [self addSubview:ratingView];
            }else{
                NSLog(@"Snapshot Not Exist in users-detail->lenderUID of QpLenderView.");
            }
            
        }];
        
        
    }
    return self;
}

- (void)msgBtnClicked
{
    [self.delegate messageLenderWithName:nameLabel.text Icon:imgView.thumbnailImg];
}

@end
