//
//  QpTableView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-18.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpTableView.h"

@interface QpTableView ()
{
    NSMutableArray *tableData;
    CGFloat keyboardHeight;
    CGFloat cellMargin;
}
@end

@implementation QpTableView

@synthesize scrollDelegate;
@synthesize currentIndexPath;

- (id)initWithFrame:(CGRect)frame Data:(NSArray *)dataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        
        self.delegate = self;
        self.dataSource = self;
        
        self.allowsSelection = NO;
        self.scrollEnabled = NO;
        
        self.contentSize = self.frame.size;
        
        tableData = [[NSMutableArray alloc] init];
        
        for (int i=0; i<dataArray.count; i++) {
            NSArray *cellArray = [dataArray objectAtIndex:i];
            TextCellData *cellData = [[TextCellData alloc] initWithCellArray:cellArray];
            NSLog(@"Cell Options: %@", cellData.cellOptions);
            [tableData addObject: cellData];
        }
        
        keyboardHeight = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        cellMargin = 5.0f;
        
        self.layoutMargins = self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)updateTableViewSize
{
    CGFloat tableViewHeight = 0;
    for (int i=0; i<tableData.count; i++) {
        TextCellData *cellData = [tableData objectAtIndex:i];
        tableViewHeight += cellData.cellHeight;
        tableViewHeight += 2 * cellMargin;
    }
    
    [self.scrollDelegate changeScrollViewContentSizeBy: self.frame.size.height - tableViewHeight NewTableHeight:tableViewHeight];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tableViewHeight);
    self.contentSize = CGSizeMake(self.frame.size.width, tableViewHeight);

}

- (void)calculateDeltaHeight
{
    [self updateTableViewSize];
    
    if (keyboardHeight > 0) {
        CGRect cellRect = [self convertRect:[self rectForRowAtIndexPath:currentIndexPath] toView:self.superview];
        
        NSLog(@"Cell Rect: %@", NSStringFromCGRect(cellRect));
        
        CGFloat deltaHeight = keyboardHeight - (self.superview.frame.size.height - (cellRect.origin.y+cellRect.size.height));
        
        NSLog(@"Delta Height: %f", deltaHeight);
        
        [self.scrollDelegate setScrollViewContentYOffset:deltaHeight WithKeyboardHeight:keyboardHeight];
    }else{
        [self.scrollDelegate resetScrollViewContentOffset];
    }
}

- (NSArray *)stopEditingAndReturnCellData
{
//    TextTableCell *cell = [self cellForRowAtIndexPath:currentIndexPath];
//    [self setTextTableCellHeight:cell.contentTextViewHeight ForCell:cell];
//    [cell.contentTextView resignFirstResponder];
    
    //Return an array that contains all cells' headerLabel.text and contextTextView.text
    NSMutableArray *cellDataArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<tableData.count; i++) {
        TextCellData *cellData = [tableData objectAtIndex:i];
        [cellDataArray addObject:@{cellData.cellTitle : cellData.cellContent}];
        NSLog(@"stop edit: %@, %@", cellData.cellTitle, cellData.cellContent);
    }
    
    return cellDataArray;
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 100;

    if ([tableData objectAtIndex:indexPath.row]) {
        TextCellData *cellData = [tableData objectAtIndex:indexPath.row];
        cellHeight = cellData.cellHeight + 2 * cellMargin;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextCellData *cellData = [tableData objectAtIndex:indexPath.row];
    
    TextTableCell *cell = (TextTableCell *)[tableView dequeueReusableCellWithIdentifier:cellData.cellIdentifier];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellData.cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.delegate = self;
    }
    
    cell.headerLabel.text = cellData.cellTitle;
    //cell.headerLabel.backgroundColor = [UIColor greenColor];
    cell.contentTextView.text = cellData.cellContent;
    if ([cell.contentTextView.text isEqualToString: @"Not Specified"]) {
        cell.contentTextView.textColor = [UIColor lightGrayColor];
    }
    cell.contentTextViewHeight = [cell calculateContentTextViewHeightWithText:cell.contentTextView.attributedText];
    cell.type = cellData.cellType;
    if (cell.type == VERTICAL_MONEY_TYPE || cell.type == HORIZONTAL_MONEY_TYPE) {
        cell.contentTextView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    cell.pickerOptions = cellData.cellOptions;
        
    if (cell.type == VERTICAL_DATEPICKER_TYPE || cell.type == HORIZONTAL_DATEPICKER_TYPE || cell.type == VERTICAL_UIPICKER_TYPE || cell.type == HORIZONTAL_UIPICKER_TYPE) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    }
    
    [cell setContentTextViewSizeToFit];
    
    cellData.cellHeight = cell.contentTextViewHeight + cellData.cellHeaderHeight;
    
    [self updateTableViewSize];
    //cell.contentTextView.backgroundColor = [UIColor redColor];
    return cell;
}

