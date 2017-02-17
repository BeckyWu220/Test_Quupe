//
//  QpPriceView.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-11-17.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "QpPriceView.h"

@interface QpPriceView ()
{
    NSMutableArray *priceLabelArray;
}
@end

@implementation QpPriceView
@synthesize rentalDay, rentalWeek, rentalMonth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self){
        self.frame = frame;
        self.userInteractionEnabled = NO;
        
        priceLabelArray = [[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++){
            UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(i*self.frame.size.width/3, 0, self.frame.size.width/3, 62)];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, priceView.frame.size.width, priceView.frame.size.height*2/3)];
            priceLabel.text = @"$$$";
            priceLabel.textAlignment = NSTextAlignmentCenter;
            priceLabel.font = [UIFont fontWithName:@"SFUIText-Semibold" size:20.0f];
            priceLabel.textColor = [UIColor colorWithRed:117.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
            [priceView addSubview:priceLabel];
            [priceLabelArray addObject:priceLabel];
            
            UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, priceView.frame.size.height*2/3, priceView.frame.size.width, priceView.frame.size.height/3)];
            switch (i) {
                case 0:
                    tagLabel.text = @"PER DAY";
                    break;
                case 1:
                    tagLabel.text = @"PER WEEK";
                    break;
                case 2:
                    tagLabel.text = @"PER MONTH";
                    break;
                default:
                    break;
            }
            
            tagLabel.textAlignment = NSTextAlignmentCenter;
            tagLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:10.0f];
            tagLabel.textColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:1.0f];
            [priceView addSubview:tagLabel];
            
            [self addSubview:priceView];
        }
        
    }
    return self;
}


- (void)calculateQuupePriceWithOriginalPrice:(float)oPrice Category:(NSString *)category
{
    float Con = 0.0f;
    float Cos = 0.0f;
    float rentMin = 0.0f;
    float originalPriceInput = oPrice;
    float rentMinwCut = 0.0f;
    float rentalPerCut = 0.0f;
    
    rentalDay = 0.0f;
    rentalWeek = 0.0f;
    rentalMonth = 0.0f;
    
    if ([category  isEqual: @"ele"] || [category  isEqual: @"Electronics"]) {
        Con = 0.25;
        Cos = 180;
    }else if ([category  isEqual: @"out"] || [category  isEqual: @"Outdoor and Adventure"]) {
        Con = 0.30;
        Cos = 150;
    }else if ([category  isEqual: @"rec"] || [category  isEqual: @"Fun and Recreation"]) {
        Con = 0.27;
        Cos = 180;
    }else if ([category  isEqual: @"hom"] || [category  isEqual: @"Home, Garden and Tools"]) {
        Con = 0.31;
        Cos = 150;
    }else if ([category  isEqual: @"oth"] || [category  isEqual: @"Others"]) {
        Con = 0.30;
        Cos = 150;
    }else{
        Con = 0.30;
        Cos = 150;
    }
    
    rentMin = (originalPriceInput + (1 - Con) * originalPriceInput) / Cos;
    rentMinwCut = rentMin + (0.2*rentMin);
    
    if (rentMinwCut<=5) {
        rentalPerCut=0.10;
    }else if (rentMinwCut>5 && rentMinwCut<=15) {
        rentalPerCut=0.09;
    }else if (rentMinwCut>16 && rentMinwCut<=30) {
        rentalPerCut=0.08;
    }else if (rentMinwCut>31 && rentMinwCut<=50) {
        rentalPerCut=0.07;
    }else if (rentMinwCut>51 && rentMinwCut<=75) {
        rentalPerCut=0.06;
    }else if (rentMinwCut>76 && rentMinwCut<=100) {
        rentalPerCut=0.05;
    }else if (rentMinwCut>101 && rentMinwCut<=135) {
        rentalPerCut=0.04;
    }else if (rentMinwCut>136 && rentMinwCut<=175) {
        rentalPerCut=0.03;
    }else if (rentMinwCut>176) {
        rentalPerCut=0.02;
    }else {
        rentalPerCut=0.07;
    }
    
    NSMutableArray *rentalRange = [[NSMutableArray alloc] init];
    float rentMinwCutCopy = rentMinwCut;
    for (int i=0; i<10; i++) {
        rentMinwCutCopy *= (1+rentalPerCut);
        [rentalRange addObject:[NSNumber numberWithFloat:rentMinwCutCopy]];
    }
    //NSLog(@"Rental Range: %@", rentalRange);
    
    rentalDay = [[rentalRange objectAtIndex:8] floatValue];
    rentalWeek = [[rentalRange objectAtIndex:6] floatValue] * 7;
    rentalMonth = [[rentalRange objectAtIndex:0] floatValue] * 30;
    
    NSLog(@"Rental --- Day: %f, Week: %f, Month: %f", rentalDay, rentalWeek, rentalMonth);
    
    rentalDay = [[NSString stringWithFormat:@"%.2f", rentalDay] floatValue];
    rentalWeek = [[NSString stringWithFormat:@"%.2f", rentalWeek] floatValue];
    rentalMonth = [[NSString stringWithFormat:@"%.2f", rentalMonth] floatValue];
    
    NSMutableArray *attributedPriceStrings = [[NSMutableArray alloc] init];
    
    for (int j=0; j<3; j++) {
    
        NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:@"$" attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"SFUIText-Medium" size:14.0f] forKey:NSFontAttributeName]];
        switch (j) {
            case 0:
                [price appendAttributedString:[[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%.2f", rentalDay] attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"SFUIText-Semibold" size:20.0f] forKey:NSFontAttributeName]]];
                break;
            
            case 1:
                [price appendAttributedString:[[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%.2f", rentalWeek] attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"SFUIText-Semibold" size:20.0f] forKey:NSFontAttributeName]]];
                break;
                
            case 2:
                [price appendAttributedString:[[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%.2f", rentalMonth] attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"SFUIText-Semibold" size:20.0f] forKey:NSFontAttributeName]]];
                break;
                
            default:
                break;
        }
        [attributedPriceStrings addObject:price];
        
    }
    
    for (int k=0; k<3; k++) {
        UILabel *priceLabel = [priceLabelArray objectAtIndex:k];
        priceLabel.attributedText = [attributedPriceStrings objectAtIndex:k];
    }
}

- (void)calculateQuupePriceForItem:(Item *)item
{
    [self calculateQuupePriceWithOriginalPrice:item.oPrice.floatValue Category:item.category];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
