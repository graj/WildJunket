//
//  PhotosAlbumViewController.h
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
@class Album;
@class Photo;
@class CategoryPhotos;
@class SubCategory;

@interface PhotosAlbumViewController : UIViewController{
    SubCategory *_subCategory;
}


@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (strong, nonatomic) SubCategory *subCategory;

- (id)initWithSubCategory:(SubCategory*)subCategory;

@end
