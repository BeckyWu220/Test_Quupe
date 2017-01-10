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
    UIImageView *imgView;
}

@end

@implementation QpLenderView

@synthesize ratingView;
@synthesize ref;

- (id)initWithFrame:(CGRect)frame LenderName:(NSString *)lenderName LenderUID:(NSString *)lenderUID
{
    self = [super initWithFrame:frame];
    if (self) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 48.0f, 48.0f)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.backgroundColor = [UIColor grayColor];
        imgView.layer.cornerRadius = imgView.frame.size.width/2;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10.0f, 10.0f, self.frame.size.width - (imgView.frame.origin.x + imgView.frame.size.width + 10.0f) - 10.0f, 25.0f)];
        nameLabel.text = lenderName;
        nameLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:16.0f];
        nameLabel.textColor = [UIColor colorWithRed:109.0f/255.0f green:109.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
        [self addSubview:nameLabel];
        
        ref = [[FIRDatabase database] reference];
        
        [[[ref child:@"users-detail"] child:lenderUID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
            NSDictionary *retrieveDataDict = snapshot.value;
            User *lender = [[User alloc] initWithDictionary:retrieveDataDict];
            NSLog(@"LENDER: %@, Rating: %f", lender.name, lender.rating);
            
            [self loadImageFromURL:[NSURL URLWithString:lender.imgURL]];
            
            ratingView = [[QpRatingView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5.0f, 12.0f*5, 12.0f) Rating:lender.rating];
            [self addSubview:ratingView];
        }];
        
        
    }
    return self;
}

- (void)loadImageFromURL:(NSURL *)photoURL
{
    imgView.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //Background Thread --- Loading images.
        NSData *imgData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Run UI Updates
            imgView.image = [self thumbnailForImage:imgData];
            
        });
    });
}

- (UIImage *)thumbnailForImage:(NSData *)imgData
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imgData, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,(NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:300],(NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,});
    CFRelease(source);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

@end
