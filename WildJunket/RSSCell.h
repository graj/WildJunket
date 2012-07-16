//
//  RSSCell.h
//  WildJunket
//
//  Created by David García Fernández on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lblTitulo;
@property (nonatomic, retain) IBOutlet UILabel *lblDatos;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
