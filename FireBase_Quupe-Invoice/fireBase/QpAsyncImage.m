//
//  QpAsyncImage.m
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-15.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "QpAsyncImage.h"
#import <ImageIO/ImageIO.h>

@implementation QpAsyncImage

@synthesize imageURL;
@synthesize imgLoaded;
@synthesize thumbnailImg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
        self.imgLoaded = NO;
        self.thumbnailImg = [UIImage imageNamed:@"default-thumbnail.jpg"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
        self.imgLoaded = NO;
        self.thumbnailImg = [UIImage imageNamed:@"default-thumbnail.jpg"];
    }
    return self;
}

- (void)loadImageFromURL:(NSURL *)imgURL
{
    if (!self.imgLoaded && imgURL) {
        NSLog(@"Load Image From URL: %@", imgURL);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            //Background Thread --- Loading images.
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            if (imgData) {
                UIImage *thumbnail = [self thumbnailForImage:imgData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Run UI Updates
                    if (thumbnail) {
                        self.image = thumbnail;
                        self.imgLoaded = YES;
                        self.thumbnailImg = thumbnail;
                    }else{
                        NSLog(@"No Thumbnail Generated.");
                    }
                    
                });
            }else {
                NSLog(@"No Image Data");
            }
        });
    }else if (self.imgLoaded){
        NSLog(@"Already Loaded Image");
        self.image = self.thumbnailImg;
    }
    
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

- (void)dealloc
{
    NSLog(@"Dealloc QpAsyncImage.");
}

@end
