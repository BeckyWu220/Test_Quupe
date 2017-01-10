//
//  MessageTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-10.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "MessageTableCell.h"

@implementation MessageTableCell

@synthesize userIcon;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    userIcon.layer.cornerRadius = userIcon.frame.size.height/2;
    userIcon.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createThumbnailIconWithURL:(NSURL *)imgURL
{
    userIcon.image = [UIImage imageNamed:@"default-profile.jpg"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Background Thread --- Loading images.
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Run UI Updates
            userIcon.image = [self thumbnailForImage:imgData];
        });
    });
}

- (UIImage *)thumbnailForImage:(NSData *)imgData
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imgData, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,(NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:100],(NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,});
    CFRelease(source);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

@end
