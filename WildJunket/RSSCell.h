//
//  RSSCell.h
//  WildJunket
//
//  Created by David García Fernández on 16/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitulo;
@property (nonatomic, weak) IBOutlet UILabel *lblDatos;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end
