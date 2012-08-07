//
//  PhotosAllViewController.h
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import <UIKit/UIKit.h>

@class Album;
@class Photo;
@class CategoryPhotos;
@class SubCategory;

@interface PhotosAllViewController : UIViewController{
    Album *_album;
}


@property (strong, nonatomic) Album *album;

- (id)initWithAlbum:(Album*)album;

@end
