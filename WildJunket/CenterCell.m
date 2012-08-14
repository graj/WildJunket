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
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.backgroundColor=[UIColor clearColor];
        cityLabel.shadowColor=[UIColor blackColor];
        cityLabel.shadowOffset=CGSizeMake(0.0, -1.0);
        cityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Country Label
        countryLabel = [[UILabel alloc]init];
        countryLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
        [self.contentView addSubview:countryLabel];
        countryLabel.textAlignment = UITextAlignmentRight;
        countryLabel.textColor = [UIColor whiteColor];
        countryLabel.backgroundColor=[UIColor clearColor];
        countryLabel.shadowColor=[UIColor blackColor];
        countryLabel.shadowOffset=CGSizeMake(0.0, -1.0);

        countryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Date Label
        dateLabel = [[UILabel alloc]init];
        dateLabel.font = [UIFont fontWithName:@"Vernada-Italic" size:15];
        [self.contentView addSubview:dateLabel];
        dateLabel.textAlignment = UITextAlignmentRight;
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.backgroundColor=[UIColor clearColor];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        //Description Label
        descLabel = [[UILabel alloc]init];
        descLabel.font = [UIFont fontWithName:@"Verdana" size:18];
        descLabel.lineBreakMode=UILineBreakModeWordWrap;
        descLabel.minimumFontSize=12;
        descLabel.numberOfLines=0;
        [self.contentView addSubview:descLabel];
        descLabel.textAlignment = UITextAlignmentLeft;
        descLabel.textColor = [UIColor whiteColor];
        descLabel.backgroundColor=[UIColor clearColor];
        descLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        
        //Scroll View, tengo que hacer esto aquí, en layoutSubviews peta
        CGRect contentRect = self.contentView.bounds;
        CGFloat width=self.contentView.bounds.size.width;
        CGFloat boundsX = contentRect.origin.x;
        CGFloat boundsY = contentRect.origin.y;

        scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(boundsX, boundsY+200, width, 280)];
        scrollView.autoresizesSubviews=YES;
        scrollView.contentMode=UIViewContentModeScaleToFill;
        scrollView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:scrollView];
        
        
        //Cell
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"photosbackground3.png"]];

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
    cityLabel.frame = CGRectMake(boundsX, boundsY+20, width, 32);
    
    //Country Label
    countryLabel.frame = CGRectMake(boundsX, boundsY+60, width, 32);
    
    //Data Label
    dateLabel.frame = CGRectMake(boundsX, boundsY+100, width, 22);
    
    //Description Label
    descLabel.frame = CGRectMake(boundsX, boundsY+130, width, 60);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
