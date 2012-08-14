//
//  CountryCodeCell.h
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import <UIKit/UIKit.h>

@interface CountryCodeCell : UITableViewCell{
    UILabel *primaryLabel;
    UILabel *cityLabel;
}

@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *cityLabel;

@end
