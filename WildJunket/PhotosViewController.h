//
//  SecondViewController.h
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface PhotosViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UILabel *titulo;


@end
