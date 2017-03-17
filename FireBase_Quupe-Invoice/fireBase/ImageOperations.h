//
//  ImageOperations.h
//  quupe
//
//  Created by Wanqiao Wu on 2017-03-10.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

typedef enum : NSUInteger {
    New = 0,
    Downloaded,
    Scaled,
    Saved,
    Read,
    Failed
} ImageRecordState;


@interface ImageRecord : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *filePath;
@property ImageRecordState state;
@property (strong, nonatomic) UIImage *image;

- (id)initWithName:(NSString *)imgName URL:(NSURL *)imgURL;
- (id)initWithName:(NSString *)imgName filePath:(NSString *)filePath;

@end


@interface ImageOperations : NSObject

@property (strong, nonatomic) NSMutableDictionary *downloadsInProgress;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;

@property (strong, nonatomic) NSMutableDictionary *scalesInProgress;
@property (strong, nonatomic) NSOperationQueue *scaleQueue;

@property (strong, nonatomic) NSMutableDictionary *readsInProgress;
@property (strong, nonatomic) NSOperationQueue *readQueue;

@end


@interface ImageDownloader : NSOperation

@property (strong, nonatomic) ImageRecord *imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord;

@end


@interface ImageScaler : NSOperation

@property (strong, nonatomic) ImageRecord *imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord;

@end

@interface ImageReader : NSOperation

@property (strong, nonatomic) ImageRecord *imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord;

@end
