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
    NSMutableDictionary *priceDic;
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
        
        priceDic = [[NSMutableDictionary alloc] init];
        [priceDic setValue:[NSNumber numberWithFloat:itemRentalPrice-itemRentalPrice*0.20f-itemRentalPrice*0.027f-0.30f] forKey:@"subtotal"];
        [priceDic setValue:[NSNumber numberWithFloat:itemRentalPrice*0.2] forKey:@"service"];//Service fee
        [priceDic setValue:[NSNumber numberWithFloat:itemRentalPrice*0.027f+0.30f] forKey:@"processing"];//Stripe Payment Processing Fee
        [priceDic setValue:[NSNumber numberWithFloat:0.0f] forKey:@"delivery"];//Default delivery fee
        [priceDic setValue:[NSNumber numberWithFloat:0.0f] forKey:@"insurance"];//Default insurance fee
        [priceDic setValue:[NSNumber numberWithFloat:itemRentalPrice] forKey:@"total"];//Default grand total price
    }
    return self;
}

- (void)setDeliveryPrice:(float)price
{
    BreakdownTableCell *deliveryCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    deliveryCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", price];
    [priceDic setValue:[NSNumber numberWithFloat:price] forKey:@"delivery"];
    
    [self calculateGrandTotal];
}

- (void)setInsurancePrice:(float)price
{
    BreakdownTableCell *insuranceCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    insuranceCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", price];
    [priceDic setValue:[NSNumber numberWithFloat:price] forKey:@"insurance"];
    
    [self calculateGrandTotal];
}

- (void)calculateGrandTotal
{
    float grandTotal = 0.0f;
    
    for (int j=0; j<priceDic.allValues.count-1; j++) {
        grandTotal += [[priceDic.allValues objectAtIndex:j] floatValue];
    }
    
    BreakdownTableCell *totalCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    totalCell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", grandTotal];
}

- (void)updateTableWithItemInfo:(NSDictionary *)itemInfo
{
    
    float subtotal = [[[itemInfo objectForKey:@"subtotal"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float servicefee = [[[itemInfo objectForKey:@"serfee"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float processingfee = [[[itemInfo objectForKey:@"payfee"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float deliveryfee = [[[itemInfo objectForKey:@"delfee"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float insurancefee = [[[itemInfo objectForKey:@"insfee"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float total = [[[itemInfo objectForKey:@"rTotal"] stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    
    for (int i=0; i<priceDic.allValues.count; i++) {
        BreakdownTableCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        switch (i) {
            case 0:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", subtotal];
                break;
            case 1:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", servicefee];
                break;
            case 2:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", processingfee];
                break;
            case 3:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", deliveryfee];
                break;
            case 4:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", insurancefee];
                break;
            case 5:
                cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", total];
                break;
            default:
                break;
        }
    }
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
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"subtotal"] floatValue]];
            break;
        case 1:
            cell.headerLabel.text = @"Service Fee";
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"service"] floatValue]];
            break;
        case 2:
            cell.headerLabel.text = @"Processing Fee";
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"processing"] floatValue]];
            break;
        case 3:
            cell.headerLabel.text = @"Delivery";
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"delivery"] floatValue]];
            break;
        case 4:
            cell.headerLabel.text = @"Insurance";
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"insurance"] floatValue]];
            break;
        case 5:
            cell.headerLabel.text = @"Total";
            cell.priceLabel.text = [NSString stringWithFormat: @"$%.2f", [[priceDic valueForKey:@"total"] floatValue]];
            cell.priceLabel.font = cell.headerLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
            cell.priceLabel.textColor = cell.headerLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
            break;
        default:
            break;
    }
    
    return cell;
}


@end
