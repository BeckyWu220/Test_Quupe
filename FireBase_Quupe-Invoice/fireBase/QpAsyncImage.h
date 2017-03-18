//
//  QpAsyncImage.h
//  quupe
//
//  Created by Wanqiao Wu on 2017-01-15.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QpAsyncImage : UIImageView

@property (strong, nonatomic) NSURL *imageURL;
@property BOOL imgLoaded;
@property (strong, nonatomic) UIImage *thumbnailImg;
@property (strong, nonatomic) NSString *imgName;

- (id)initWithImageView:(UIImageView *)imgView;
- (void)loadImageFromURL:(NSURL *)imgURL;

@end
