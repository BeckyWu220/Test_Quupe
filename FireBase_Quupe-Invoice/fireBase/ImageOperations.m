//
//  ImageOperations.m
//  quupe
//
//  Created by Wanqiao Wu on 2017-03-10.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import "ImageOperations.h"

@implementation ImageRecord

@synthesize name, url, state, image;

- (id)initWithName:(NSString *)imgName URL:(NSURL *)imgURL
{
    self = [super init];
    if (self) {
        self.name = imgName;
        self.url = imgURL;
        self.state = New;
        self.image = [UIImage imageNamed:@"default-thumbnail.jpg"];
    }
    return self;
}

@end



@implementation ImageOperations

@synthesize downloadsInProgress, downloadQueue;
@synthesize scalesInProgress, scaleQueue;

- (id)init {
    self = [super init];
    if (self) {
        downloadsInProgress = [[NSMutableDictionary alloc] init];
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.name = @"Download Queue";
        
        scalesInProgress = [[NSMutableDictionary alloc] init];
        scaleQueue = [[NSOperationQueue alloc] init];
        scaleQueue.name = @"Image Scale Queue";
    }
    return self;
}

@end


@implementation ImageDownloader

@synthesize imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord
{
    self = [super init];
    if (self) {
        self.imageRecord = imgRecord;
    }
    return self;
}

- (void) main
{
    if (self.isCancelled) {
        return;
    }
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageRecord.url];
    
    if (self.isCancelled) {
        return;
    }
    
    if (imageData && imageData.length > 0) {
        self.imageRecord.image = [UIImage imageWithData:imageData];
        self.imageRecord.state = Downloaded;
    }else {
        self.imageRecord.image = [UIImage imageNamed:@"default-profile.jpg"];
        self.imageRecord.state = Failed;
    }
    imageData = nil;
}

@end


@implementation ImageScaler

@synthesize imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord
{
    self = [super init];
    if (self) {
        self.imageRecord = imgRecord;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) {
        return;
    }
    
    if (self.imageRecord.state != Downloaded) {
        return;
    }
    
    if (self.imageRecord.image){
        UIImage *thumbnail = [self thumbnailForImage:UIImagePNGRepresentation(self.imageRecord.image)];
        if (thumbnail) {
            self.imageRecord.image = thumbnail;
            self.imageRecord.state = Scaled;
        }
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

@end


