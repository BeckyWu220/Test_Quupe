//
//  QpTableView.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-18.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextTableCell.h"
#import "TextCellData.h"

@protocol QpTableViewDelegate <NSObject>

@required
- (void)changeScrollViewContentSizeBy:(CGFloat)tableViewChangedHeight NewTableHeight:(CGFloat)newTableViewHeight;
- (void)setScrollViewContentYOffset:(CGFloat)yOffset WithKeyboardHeight:(CGFloat)keyboardHeight;
- (void)resetScrollViewContentOffset;
- (void)updateRelatedElementsInScrollViewWithCell:(TextTableCell *)cell;

@end

@interface QpTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,TextTableCellDelegate>

@property (weak, nonatomic) id<QpTableViewDelegate> scrollDelegate;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

- (id)initWithFrame:(CGRect)frame Data:(NSArray *)dataArray;
- (NSArray *)stopEditingAndReturnCellData;

@end
