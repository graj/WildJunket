//
//  CategoryPhotos.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface CategoryPhotos : NSObject{
    int _idCat;
    NSString* _name;
    NSMutableArray* _subCats;
    NSURL* _thumbnailURL;
    
}

@property (nonatomic) NSString *name;
@property (nonatomic) NSURL *thumbnailURL;
@property (nonatomic) NSMutableArray *subCats;
@property int idCat;

- (id)init:(int)idCatParam nameParam:(NSString*)nameParam;
-(void)setThumbnailPhotoURL:(NSURL *)thumbnailURL;

@end
