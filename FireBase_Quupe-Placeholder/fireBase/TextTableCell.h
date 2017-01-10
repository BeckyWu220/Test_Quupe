//
//  TextTableCell.h
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-15.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextCellData.h"

@class TextTableCell;

@protocol TextTableCellDelegate <NSObject>

@required
- (void)setTextTableCellHeight:(CGFloat)height ForCell:(TextTableCell *)cell;
- (void)updateTextTableCellText:(TextTableCell *)cell;
- (void)endEditingTextTableCellText:(TextTableCell *)cell;

- (void)presentDatePickerForCell:(TextTableCell *)cell;
- (void)presentUIPickerViewForCell:(TextTableCell *)cell;

@end

@interface TextTableCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property CGFloat contentTextViewHeight;

@property TextCellType type;
@property (strong, nonatomic) NSArray *pickerOptions;

@property (weak, nonatomic) id <TextTableCellDelegate> delegate;

- (CGFloat)calculateContentTextViewHeightWithText:(NSAttributedString *)text;
- (void)setContentTextViewSizeToFit;
- (void)textViewDidChange:(UITextView *)textView;

@end
