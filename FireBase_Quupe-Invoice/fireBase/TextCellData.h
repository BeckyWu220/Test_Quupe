//
//  TextCellData.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-21.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, TextCellType) {
    VERTICAL_TEXT_TYPE,
    HORIZONTAL_TEXT_TYPE,
    VERTICAL_MONEY_TYPE,
    HORIZONTAL_MONEY_TYPE,
    VERTICAL_DATEPICKER_TYPE,
    HORIZONTAL_DATEPICKER_TYPE,
    VERTICAL_UIPICKER_TYPE,
    HORIZONTAL_UIPICKER_TYPE,
};

@interface TextCellData : NSObject

//Need to create a NSObject class to hold table data. The class should contains title, content, cell height, type. The type would specify if the cell will trigger keyboard, datePicker, or other pickers.

@property (strong, nonatomic) NSString *cellTitle;
@property (strong, nonatomic) NSString *cellContent;
@property CGFloat cellHeight;
@property CGFloat cellHeaderHeight;
@property TextCellType cellType;
//NSString *cellType;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSArray *cellOptions;

- (id)initWithCellArray:(NSArray *)cellArray;


@end
