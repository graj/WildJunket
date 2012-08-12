//
//  CountryCodeCell.m
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import "CountryCodeCell.h"

@implementation CountryCodeCell
@synthesize primaryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        primaryLabel = [[UILabel alloc]init];
        primaryLabel.textAlignment = UITextAlignmentLeft;
        primaryLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:40];
                [self.contentView addSubview:primaryLabel];
        primaryLabel.backgroundColor=[UIColor grayColor];
        primaryLabel.textAlignment = UITextAlignmentRight;
        primaryLabel.textColor = [UIColor whiteColor];
        primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
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
    CGRect frame;
    
    frame= CGRectMake(boundsX, 0, 100, 100);
    primaryLabel.frame = frame;
    
  
}

@end
