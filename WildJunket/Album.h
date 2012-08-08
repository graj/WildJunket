//
//  Album.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface Album : NSObject{
    int _idCat;
    int _idSubCat;
    int _idAlbum;
    NSString* _key;
    NSString* _name;
    NSURL* _thumbnailURL;
    
}

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray *albums;
@property (nonatomic) NSURL *thumbnailURL;
@property int idCat;
@property int idSubCat;
@property int idAlbum;

- (id)init:(int)idAlbumParam idCatParam:(int)idCatParam idSubCatParam:(int)idSubCatParam nameParam:(NSString*)nameParam keyParam:(NSString*)keyParam;

-(void)setThumbnailPhotoURL:(NSURL *)thumbnailURL;

@end
