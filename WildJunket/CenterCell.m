//
//  CenterCell.m
//  WildJunket
//
//  Created by david on 14/08/12.
//
//

#import "CenterCell.h"
#import "SVProgressHUD.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@implementation CenterCell
@synthesize cityLabel, countryLabel, dateLabel, descLabel, scrollView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //City Label
        cityLabel = [[UILabel alloc]init];
        cityLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
        [self.contentView addSubview:cityLabel];
        cityLabel.textAlignment = UITextAlignmentRight;
        cityLabel.textColor = [UIColor blackColor];
        cityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Country Label
        countryLabel = [[UILabel alloc]init];
        countryLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
        [self.contentView addSubview:countryLabel];
        countryLabel.textAlignment = UITextAlignmentRight;
        countryLabel.textColor = [UIColor blackColor];
        countryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Date Label
        dateLabel = [[UILabel alloc]init];
        dateLabel.font = [UIFont fontWithName:@"Vernada" size:20];
        [self.contentView addSubview:dateLabel];
        dateLabel.textAlignment = UITextAlignmentLeft;
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Description Label
        descLabel = [[UILabel alloc]init];
        descLabel.font = [UIFont fontWithName:@"Verdana" size:15];
        descLabel.lineBreakMode=UILineBreakModeWordWrap;
        descLabel.minimumFontSize=12;
        descLabel.numberOfLines=0;
        [self.contentView addSubview:descLabel];
        descLabel.textAlignment = UITextAlignmentLeft;
        descLabel.textColor = [UIColor blackColor];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        
        //Scroll View, tengo que hacer esto aquí, en layoutSubviews peta
        CGRect contentRect = self.contentView.bounds;
        CGFloat width=self.contentView.bounds.size.width;
        CGFloat boundsX = contentRect.origin.x;
        CGFloat boundsY = contentRect.origin.y;

        scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(boundsX, boundsY+210, width, 270)];
        scrollView.autoresizesSubviews=YES;
        scrollView.contentMode=UIViewContentModeScaleToFill;
        [self.contentView addSubview:scrollView];
        
        
        //Cell
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat width=self.contentView.bounds.size.width;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsY = contentRect.origin.y;
    
    //City Label
    cityLabel.frame = CGRectMake(boundsX, boundsY+30, width, 32);
    
    //Country Label
    countryLabel.frame = CGRectMake(boundsX, boundsY+70, width, 32);
    
    //Data Label
    dateLabel.frame = CGRectMake(boundsX, boundsY+110, width, 22);
    
    //Description Label
    descLabel.frame = CGRectMake(boundsX, boundsY+130, width, 60);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
