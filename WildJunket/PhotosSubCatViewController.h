//
//  PhotosSubCatViewController.h
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
@class Album;
@class Photo;
@class CategoryPhotos;
@class SubCategory;

@interface PhotosSubCatViewController : UIViewController{
    CategoryPhotos *_category;
}


@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (strong, nonatomic) CategoryPhotos *category;

- (id)initWithCategory:(CategoryPhotos*)category;

@end