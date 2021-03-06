//
//  CenterCell.h
//  WildJunket
//
//  Created by david on 14/08/12.
//
//

#import <UIKit/UIKit.h>

@interface CenterCell : UITableViewCell {
    UILabel *cityLabel;
    UILabel *countryLabel;
    UILabel *dateLabel;
    UILabel *descLabel;
    UIScrollView *scrollView;
    UIView *dingBat;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,retain) UILabel *cityLabel;
@property (nonatomic,retain) UILabel *countryLabel;
@property (nonatomic,retain) UILabel *dateLabel;
@property (nonatomic,retain) UILabel *descLabel;
@property (nonatomic,retain) UIView *dingBat;
@property bool portrait;

-(void)checkOrientations:(bool)portrait;

@end
