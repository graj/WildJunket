//
//  CenterCell.h
//  WildJunket
//
//  Created by david on 14/08/12.
//
//

#import <UIKit/UIKit.h>

@interface CenterCell : UITableViewCell <UIScrollViewDelegate>{
    UILabel *cityLabel;
    UILabel *countryLabel;
    UILabel *dateLabel;
    UILabel *descLabel;
    UIScrollView *scrollView;
    
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,retain) UILabel *cityLabel;
@property (nonatomic,retain) UILabel *countryLabel;
@property (nonatomic,retain) UILabel *dateLabel;
@property (nonatomic,retain) UILabel *descLabel;

@end
