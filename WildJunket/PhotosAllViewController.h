//
//  PhotosAllViewController.h
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import <UIKit/UIKit.h>
#import "BDDynamicGridViewController.h"

@class Album;
@class Photo;
@class CategoryPhotos;
@class SubCategory;
 
@interface PhotosAllViewController : BDDynamicGridViewController <BDDynamicGridViewDelegate>{
    Album *_album;
    NSArray *_items;
    NSMutableArray *_photosURL;
    NSArray *images;
}


@property (strong, nonatomic) Album *album;

- (id)initWithAlbum:(Album*)album;
@property (nonatomic) NSArray *items;
@property(nonatomic)NSMutableArray *photosURL;

@end
