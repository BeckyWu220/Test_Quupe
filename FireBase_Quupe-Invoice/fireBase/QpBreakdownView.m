//
//  QpBreakdownView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-24.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpBreakdownView.h"

@interface QpBreakdownView ()
{
    NSMutableArray *tableData;
}
@end

@implementation QpBreakdownView

- (id)initWithFrame:(CGRect)frame RentalPrice:(float)itemRentalPrice
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.delegate = self;
        self.dataSource = self;
        
        self.allowsSelection = NO;
        self.scrollEnabled = NO;
        
        self.contentSize = self.frame.size;
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44.0f)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, headerView.frame.size.width - 5*2, headerView.frame.size.height)];
        headerLabel.text = @"Price Breakdown";
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:16.0f];
        headerLabel.textColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0f];
        
        [headerView addSubview:headerLabel];
        self.tableHeaderView = headerView;
        
        
        tableData = [[NSMutableArray alloc] init];
        [tableData addObject:[NSNumber numberWithFloat:itemRentalPrice-itemRentalPrice*0.20f-itemRentalPrice*0.027f-0.30f]];
        [tableData addObject:[NSNumber numberWithFloat:itemRentalPrice*0.2]];//Service fee
        [tableData addObject:[NSNumber numberWithFloat:itemRentalPrice*0.027f+0.30f]];//Stripe Payment Processing Fee
        [tableData addObject:[NSNumber numberWithFloat:0.0f]];//Default delivery fee
        [tableData addObject:[NSNumber numberWithFloat:0.0f]];//Default insurance fee
        [tableData addObject:[NSNumber numberWithFloat:itemRentalPrice + 0.0f + 0.0f]];//Default grand total price
    }
    return self;
}

- (void)setDeliveryPrice:(float)price
{
    BreakdownTableCell *deliveryCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    deliveryCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", price];
    [tableData replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:price]];
    
    [self calculateGrandTotal];
}

- (void)setInsurancePrice:(float)price
{
    BreakdownTableCell *insuranceCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    insuranceCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", price];
    [tableData replaceObjectAtIndex:4 withObject:[NSNumber numberWithFloat:price]];
    
    [self calculateGrandTotal];
}

- (void)calculateGrandTotal
{
    float grandTotal = 0.0f;
    
    for (int i=0; i<5; i++) {
        NSLog(@"fee: %f", [[tableData objectAtIndex:i] floatValue]);
        grandTotal += [[tableData objectAtIndex:i] floatValue];
    }
    
    BreakdownTableCell *totalCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    totalCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", grandTotal];
}

#pragma UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BreakdownTableCell *cell = (BreakdownTableCell *)[tableView dequeueReusableCellWithIdentifier:@"BreakdownTableCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BreakdownTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.headerLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
    cell.headerLabel.textColor = [UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1.0f];
    
    cell.priceLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:14.0f];
    cell.priceLabel.textColor = [UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1.0f];
    
    switch (indexPath.row) {
        case 0:
            cell.headerLabel.text = @"Subtotal";
            break;
        case 1:
            cell.headerLabel.text = @"Service Fee";
            break;
        case 2:
            cell.headerLabel.text = @"Processing Fee";
            break;
        case 3:
            cell.headerLabel.text = @"Delivery";
            break;
        case 4:
            cell.headerLabel.text = @"Insurance";
            break;
        case 5:
            cell.headerLabel.text = @"Grand Total";
            cell.priceLabel.font = cell.headerLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
            cell.priceLabel.textColor = cell.headerLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
            break;
        default:
            break;
    }
    
    cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[tableData objectAtIndex:indexPath.row] floatValue]];
    
    return cell;
}


@end
