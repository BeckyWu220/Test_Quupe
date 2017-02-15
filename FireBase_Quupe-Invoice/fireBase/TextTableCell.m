//
//  TextTableCell.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-15.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "TextTableCell.h"

@interface TextTableCell ()
{
    UIColor *contentTextColor;
}

@end

@implementation TextTableCell

@synthesize contentTextView;
@synthesize delegate;
@synthesize headerLabel;
@synthesize contentTextViewHeight;
@synthesize type;
@synthesize pickerOptions;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    contentTextView.delegate = self;
    contentTextView.scrollEnabled = NO;
    //contentTextView.backgroundColor = [UIColor redColor];
    
    contentTextColor = contentTextView.textColor;
    
    //pickerOptions = @[@"Item1", @"Item2", @"Item3"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)calculateContentTextViewHeightWithText:(NSAttributedString *)text
{
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(self.contentTextView.frame.size.width, FLT_MAX)];
    
    return size.height;
}

- (void)setContentTextViewSizeToFit
{
    self.contentTextView.frame = CGRectMake(self.contentTextView.frame.origin.x, self.contentTextView.frame.origin.y, self.contentTextView.frame.size.width, contentTextViewHeight);
}

#pragma UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"Text Did Change");
    
    CGFloat calculatedTextViewHeight = [self calculateContentTextViewHeightWithText:textView.attributedText];
    
    if (calculatedTextViewHeight != contentTextViewHeight) {
        contentTextViewHeight = calculatedTextViewHeight;
        [self setContentTextViewSizeToFit];
        NSLog(@"Text View Height Change: %f", contentTextViewHeight);
        [self.delegate setTextTableCellHeight:contentTextViewHeight+5.0f ForCell:self];
    }
    [self.delegate updateTextTableCellText:self];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Did Begin Editing");
    
    if ([self.contentTextView.text isEqualToString:@"Not Specified"]) {
        self.contentTextView.text = @"";
        self.contentTextView.textColor = contentTextColor;
    }
    
    if (type == VERTICAL_DATEPICKER_TYPE || type == HORIZONTAL_DATEPICKER_TYPE) {
        [self.delegate presentDatePickerForCell:self];
    }else if (type == VERTICAL_UIPICKER_TYPE || type == HORIZONTAL_UIPICKER_TYPE){
        if (pickerOptions) {
            [self.delegate presentUIPickerViewForCell:self];
        }else{
            [self.contentTextView resignFirstResponder];//Avoid popping UIPickerView and Keyboard.
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"Should Begin Editing");
    [self.delegate updateTextTableCellText:self];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"Done");
        [self.contentTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"Did End Editing: %ld", (long)self.type);
    
    if ([self.contentTextView.text isEqualToString:@""]) {
        self.contentTextView.text = @"Not Specified";
        self.contentTextView.textColor = [UIColor lightGrayColor];
    }else{
        if (type == VERTICAL_MONEY_TYPE || type == HORIZONTAL_MONEY_TYPE){
            float moneyAmount = [self.contentTextView.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue;
            self.contentTextView.text = [NSString stringWithFormat:@"$%.2f", moneyAmount];
        }
    }
    
    [self.delegate endEditingTextTableCellText:self];
}

@end
