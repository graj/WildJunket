//
//  CountryCodeCell.m
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import "CountryCodeCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CountryCodeCell
@synthesize primaryLabel, cityLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //Primary Label
        primaryLabel = [[UILabel alloc]init];
        primaryLabel.textAlignment = UITextAlignmentLeft;
        primaryLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:40];
                [self.contentView addSubview:primaryLabel];
        primaryLabel.backgroundColor=[UIColor grayColor];
        primaryLabel.textAlignment = UITextAlignmentRight;
        primaryLabel.textColor = [UIColor whiteColor];
        primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //City Label
        cityLabel = [[UILabel alloc]init];
        cityLabel.textAlignment = UITextAlignmentLeft;
        cityLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:10];
        [self.contentView addSubview:cityLabel];
        cityLabel.backgroundColor=[UIColor grayColor];
        cityLabel.textAlignment = UITextAlignmentRight;
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Cell selected view, con estos colores mola más
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, 100, 100);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:90.0/255.0 green:74.0/255.0 blue:66.0/255.0 alpha:1.0]CGColor], (id)[[UIColor blackColor]CGColor], nil];
        UIView* selectedView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [selectedView.layer addSublayer:gradient];
        
        self.selectedBackgroundView=selectedView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    //primaryLabel.backgroundColor=[UIColor brownColor];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
   
    primaryLabel.frame = CGRectMake(boundsX, 0, 100, 80);
    cityLabel.frame = CGRectMake(boundsX, 80, 100, 20);
    
  
}

@end