#pragma TextTableCellDelegate

- (void)setTextTableCellHeight:(CGFloat)height ForCell:(TextTableCell *)cell
{
    currentIndexPath = [self indexPathForCell:cell];
    
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    cellData.cellHeight = cell.contentTextViewHeight + cellData.cellHeaderHeight;
    
    [self calculateDeltaHeight];
    
    //[tableView reloadData];
    [self beginUpdates];
    [self endUpdates];
    
    NSLog(@"Adjust Parent Table View.");
}

- (void)updateTextTableCellText:(TextTableCell *)cell
{
    currentIndexPath = [self indexPathForCell:cell];
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    cellData.cellContent = cell.contentTextView.text;
}

#pragma Keyboard Event
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"Keyboard Height: %f", keyboardSize.height);
    
    keyboardHeight = keyboardSize.height;
    [self calculateDeltaHeight];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    //self.scrollEnabled = NO;
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardHeight = 0;
    [self calculateDeltaHeight];
}

#pragma DatePicker
- (void)presentDatePickerForCell:(TextTableCell *)cell
{
    currentIndexPath = [self indexPathForCell:cell];
    
    NSDate *selectedDate;
    if ([cell.contentTextView.text isEqualToString:@""]) {
        selectedDate = [NSDate date];//today
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d (EEE), yyyy"];
        selectedDate = [dateFormatter dateFromString:cell.contentTextView.text];
        if (selectedDate == nil) {
            selectedDate = [NSDate date];
        }
    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [NSDate date];//today
    datePicker.date = selectedDate;
    cell.contentTextView.text = [self formatDate:selectedDate];
    [cell textViewDidChange:cell.contentTextView];//Manually call this delegate method to update cell height.
    [datePicker addTarget:self action:@selector(updateContentTextViewFromDatePicker:) forControlEvents:UIControlEventValueChanged];
    [cell.contentTextView setInputView:datePicker];
    [cell.contentTextView setInputAccessoryView:[self toolBarForPicker]];
    [cell.contentTextView reloadInputViews];
}

- (void)updateContentTextViewFromDatePicker:(id)sender
{
    TextTableCell *cell = [self cellForRowAtIndexPath:currentIndexPath];
    
    cell.contentTextView.text = [self formatDate:[sender date]];
    [cell textViewDidChange:cell.contentTextView];//Manually call this delegate method to update cell height.
}

- (void)endEditingTextTableCellText:(TextTableCell *)cell
{
    [self.scrollDelegate updateRelatedElementsInScrollViewWithCell:cell];
}

- (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d (EEE), yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

#pragma UIPickerView and UIPickerViewDelegate
- (void)presentUIPickerViewForCell:(TextTableCell *)cell
{
    currentIndexPath = [self indexPathForCell:cell];
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    
    if ([cell.contentTextView.text isEqualToString:@""]) {
        [pickerView selectRow:0 inComponent:0 animated:NO];
    }else{
        for (int i=0; i<cellData.cellOptions.count; i++) {
            if ([cell.contentTextView.text isEqualToString:[cellData.cellOptions objectAtIndex:i]]) {
                [pickerView selectRow:i inComponent:0 animated:NO];
            }
        }
    }
    cell.contentTextView.text = [cellData.cellOptions objectAtIndex:[pickerView selectedRowInComponent:0]];
    [cell textViewDidChange:cell.contentTextView];//Manually call this delegate method to update cell height.
    
    [cell.contentTextView setInputView:pickerView];
    [cell.contentTextView setInputAccessoryView:[self toolBarForPicker]];
    [cell.contentTextView reloadInputViews];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    return cellData.cellOptions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    return [cellData.cellOptions objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    TextTableCell *cell = [self cellForRowAtIndexPath:currentIndexPath];
    TextCellData *cellData = [tableData objectAtIndex:currentIndexPath.row];
    
    cell.contentTextView.text = [cellData.cellOptions objectAtIndex:row];
    [cell textViewDidChange:cell.contentTextView];//Manually call this delegate method to update cell height.
}

- (UIToolbar *)toolBarForPicker
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 42)];
    UIBarButtonItem *spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPicker)];
    [toolBar setItems:[NSArray arrayWithObjects:spaceBtn, doneBtn, nil]];
    
    return toolBar;
}

- (void)dismissPicker
{
    TextTableCell *cell = [self cellForRowAtIndexPath:currentIndexPath];
    [cell.contentTextView resignFirstResponder];
}

@end
