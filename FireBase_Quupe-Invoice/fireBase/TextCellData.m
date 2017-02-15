//
//  TextCellData.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-21.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "TextCellData.h"

@implementation TextCellData

@synthesize cellTitle, cellContent;
@synthesize cellHeight;
@synthesize cellType;
@synthesize cellHeaderHeight;
@synthesize cellIdentifier;
@synthesize cellOptions;

- (id)initWithCellArray:(NSArray *)cellArray
{
    self = [super init];
    if (self) {
        self.cellTitle = [cellArray objectAtIndex:0];
        self.cellContent = [cellArray objectAtIndex:1];
        self.cellType = [[cellArray objectAtIndex:2] integerValue];
        
        if (self.cellType == HORIZONTAL_UIPICKER_TYPE || self.cellType == VERTICAL_UIPICKER_TYPE) {
            if (cellArray.count > 3) {
                self.cellOptions = [NSArray arrayWithArray:[cellArray objectAtIndex:3]];
            }else{
                NSLog(@"CELL OPTIONS ARE MISSING IN CELL WHOSE TITLE IS %@", cellTitle);
            }
        }else{
            self.cellOptions = nil;
        }
        
        //TextCellType textCellType = ;
        switch (self.cellType) {
            case VERTICAL_TEXT_TYPE:
                self.cellHeaderHeight = 34.0f;
                self.cellIdentifier = @"TextTableCell2";
                break;
            case HORIZONTAL_TEXT_TYPE:
                self.cellHeaderHeight = 0.0f;//In Horizontal Mode, the headerHeight doesn't effect the height of cell. Set it to zero in order to unify calculation formula.
                self.cellIdentifier = @"TextTableCell1";
                break;
            case VERTICAL_MONEY_TYPE:
                self.cellHeaderHeight = 34.0f;
                self.cellIdentifier = @"TextTableCell2";
                break;
            case HORIZONTAL_MONEY_TYPE:
                self.cellHeaderHeight = 0.0f;
                self.cellIdentifier = @"TextTableCell1";
                break;
            case VERTICAL_DATEPICKER_TYPE:
                self.cellHeaderHeight = 34.0f;
                self.cellIdentifier = @"TextTableCell2";
                break;
            case HORIZONTAL_DATEPICKER_TYPE:
                self.cellHeaderHeight = 0.0f;
                self.cellIdentifier = @"TextTableCell1";
                break;
            case VERTICAL_UIPICKER_TYPE:
                self.cellHeaderHeight = 34.0f;
                self.cellIdentifier = @"TextTableCell2";
                break;
            case HORIZONTAL_UIPICKER_TYPE:
                self.cellHeaderHeight = 0.0f;
                self.cellIdentifier = @"TextTableCell1";
                break;
            default:
                //Defaultly, cellType is VERTICAL_TEXT_TYPE.
                self.cellHeaderHeight = 34.0f;
                self.cellIdentifier = @"TextTableCell2";
                break;
        }
        
        self.cellHeight = 0.0f;
    }
    return self;
}



@end
