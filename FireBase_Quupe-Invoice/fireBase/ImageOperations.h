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
    Failed
} ImageRecordState;


@interface ImageRecord : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *url;
@property ImageRecordState state;
@property (strong, nonatomic) UIImage *image;

- (id)initWithName:(NSString *)imgName URL:(NSURL *)imgURL;

@end


@interface ImageOperations : NSObject

@property (strong, nonatomic) NSMutableDictionary *downloadsInProgress;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;

@property (strong, nonatomic) NSMutableDictionary *scalesInProgress;
@property (strong, nonatomic) NSOperationQueue *scaleQueue;

@end


@interface ImageDownloader : NSOperation

@property (strong, nonatomic) ImageRecord *imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord;

@end


@interface ImageScaler : NSOperation

@property (strong, nonatomic) ImageRecord *imageRecord;

- (id)initWithImageRecord:(ImageRecord *)imgRecord;

@end
